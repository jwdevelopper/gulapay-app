import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/cliente/dto/filtro_clientes.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_detalhe_page.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_form_page.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import 'package:my_app_teste/modules/cliente/widgets/cartao_cliente.dart';

/// Cadastro de clientes.
///
/// Cuida de estado, carga e navegação: o recorte vive em [FiltroClientes] e
/// cada linha em [CartaoCliente].
///
/// Cliente não é excluído — é inativado e pode voltar (RNF08), porque todo
/// pedido já feito aponta para ele.
class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final _busca = TextEditingController();

  List<ClienteResponse> _clientes = [];
  FiltroClientes _filtro = const FiltroClientes();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregar({bool mostrarCarregando = true}) async {
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await listarClientes();
      if (mounted) {
        setState(() {
          _clientes = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar os clientes.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _limparFiltros() {
    _busca.clear();
    setState(() => _filtro = const FiltroClientes());
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({ClienteResponse? cliente}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
    if (salvou == true && mounted) await _carregar();
  }

  Future<void> _abrirDetalhe(ClienteResponse cliente) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClienteDetalhesPage(cliente: cliente)),
    );
    if (alterou == true && mounted) await _carregar();
  }

  Future<bool> _confirmarInativacao(ClienteResponse c) async =>
      await AppDialogoConfirmacao.mostrar(
        context,
        titulo: 'Inativar cliente',
        mensagem:
            'Deseja inativar "${c.nome ?? 'este cliente'}"? '
            'O histórico de pedidos será preservado.',
        rotuloConfirmar: 'Inativar',
        tom: TomConfirmacao.destrutivo,
      ) ??
      false;

  /// Inativa e devolve se deu certo — o `Dismissible` usa o retorno para
  /// decidir se o card some ou volta ao lugar.
  Future<bool> _inativar(ClienteResponse c) async {
    if (c.id == null) return false;
    try {
      await inativarCliente(c.id!);
      _avisar('Cliente "${c.nome ?? ''}" inativado.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao inativar: ${e.message}');
      return false;
    }
  }

  Future<void> _reativar(ClienteResponse c) async {
    if (c.id == null) return;
    final confirmou =
        await AppDialogoConfirmacao.mostrar(
          context,
          titulo: 'Ativar cliente',
          mensagem: 'Deseja reativar "${c.nome ?? 'este cliente'}"?',
          rotuloConfirmar: 'Ativar',
          tom: TomConfirmacao.positivo,
        ) ??
        false;
    if (!confirmou) return;

    try {
      await reativarCliente(c.id!, c);
      _avisar('Cliente "${c.nome ?? ''}" reativado.', sucesso: true);
      await _carregar();
    } on ApiError catch (e) {
      _avisar('Erro ao reativar: ${e.message}');
    }
  }

  /// Caminho do menu de 3 pontos: confirma, inativa e recarrega. O do
  /// arrastar é separado porque o `Dismissible` já tira o card da lista.
  Future<void> _inativarPeloMenu(ClienteResponse c) async {
    if (!await _confirmarInativacao(c)) return;
    if (await _inativar(c) && mounted) await _carregar();
  }

  void _avisar(String mensagem, {bool sucesso = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? AppTema.sucesso : AppTema.erro,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppTema.primaria,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      onPressed: _abrirFormulario,
      child: const Icon(Icons.add_rounded),
    ),
    body: SafeArea(
      child: Column(
        children: [
          _filtros(),
          Expanded(
            child: RefreshIndicator(
              color: AppTema.primaria,
              onRefresh: () => _carregar(mostrarCarregando: false),
              child: _corpo(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _filtros() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Column(
      children: [
        AppCampoBusca(
          controle: _busca,
          dica: 'Buscar por nome ou telefone…',
          aoMudar: (v) => setState(() => _filtro = _filtro.copiarCom(texto: v)),
        ),
        const SizedBox(height: 10),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            for (final situacao in SituacaoCadastro.values)
              AppChipFiltro(
                rotulo: situacao.rotulo,
                selecionado: _filtro.situacao == situacao,
                aoTocar: () => setState(
                  () => _filtro = _filtro.copiarCom(situacao: situacao),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _corpo() {
    if (_carregando) return const AppCarregando();
    if (_erro != null) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.cloud_off_rounded,
          titulo: 'Não foi possível carregar',
          mensagem: _erro!,
          rotuloBotao: 'Tentar novamente',
          iconeBotao: Icons.refresh_rounded,
          aoTocarBotao: _carregar,
        ),
      );
    }

    final filtrados = _filtro.aplicar(_clientes);
    if (filtrados.isEmpty) {
      return _rolavel(
        _filtro.vazio
            ? AppEstadoVazio(
                icone: Icons.people_outline_rounded,
                titulo: 'Nenhum cliente cadastrado',
                mensagem:
                    'O telefone do cliente identifica todo pedido. '
                    'Cadastre o primeiro para começar a vender.',
                rotuloBotao: 'Novo cliente',
                aoTocarBotao: _abrirFormulario,
              )
            : AppEstadoVazio(
                icone: Icons.search_off_rounded,
                titulo: 'Nada encontrado',
                mensagem: 'Nenhum cliente corresponde aos filtros aplicados.',
                rotuloBotao: 'Limpar filtros',
                iconeBotao: Icons.filter_alt_off_rounded,
                secundario: true,
                aoTocarBotao: _limparFiltros,
              ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final cliente = filtrados[i];
        return CartaoCliente(
          cliente: cliente,
          aoAbrir: () => _abrirDetalhe(cliente),
          aoEditar: () => _abrirFormulario(cliente: cliente),
          aoInativar: () => _inativarPeloMenu(cliente),
          aoReativar: () => _reativar(cliente),
          aoConfirmarArrastar: () async {
            if (!await _confirmarInativacao(cliente)) return false;
            final ok = await _inativar(cliente);
            if (ok && mounted) await _carregar();
            return ok;
          },
        );
      },
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 90),
    children: [filho],
  );
}
