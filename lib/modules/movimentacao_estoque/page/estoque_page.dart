import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_botao_icone.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/filtro_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/page/movimentacao_form_page.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/aba_historico.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/aba_saldos.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/abas_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/folha_filtros_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/tipo_filter_chips.dart';

/// Tela de estoque, em duas abas: histórico de movimentações e saldos por
/// insumo.
///
/// Esta classe cuida apenas de carregar os dados, guardar o filtro e a
/// busca, e orquestrar as abas. A aparência vive em `widgets/` e as regras
/// de filtragem em [FiltroEstoque].
class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage>
    with SingleTickerProviderStateMixin {
  final _service = MovimentacaoEstoqueService();
  final _controleBusca = TextEditingController();

  late final TabController _abas;

  List<Insumo> _insumos = [];
  List<MovimentacaoEstoque> _movimentacoes = [];
  bool _carregando = true;
  String _busca = '';
  int _abaAtual = 0;
  FiltroEstoque _filtro = const FiltroEstoque();

  @override
  void initState() {
    super.initState();
    // Registra a acao do "+" da barra inferior para esta aba.
    AcoesCriacao.registrar(TitulosAba.estoque, _abrirCadastro);
    _abas = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_abas.indexIsChanging) {
          setState(() => _abaAtual = _abas.index);
        }
      });
    _carregar();
  }

  @override
  void dispose() {
    _abas.dispose();
    _controleBusca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  /// Carrega os insumos e, para cada um, seu histórico.
  ///
  /// A API não expõe um endpoint de "todas as movimentações", então a tela
  /// consulta insumo a insumo. Uma falha isolada não derruba a carga — o
  /// insumo apenas fica sem histórico.
  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final brutos = await _service.listarInsumos(apenasAtivos: false);
      if (!mounted) return;
      final insumos = brutos
          .map((e) => Insumo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final movimentacoes = <MovimentacaoEstoque>[];
      for (final insumo in insumos) {
        if (insumo.id == null) continue;
        try {
          final lista = await _service.listarMovimentacoes(insumo.id!);
          movimentacoes.addAll(
            lista.map(
              (e) => MovimentacaoEstoque.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
        } catch (_) {
          // Segue com os demais insumos.
        }
      }

      if (!mounted) return;
      setState(() {
        _insumos = insumos;
        _movimentacoes = movimentacoes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar estoque: $e')));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<MovimentacaoEstoque> get _movimentacoesVisiveis =>
      _filtro.aplicar(_movimentacoes);

  List<Insumo> get _insumosVisiveis {
    final termo = _busca.trim().toLowerCase();
    if (termo.isEmpty) return _insumos;
    return _insumos.where((i) => i.nome.toLowerCase().contains(termo)).toList();
  }

  int get _totalAbaixoDoMinimo =>
      _insumos.where((i) => i.abaixoDoMinimo == true).length;

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirCadastro() async {
    final criou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MovimentacaoFormPage()),
    );
    if (criou == true) await _carregar();
  }

  Future<void> _abrirFiltros() async {
    final escolhido = await abrirFolhaFiltrosEstoque(
      context,
      filtroAtual: _filtro,
      insumos: _insumos,
    );
    if (escolhido != null) setState(() => _filtro = escolhido);
  }

  void _limparFiltros() => setState(() => _filtro = const FiltroEstoque());

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AbasEstoque(
              controlador: _abas,
              abaixoDoMinimo: _totalAbaixoDoMinimo,
            ),
            const SizedBox(height: 16),
            if (_abaAtual == 0) ...[
              _controlesDoHistorico(),
              const SizedBox(height: 6),
            ],
            if (_abaAtual == 1) ...[
              AppCampoBusca(
                controle: _controleBusca,
                dica: 'Buscar insumo...',
                margemHorizontal: 16,
                aoMudar: (valor) => setState(() => _busca = valor),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: RefreshIndicator(
                color: AppTema.primaria,
                onRefresh: _carregar,
                child: TabBarView(
                  controller: _abas,
                  children: [
                    AbaHistorico(
                      todas: _movimentacoes,
                      visiveis: _movimentacoesVisiveis,
                      insumos: _insumos,
                      filtro: _filtro,
                      carregando: _carregando,
                      aoRegistrar: _abrirCadastro,
                      aoLimparFiltros: _limparFiltros,
                    ),
                    AbaSaldos(
                      insumos: _insumosVisiveis,
                      buscaAtiva: _busca.trim().isNotEmpty,
                      carregando: _carregando,
                      aoRegistrarEntrada: _abrirCadastro,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chips de categoria + botão de filtros avançados, acima do histórico.
  Widget _controlesDoHistorico() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: TipoFilterChips(
            selectedFilter: _filtro.tipo,
            onFilterChanged: (tipo) =>
                setState(() => _filtro = _filtro.copiarCom(tipo: tipo)),
          ),
        ),
        const SizedBox(width: 12),
        AppBotaoIcone(
          icone: Icons.filter_alt_outlined,
          mostrarSelo: _filtro.temFiltroAvancado,
          aoTocar: _abrirFiltros,
          dicaAcessibilidade: 'Filtros',
        ),
      ],
    ),
  );
}
