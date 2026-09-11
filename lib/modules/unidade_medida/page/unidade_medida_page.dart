import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/filtro_unidades.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/rotulos_unidade.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/unidade_medida/page/unidade_medida_form_page.dart';
import 'package:my_app_teste/modules/unidade_medida/service/unidade_medida_service.dart';
import 'package:my_app_teste/modules/unidade_medida/widgets/cartao_unidade.dart';

/// Cadastro de unidades de medida.
///
/// Cuida de estado, carga e navegação: o recorte vive em [FiltroUnidades],
/// as traduções em [RotulosUnidade] e cada linha em [CartaoUnidade].
///
/// Unidade não é excluída — é inativada e pode voltar (RNF08). O backend
/// ainda recusa inativar uma unidade em uso; a mensagem dele é exibida
/// como está.
class UnidadeMedidaPage extends StatefulWidget {
  const UnidadeMedidaPage({super.key});

  @override
  State<UnidadeMedidaPage> createState() => _UnidadeMedidaPageState();
}

class _UnidadeMedidaPageState extends State<UnidadeMedidaPage> {
  final _busca = TextEditingController();

  List<UnidadeMedidaResponse> _unidades = [];
  FiltroUnidades _filtro = const FiltroUnidades();
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
      final lista = await listarUnidadesMedida();
      if (mounted) {
        setState(() {
          _unidades = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar as unidades.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _aplicarFiltro(FiltroUnidades novo) => setState(() => _filtro = novo);

  void _limparFiltros() {
    _busca.clear();
    setState(() => _filtro = const FiltroUnidades());
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({UnidadeMedidaResponse? unidade}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => UnidadeMedidaFormPage(unidade: unidade),
      ),
    );
    if (salvou == true && mounted) await _carregar();
  }

  Future<bool> _confirmarInativacao(UnidadeMedidaResponse u) async =>
      await AppDialogoConfirmacao.mostrar(
        context,
        titulo: 'Inativar unidade',
        mensagem:
            'Deseja inativar "${u.nome ?? 'esta unidade'}" '
            '(${u.simbolo ?? ''})? Ela deixará de aparecer como opção em '
            'novos cadastros.',
        rotuloConfirmar: 'Inativar',
        tom: TomConfirmacao.destrutivo,
      ) ??
      false;

  /// Inativa e devolve se deu certo — o `Dismissible` usa o retorno para
  /// decidir se o card some ou volta ao lugar.
  Future<bool> _inativar(UnidadeMedidaResponse u) async {
    if (u.id == null) return false;
    try {
      await inativarUnidadeMedida(u.id!);
      _avisar('"${u.nome ?? u.simbolo}" inativada.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao inativar: ${e.message}');
      return false;
    }
  }

  Future<void> _reativar(UnidadeMedidaResponse u) async {
    if (u.id == null) return;
    final confirmou =
        await AppDialogoConfirmacao.mostrar(
          context,
          titulo: 'Ativar unidade',
          mensagem:
              'Deseja reativar "${u.nome ?? 'esta unidade'}" '
              '(${u.simbolo ?? ''})?',
          rotuloConfirmar: 'Ativar',
          tom: TomConfirmacao.positivo,
        ) ??
        false;
    if (!confirmou) return;

    try {
      await reativarUnidadeMedida(u.id!, u);
      _avisar('"${u.nome ?? u.simbolo}" reativada.', sucesso: true);
      await _carregar();
    } on ApiError catch (e) {
      _avisar('Erro ao reativar: ${e.message}');
    }
  }

  /// Caminho do menu de 3 pontos: confirma, inativa e recarrega. O do
  /// arrastar é separado porque o `Dismissible` já tira o card da lista.
  Future<void> _inativarPeloMenu(UnidadeMedidaResponse u) async {
    if (!await _confirmarInativacao(u)) return;
    if (await _inativar(u) && mounted) await _carregar();
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
          dica: 'Buscar por nome ou símbolo…',
          aoMudar: (v) => _aplicarFiltro(_filtro.copiarCom(texto: v)),
        ),
        const SizedBox(height: 10),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            for (final situacao in SituacaoCadastro.values)
              AppChipFiltro(
                rotulo: situacao.rotulo,
                selecionado: _filtro.situacao == situacao,
                aoTocar: () =>
                    _aplicarFiltro(_filtro.copiarCom(situacao: situacao)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            AppChipFiltro(
              rotulo: 'Todos os tipos',
              selecionado: _filtro.tipo == null,
              aoTocar: () =>
                  _aplicarFiltro(_filtro.copiarCom(limparTipo: true)),
            ),
            for (final tipo in RotulosUnidade.tipos)
              AppChipFiltro(
                rotulo: RotulosUnidade.tipo(tipo),
                selecionado: _filtro.tipo == tipo,
                aoTocar: () => _aplicarFiltro(_filtro.alternarTipo(tipo)),
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

    final filtradas = _filtro.aplicar(_unidades);
    if (filtradas.isEmpty) {
      return _rolavel(
        _filtro.vazio
            ? AppEstadoVazio(
                icone: Icons.straighten_rounded,
                titulo: 'Nenhuma unidade cadastrada',
                mensagem:
                    'As unidades definem como o estoque é medido e '
                    'convertido. Cadastre a primeira para começar.',
                rotuloBotao: 'Nova unidade',
                aoTocarBotao: _abrirFormulario,
              )
            : AppEstadoVazio(
                icone: Icons.search_off_rounded,
                titulo: 'Nada encontrado',
                mensagem: 'Nenhuma unidade corresponde aos filtros aplicados.',
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
      itemCount: filtradas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final unidade = filtradas[i];
        return CartaoUnidade(
          unidade: unidade,
          aoEditar: () => _abrirFormulario(unidade: unidade),
          aoInativar: () => _inativarPeloMenu(unidade),
          aoReativar: () => _reativar(unidade),
          aoConfirmarArrastar: () async {
            if (!await _confirmarInativacao(unidade)) return false;
            final ok = await _inativar(unidade);
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
