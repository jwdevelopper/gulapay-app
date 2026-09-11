import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/cabecalho_secao.dart';
import 'package:my_app_teste/modules/insumo/dto/filtro_insumos.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/rotulos_insumo.dart';
import 'package:my_app_teste/modules/insumo/page/insumo_form_page.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';
import 'package:my_app_teste/modules/insumo/widgets/insumo_card.dart';
import 'package:my_app_teste/modules/insumo/widgets/insumo_sort_sheet.dart';

/// Listagem de insumos, com busca, ordenação e seções.
///
/// Cuida apenas de estado, carga e navegação: o recorte, a ordem e o
/// agrupamento vivem em [FiltroInsumos], e ícones, cores e formatações em
/// [RotulosInsumo].
///
/// A faixa do topo mostra quantos insumos estão abaixo do mínimo — é o
/// alerta de reposição do RF43, e o motivo de a ordenação padrão ser a de
/// alerta.
class InsumosListPage extends StatefulWidget {
  const InsumosListPage({super.key});

  @override
  State<InsumosListPage> createState() => _InsumosListPageState();
}

class _InsumosListPageState extends State<InsumosListPage> {
  final _service = InsumoService();
  final _busca = TextEditingController();

  List<InsumoResponse> _insumos = [];
  FiltroInsumos _filtro = const FiltroInsumos();
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
      final lista = await _service.listar(apenasAtivos: true);
      if (mounted) {
        setState(() {
          _insumos = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar os insumos.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  int get _abaixoDoMinimo =>
      _insumos.where((i) => i.abaixoDoMinimo == true).length;

  List<InsumoResponse> get _filtrados => _filtro.aplicar(_insumos);

  void _limparBusca() {
    _busca.clear();
    setState(() => _filtro = _filtro.copiarCom(texto: ''));
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({InsumoResponse? insumo}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InsumoFormPage(insumo: insumo)),
    );
    if (salvou == true) await _carregar();
  }

  Future<void> _abrirOrdenacao() async {
    final escolhida = await InsumoSortSheet.mostrar(
      context,
      selecionada: _filtro.ordenacao,
    );
    if (escolhida != null && escolhida != _filtro.ordenacao) {
      setState(() => _filtro = _filtro.copiarCom(ordenacao: escolhida));
    }
  }

  /// Confirma e exclui. Devolve `true` quando o card pode sair da lista.
  Future<bool> _confirmarEExcluir(InsumoResponse insumo) async {
    final confirmou = await AppDialogoConfirmacao.exclusao(
      context,
      titulo: 'Excluir insumo',
      mensagem: 'Deseja realmente excluir "${insumo.nome ?? ''}"?',
    );
    if (confirmou != true || insumo.id == null) return false;

    try {
      await _service.excluir(insumo.id!);
      if (!mounted) return false;
      setState(() => _insumos.removeWhere((i) => i.id == insumo.id));
      _avisar('Insumo "${insumo.nome ?? ''}" excluído.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao excluir: ${e.message}');
      return false;
    } catch (e) {
      _avisar('Erro ao excluir: $e');
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
      onPressed: _abrirFormulario,
      foregroundColor: Colors.white,
      backgroundColor: AppTema.primaria,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _faixaResumo(),
          AppCampoBusca(
            controle: _busca,
            dica: 'Buscar insumo…',
            margemHorizontal: 16,
            aoMudar: (valor) =>
                setState(() => _filtro = _filtro.copiarCom(texto: valor)),
            aoLimpar: _limparBusca,
          ),
          const SizedBox(height: 4),
          _cabecalhoResultados(),
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

  /// Total de insumos e quantos precisam de reposição (RF43).
  Widget _faixaResumo() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Row(
      children: [
        Text(
          '${_insumos.length} ativos',
          style: const TextStyle(fontSize: 13, color: AppTema.textoSecundario),
        ),
        if (_abaixoDoMinimo > 0) ...[
          const Text(
            ' · ',
            style: TextStyle(fontSize: 13, color: AppTema.textoSecundario),
          ),
          Text(
            '$_abaixoDoMinimo abaixo do mínimo',
            style: const TextStyle(
              fontSize: 13,
              color: AppTema.erro,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _cabecalhoResultados() {
    final total = _filtrados.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$total ${total == 1 ? 'insumo' : 'insumos'}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTema.textoSecundario,
            ),
          ),
          const Spacer(),
          if (!_filtro.vazio)
            TextButton(
              onPressed: _limparBusca,
              style: TextButton.styleFrom(foregroundColor: AppTema.primaria),
              child: const Text('Limpar busca'),
            ),
          TextButton.icon(
            onPressed: _abrirOrdenacao,
            style: TextButton.styleFrom(foregroundColor: AppTema.texto),
            icon: const Icon(Icons.sort_rounded, size: 18),
            label: Text(_filtro.ordenacao.rotulo),
          ),
        ],
      ),
    );
  }

  Widget _lista() {
    if (_carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 140),
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
          aoTocarBotao: _carregar,
        ),
      );
    }
    if (_insumos.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.inventory_2_rounded,
          titulo: 'Sem insumos por aqui',
          mensagem:
              'Cadastre seu primeiro insumo para começar a controlar o '
              'estoque.',
          rotuloBotao: 'Cadastrar insumo',
          aoTocarBotao: _abrirFormulario,
        ),
      );
    }
    if (_filtrados.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum insumo encontrado',
          mensagem: 'Tente um termo diferente ou limpe a busca para ver todos.',
          rotuloBotao: 'Limpar busca',
          iconeBotao: Icons.close_rounded,
          secundario: true,
          aoTocarBotao: _limparBusca,
        ),
      );
    }

    final itens = _filtro.agrupar(_insumos);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
      itemCount: itens.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = itens[i];
        return item is CabecalhoSecao
            ? _cabecalhoSecao(item)
            : _cartao(item as InsumoResponse);
      },
    );
  }

  Widget _cabecalhoSecao(CabecalhoSecao secao) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
    child: Text(
      '${secao.rotulo} · ${secao.quantidade}',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTema.textoSecundario,
      ),
    ),
  );

  Widget _cartao(InsumoResponse insumo) => InsumoCard(
    insumo: insumo,
    icon: RotulosInsumo.icone(insumo),
    accentColor: RotulosInsumo.corDestaque(insumo),
    stockBarColor: RotulosInsumo.corDaBarra(insumo),
    stockText: RotulosInsumo.estoque(insumo),
    percentVsMinimo: RotulosInsumo.percentualVsMinimo(insumo),
    onTap: () => _abrirFormulario(insumo: insumo),
    onEdit: () => _abrirFormulario(insumo: insumo),
    onConfirmDelete: () => _confirmarEExcluir(insumo),
  );

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 38, 16, 140),
    children: [filho],
  );
}
