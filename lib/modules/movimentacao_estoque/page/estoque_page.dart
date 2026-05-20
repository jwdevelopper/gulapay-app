import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_widgets.dart';
import 'package:my_app_teste/shared/bottom_bar/bottom_bar.dart';

import 'movimentacao_form_page.dart';

class EstoquePage extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const EstoquePage({super.key, this.onOpenDrawer});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

const List<BottomBarItem> _bottomBarItems = [
  BottomBarItem(label: 'Inicio', icon: Icons.home_outlined),
  BottomBarItem(label: 'Mesas', icon: Icons.grid_view_rounded),
  BottomBarItem(label: 'Produtos', icon: Icons.inventory_2_outlined),
  BottomBarItem(label: 'Clientes', icon: Icons.people_alt_outlined),
  BottomBarItem(label: 'Mais', icon: Icons.more_horiz_rounded),
];

class _EstoquePageState extends State<EstoquePage>
    with SingleTickerProviderStateMixin {
  final MovimentacaoEstoqueService _service = MovimentacaoEstoqueService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  List<Insumo> _insumos = [];
  List<MovimentacaoEstoque> _allMovimentacoes = [];
  bool _loading = true;
  String _selectedFilter = 'TUDO';
  String _search = '';
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final insumoList = await _service.listarInsumos(apenasAtivos: false);
      if (!mounted) return;
      final insumos = insumoList
          .map((item) => Insumo.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      // Load all movimentacoes for all insumos
      final allMovs = <MovimentacaoEstoque>[];
      for (final insumo in insumos) {
        if (insumo.id != null) {
          try {
            final movList = await _service.listarMovimentacoes(insumo.id!);
            allMovs.addAll(
              movList.map((item) => MovimentacaoEstoque.fromJson(
                  Map<String, dynamic>.from(item as Map))),
            );
          } catch (_) {
            // Continue even if one insumo fails
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _insumos = insumos;
        _allMovimentacoes = allMovs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estoque: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MovimentacaoEstoque> get _filteredMovimentacoes {
    var list = List<MovimentacaoEstoque>.from(_allMovimentacoes);

    switch (_selectedFilter) {
      case 'ENTRADAS':
        list = list.where((m) => m.isEntrada).toList();
        break;
      case 'SAIDAS':
        list = list.where((m) => m.isSaida).toList();
        break;
      case 'AJUSTES':
        list = list.where((m) => m.isAjuste).toList();
        break;
    }

    // Sort by date, most recent first
    list.sort((a, b) {
      final dateA = a.dataHora ?? '';
      final dateB = b.dataHora ?? '';
      return dateB.compareTo(dateA);
    });

    return list;
  }

  List<Insumo> get _insumosAbaixoMinimo =>
      _insumos.where((i) => i.abaixoDoMinimo == true).toList();

  List<Insumo> get _insumosEmEstoque =>
      _insumos.where((i) => i.abaixoDoMinimo != true).toList();

  List<Insumo> get _filteredInsumos {
    if (_search.trim().isEmpty) return _insumos;
    final query = _search.toLowerCase().trim();
    return _insumos.where((i) => i.nome.toLowerCase().contains(query)).toList();
  }

  int get _totalMovimentacoes => _allMovimentacoes.length;

  String get _screenSubtitle {
    if (_loading) return 'Carregando...';
    if (_insumos.isEmpty) return 'Comece por aqui';
    if (_tabIndex == 1) {
      final abaixo = _insumosAbaixoMinimo.length;
      if (abaixo > 0) return '${_insumos.length} insumos · $abaixo abaixo do mínimo';
      return '${_insumos.length} insumos';
    }
    return '$_totalMovimentacoes movimentações · ${_insumos.length} insumos';
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MovimentacaoFormPage()),
    );
    if (created == true) {
      await _loadData();
    }
  }

  String _formatDateHeader(String? dataHora) {
    if (dataHora == null) return '';
    try {
      final dt = DateTime.parse(dataHora);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(date).inDays;

      if (diff == 0) return 'HOJE';
      if (diff == 1) return 'ONTEM';

      final months = [
        '', 'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
        'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
      ];
      if (dt.year == now.year) {
        return '${dt.day} ${months[dt.month]}';
      }
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatTime(String? dataHora) {
    if (dataHora == null) return '';
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _dateKeyFor(String? dataHora) {
    if (dataHora == null) return '';
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  // ──── Header ────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estoque',
                  style: TextStyle(
                    color: EstoquePalette.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _screenSubtitle,
                  style: const TextStyle(
                    color: EstoquePalette.textMuted,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──── Tab bar ────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: EstoquePalette.borderSoft, width: 1.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: EstoquePalette.primary,
        unselectedLabelColor: EstoquePalette.textMuted,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        indicatorColor: EstoquePalette.primary,
        indicatorWeight: 2.5,
        tabs: [
          const Tab(text: 'Histórico'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Saldos'),
                if (_insumosAbaixoMinimo.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: EstoquePalette.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_insumosAbaixoMinimo.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──── Histórico tab ────

  Widget _buildHistoricoTab() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: EstoquePalette.primary),
      );
    }

    if (_allMovimentacoes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
        children: [
          EstoqueEmptyState(
            title: 'Sem movimentações ainda',
            subtitle:
                'Registre uma entrada por compra para começar a controlar o estoque do seu restaurante.',
            buttonLabel: 'Registrar movimentação',
            onPressed: _openCreate,
            tipText:
                'Antes da primeira movimentação, cadastre seus insumos e unidades de medida em Cadastros > Estoque.',
          ),
        ],
      );
    }

    final movs = _filteredMovimentacoes;

    // Group by date
    final grouped = <String, List<MovimentacaoEstoque>>{};
    for (final mov in movs) {
      final key = _dateKeyFor(mov.dataHora);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(mov);
    }

    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final dayMovs = grouped[dateKey]!;
        final header =
            _formatDateHeader(dayMovs.first.dataHora);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                header,
                style: const TextStyle(
                  color: EstoquePalette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...dayMovs.map((mov) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MovimentacaoCard(
                  insumoNome: mov.insumoNome ?? 'Insumo #${mov.insumoId}',
                  tipo: mov.tipo ?? '',
                  quantidade: mov.quantidade,
                  unidadeSimbolo: mov.unidadeSimbolo ?? mov.unidadePadraoSimbolo,
                  detalhes: mov.justificativa,
                  hora: _formatTime(mov.dataHora),
                  responsavel: mov.responsavel,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ──── Saldos tab ────

  Widget _buildSaldosTab() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: EstoquePalette.primary),
      );
    }

    final abaixo = _search.isEmpty
        ? _insumosAbaixoMinimo
        : _filteredInsumos.where((i) => i.abaixoDoMinimo == true).toList();
    final emEstoque = _search.isEmpty
        ? _insumosEmEstoque
        : _filteredInsumos.where((i) => i.abaixoDoMinimo != true).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
      children: [
        // Alert banner
        if (abaixo.isNotEmpty && _search.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EstoquePalette.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EstoquePalette.warningBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: EstoquePalette.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${abaixo.length} ${abaixo.length == 1 ? 'insumo abaixo' : 'insumos abaixo'} do estoque mínimo.\nToque para registrar entrada por compra.',
                    style: const TextStyle(
                      color: EstoquePalette.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Abaixo do mínimo section
        if (abaixo.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'ABAIXO DO MÍNIMO',
              style: TextStyle(
                color: EstoquePalette.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...abaixo.map((insumo) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InsumoSaldoCard(
                  nome: insumo.nome,
                  estoqueMinimo: insumo.estoqueMinimo,
                  estoqueAtual: insumo.estoqueAtual,
                  unidadeSimbolo: insumo.unidadePadraoSimbolo,
                  percentAbaixo: insumo.percentAbaixo,
                  onTap: () => _openCreate(),
                ),
              )),
          const SizedBox(height: 8),
        ],

        // Em estoque section
        if (emEstoque.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'EM ESTOQUE',
              style: TextStyle(
                color: EstoquePalette.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...emEstoque.map((insumo) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InsumoSaldoCard(
                  nome: insumo.nome,
                  estoqueMinimo: insumo.estoqueMinimo,
                  estoqueAtual: insumo.estoqueAtual,
                  unidadeSimbolo: insumo.unidadePadraoSimbolo,
                  percentAbaixo: insumo.percentAbaixo,
                ),
              )),
        ],
      ],
    );
  }

  // ──── Search field (for Saldos tab) ────

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: EstoquePalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08A86D37),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          style: const TextStyle(
            color: EstoquePalette.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: EstoquePalette.textMuted,
            ),
            hintText: 'Buscar insumo...',
            hintStyle: const TextStyle(color: EstoquePalette.textMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: _search.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _search = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstoquePalette.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: EstoquePalette.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomBar(
        items: _bottomBarItems,
        selectedIndex: 2,
        onTap: (_) {},
        backgroundColor: EstoquePalette.surface,
        borderColor: EstoquePalette.borderSoft,
        activeColor: EstoquePalette.primary,
        inactiveColor: EstoquePalette.textMuted,
        activeIndicatorColor: EstoquePalette.warningBg,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            const SizedBox(height: 10),

            // Tab-specific controls
            if (_tabIndex == 0) ...[
              TipoFilterChips(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) =>
                    setState(() => _selectedFilter = filter),
              ),
              const SizedBox(height: 6),
            ],
            if (_tabIndex == 1) ...[
              _buildSearchField(),
              const SizedBox(height: 10),
            ],

            Expanded(
              child: RefreshIndicator(
                color: EstoquePalette.primary,
                onRefresh: _loadData,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHistoricoTab(),
                    _buildSaldosTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EstoquePalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: EstoquePalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EstoquePalette.border),
          ),
          child: Icon(icon, color: EstoquePalette.text, size: 22),
        ),
      ),
    );
  }
}
