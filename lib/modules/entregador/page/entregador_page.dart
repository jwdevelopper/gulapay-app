import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/dto/filtro_entregadores.dart';
import 'package:my_app_teste/modules/entregador/page/entregador_form_page.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_active_count.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_card.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_results_header.dart';

/// Cadastro de entregadores.
///
/// Cuida de estado, carga e navegação: a busca e a ordem vivem em
/// [FiltroEntregadores] e cada linha em [EntregadorCard].
///
/// Entregador não tem login — é um recurso cadastrado que recebe a comanda
/// impressa (seção 3.5). "Excluir" aqui é inativar (RNF08): o entregador
/// sai da lista, mas as entregas que ele já fez continuam apontando para
/// ele.
class EntregadorPage extends StatefulWidget {
  /// Permite injetar um service nos testes.
  final EntregadorService? service;

  const EntregadorPage({super.key, this.service});

  @override
  State<EntregadorPage> createState() => _EntregadorPageState();
}

class _EntregadorPageState extends State<EntregadorPage> {
  late final EntregadorService _service = widget.service ?? EntregadorService();
  final _busca = TextEditingController();

  List<EntregadorResponse> _entregadores = [];
  FiltroEntregadores _filtro = const FiltroEntregadores();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    // Registra a acao do "+" da barra inferior para esta aba.
    AcoesCriacao.registrar(TitulosAba.entregadores, _abrirFormulario);
    _carregar();
  }

  /// Recarrega a lista a cada hot reload.
  ///
  /// Só roda em desenvolvimento, e existe porque a tela costuma ser
  /// editada com o app aberto — sem isso, cada alteração deixaria a lista
  /// congelada no que foi carregado antes.
  @override
  void reassemble() {
    super.reassemble();
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
      final lista = await _service.listar(apenasAtivos: true);
      if (mounted) {
        setState(() {
          _entregadores = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Erro inesperado ao consultar a API.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<EntregadorResponse> get _filtrados => _filtro.aplicar(_entregadores);

  /// Contagem exibida no topo. Reflete o total carregado, não o filtrado —
  /// é a informação operacional ("quantos entregadores tenho hoje"), que
  /// não deve mudar quando alguém digita na busca.
  String get _rotuloContagem {
    if (_carregando) return 'Carregando entregadores…';
    if (_erro != null) return 'Entregadores ativos indisponíveis';
    final total = _entregadores.length;
    return '$total ${total == 1 ? 'entregador ativo' : 'entregadores ativos'}';
  }

  void _limparBusca() {
    _busca.clear();
    setState(() => _filtro = _filtro.copiarCom(texto: ''));
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({EntregadorResponse? entregador}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EntregadorFormPage(entregador: entregador, service: _service),
      ),
    );
    if (salvou != true || !mounted) return;
    _avisar(
      entregador == null ? 'Entregador cadastrado.' : 'Entregador atualizado.',
      sucesso: true,
    );
    await _carregar();
  }

  /// Confirma e inativa. Devolve `true` quando o card pode sair da lista.
  Future<bool> _confirmarEExcluir(EntregadorResponse entregador) async {
    final confirmou = await AppDialogoConfirmacao.mostrar(
      context,
      titulo: 'Excluir entregador',
      mensagem:
          'Deseja excluir "${entregador.nome}"? O entregador será inativado '
          'e sairá desta lista.',
      rotuloConfirmar: 'Excluir',
      tom: TomConfirmacao.destrutivo,
    );
    if (confirmou != true || entregador.id == null) return false;

    try {
      await _service.inativar(entregador.id!);
      if (!mounted) return false;
      setState(() => _entregadores.removeWhere((e) => e.id == entregador.id));
      _avisar('Entregador "${entregador.nome}" excluído.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao excluir: ${e.message}');
      return false;
    } catch (_) {
      _avisar('Erro inesperado ao excluir o entregador.');
      return false;
    }
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
      tooltip: 'Cadastrar entregador',
      onPressed: _abrirFormulario,
      backgroundColor: AppTema.primaria,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded),
    ),
    body: SafeArea(
      child: Column(
        children: [
          EntregadorActiveCount(label: _rotuloContagem),
          AppCampoBusca(
            controle: _busca,
            dica: 'Buscar entregador…',
            margemHorizontal: 16,
            aoMudar: (valor) =>
                setState(() => _filtro = _filtro.copiarCom(texto: valor)),
            aoLimpar: _limparBusca,
          ),
          EntregadorResultsHeader(
            resultCount: _filtrados.length,
            ascending: _filtro.crescente,
            onSortTap: () => setState(() => _filtro = _filtro.inverterOrdem()),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTema.primaria,
              onRefresh: () => _carregar(mostrarCarregando: false),
              child: _lista(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _lista() {
    if (_carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 96),
        children: const [SizedBox(height: 120), AppCarregando()],
      );
    }
    if (_erro != null) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.cloud_off_rounded,
          titulo: 'Não foi possível carregar',
          mensagem: _erro!,
          rotuloBotao: 'Tentar novamente',
          iconeBotao: Icons.refresh_rounded,
          secundario: true,
          aoTocarBotao: _carregar,
        ),
      );
    }
    if (_entregadores.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.delivery_dining_rounded,
          titulo: 'Sem entregadores por aqui',
          mensagem:
              'Cadastre o primeiro entregador para organizar as entregas '
              'dos pedidos.',
          rotuloBotao: 'Cadastrar entregador',
          iconeBotao: Icons.add_rounded,
          aoTocarBotao: _abrirFormulario,
        ),
      );
    }

    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum entregador encontrado',
          mensagem: 'Tente buscar por outro nome ou telefone.',
          rotuloBotao: 'Limpar busca',
          iconeBotao: Icons.close_rounded,
          secundario: true,
          aoTocarBotao: _limparBusca,
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final entregador = filtrados[i];
        return EntregadorCard(
          entregador: entregador,
          onTap: () => _abrirFormulario(entregador: entregador),
          onEdit: () => _abrirFormulario(entregador: entregador),
          onConfirmDelete: () => _confirmarEExcluir(entregador),
        );
      },
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
    children: [filho],
  );
}
