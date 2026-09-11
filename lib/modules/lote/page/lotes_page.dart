import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/filtro_lotes.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/page/lote_detalhes_page.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/widgets/cabecalho_insumo_lotes.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_card.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_insumo_seletor.dart';

/// Lotes de um insumo, em ordem de validade (FEFO).
///
/// A tela tem dois momentos: enquanto nenhum insumo foi escolhido ela só
/// convida a escolher um — `GET /lotes` exige o `insumoId` —; escolhido o
/// insumo, mostra a lista com busca e recorte por validade.
///
/// Cuida apenas de estado, carga e navegação: o recorte vive em
/// [FiltroLotes] e a faixa do topo em [CabecalhoInsumoLotes].
class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final _service = LoteService();
  final _busca = TextEditingController();

  InsumoResponse? _insumo;
  List<LoteResponse> _lotes = [];
  FiltroLotes _filtro = const FiltroLotes();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _selecionarInsumo() async {
    final insumo = await LoteInsumoSeletor.abrir(context);
    if (insumo == null || !mounted) return;
    _busca.clear();
    setState(() {
      _insumo = insumo;
      _lotes = [];
      _filtro = const FiltroLotes();
    });
    await _carregar();
  }

  /// Recarrega os lotes do insumo escolhido.
  ///
  /// [mostrarCarregando] é falso no "puxar para atualizar": ali o próprio
  /// `RefreshIndicator` já dá o retorno visual.
  Future<void> _carregar({bool mostrarCarregando = true}) async {
    final insumo = _insumo;
    if (insumo?.id == null) return;
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await _service.listar(insumoId: insumo!.id!);
      if (mounted) {
        setState(() {
          _lotes = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao carregar lotes: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirDetalhes(LoteResponse lote) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LoteDetalhesPage(lote: lote, insumo: _insumo),
      ),
    );
    if (alterou == true) await _carregar();
  }

  Future<void> _abrirCriacao() async {
    final criado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LoteFormPage(insumoInicial: _insumo)),
    );
    if (criado == true) await _carregar();
  }

  void _limparFiltros() {
    _busca.clear();
    setState(() => _filtro = const FiltroLotes());
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final temInsumo = _insumo != null;
    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: temInsumo
          ? FloatingActionButton(
              onPressed: _abrirCriacao,
              backgroundColor: AppTema.primaria,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: temInsumo ? _corpoComInsumo() : _convitePorInsumo(),
    );
  }

  /// Estado inicial: sem insumo não há o que listar.
  Widget _convitePorInsumo() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppEstadoVazio(
        icone: Icons.calendar_month_outlined,
        titulo: 'Escolha um insumo',
        mensagem:
            'Os lotes são listados por insumo, em ordem de validade (FEFO).',
        rotuloBotao: 'Selecionar insumo',
        iconeBotao: Icons.search_rounded,
        aoTocarBotao: _selecionarInsumo,
      ),
    ),
  );

  Widget _corpoComInsumo() => Column(
    children: [
      CabecalhoInsumoLotes(insumo: _insumo!, aoTrocar: _selecionarInsumo),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: AppCampoBusca(
          controle: _busca,
          dica: 'Buscar por código ou insumo…',
          aoMudar: (valor) =>
              setState(() => _filtro = _filtro.copiarCom(texto: valor)),
        ),
      ),
      _chipsValidade(),
      const SizedBox(height: 8),
      Expanded(
        child: RefreshIndicator(
          color: AppTema.primaria,
          onRefresh: () => _carregar(mostrarCarregando: false),
          child: _lista(),
        ),
      ),
    ],
  );

  /// Chips de validade. Vencidos e 7 dias mostram o contador — são as duas
  /// janelas que exigem ação do operador.
  Widget _chipsValidade() => AppFileiraChips(
    chips: [
      for (final janela in JanelaValidade.values)
        AppChipFiltro(
          rotulo: _rotuloComContador(janela),
          selecionado: _filtro.janela == janela,
          aoTocar: () =>
              setState(() => _filtro = _filtro.copiarCom(janela: janela)),
        ),
    ],
  );

  String _rotuloComContador(JanelaValidade janela) {
    if (janela != JanelaValidade.vencidos &&
        janela != JanelaValidade.ate7Dias) {
      return janela.rotulo;
    }
    final total = _filtro.contar(_lotes, janela);
    return total == 0 ? janela.rotulo : '${janela.rotulo} · $total';
  }

  Widget _lista() {
    if (_carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 140), AppCarregando()],
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
    if (_lotes.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.calendar_month_outlined,
          titulo: 'Nenhum lote cadastrado',
          mensagem:
              'Este insumo ainda não tem lotes. Registre uma entrada em '
              'Movimentação de Estoque, ou crie um lote avulso para o '
              'inventário inicial.',
          rotuloBotao: 'Criar lote avulso',
          aoTocarBotao: _abrirCriacao,
        ),
      );
    }

    final filtrados = _filtro.aplicar(_lotes);
    if (filtrados.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Nada encontrado',
          mensagem: 'Nenhum lote corresponde à busca ou ao filtro.',
          rotuloBotao: 'Limpar filtros',
          iconeBotao: Icons.filter_alt_off_rounded,
          secundario: true,
          aoTocarBotao: _limparFiltros,
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => LoteCard(
        lote: filtrados[i],
        onTap: () => _abrirDetalhes(filtrados[i]),
      ),
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
    children: [filho],
  );
}
