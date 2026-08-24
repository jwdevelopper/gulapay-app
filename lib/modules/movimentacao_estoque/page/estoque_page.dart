import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_widgets.dart';

import 'movimentacao_form_page.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

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
  int? _filterInsumoId;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  bool get _hasAdvancedFilters =>
      _filterInsumoId != null || _filterDateFrom != null || _filterDateTo != null;

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

    if (_filterInsumoId != null) {
      list = list.where((m) => m.insumoId == _filterInsumoId).toList();
    }

    if (_filterDateFrom != null || _filterDateTo != null) {
      list = list.where((m) {
        if (m.dataHora == null) return false;
        final dt = DateTime.tryParse(m.dataHora!);
        if (dt == null) return false;
        if (_filterDateFrom != null && dt.isBefore(_filterDateFrom!)) return false;
        if (_filterDateTo != null && dt.isAfter(_filterDateTo!)) return false;
        return true;
      }).toList();
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

  Future<void> _openFiltersSheet() async {
    String tempFilter = _selectedFilter;
    int? tempInsumoId = _filterInsumoId;
    DateTime? tempFrom = _filterDateFrom;
    DateTime? tempTo = _filterDateTo;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          String fmtDate(DateTime? d) {
            if (d == null) return 'Selecionar';
            return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
          }

        Future<void> pickDate(bool isFrom) async {
    final initial = isFrom ? (tempFrom ?? DateTime.now()) : (tempTo ?? DateTime.now());
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: EstoquePalette.primary, // Cor do cabeçalho e do dia selecionado
              onPrimary: Colors.white, // Cor do texto dentro da cor primária
              onSurface: EstoquePalette.text, // Cor dos números dos dias
              surface: EstoquePalette.surface, // Cor de fundo do calendário
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: EstoquePalette.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
  );
        
    if (picked != null) {
      setSheet(() {
        if (isFrom) {
          tempFrom = DateTime(picked.year, picked.month, picked.day);
        } else {
          tempTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

          Widget tipoChip(String value, String label) {
            final selected = tempFilter == value;
            return InkWell(
              onTap: () => setSheet(() => tempFilter = value),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? EstoquePalette.primary : EstoquePalette.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : EstoquePalette.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          return FractionallySizedBox(
            heightFactor: 0.82,
            child: Container(
              decoration: const BoxDecoration(
                color: EstoquePalette.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: EstoquePalette.borderSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filtros',
                              style: TextStyle(
                                color: EstoquePalette.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                            color: EstoquePalette.text,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: [
                            const Text(
                              'TIPO',
                              style: TextStyle(
                                color: EstoquePalette.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                tipoChip('TUDO', 'Tudo'),
                                tipoChip('ENTRADAS', 'Entradas'),
                                tipoChip('SAIDAS', 'Saídas'),
                                tipoChip('AJUSTES', 'Ajustes'),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'INSUMO',
                              style: TextStyle(
                                color: EstoquePalette.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<int?>(
                              initialValue: tempInsumoId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: EstoquePalette.surfaceAlt,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: EstoquePalette.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: EstoquePalette.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: EstoquePalette.primary),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Todos os insumos'),
                                ),
                                ..._insumos.where((i) => i.id != null).map(
                                      (i) => DropdownMenuItem<int?>(
                                        value: i.id,
                                        child: Text(i.nome, overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                              ],
                              onChanged: (value) => setSheet(() => tempInsumoId = value),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'PERÍODO',
                              style: TextStyle(
                                color: EstoquePalette.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _DateBox(
                                    label: 'De',
                                    value: fmtDate(tempFrom),
                                    onTap: () => pickDate(true),
                                    onClear: tempFrom == null ? null : () => setSheet(() => tempFrom = null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _DateBox(
                                    label: 'Até',
                                    value: fmtDate(tempTo),
                                    onTap: () => pickDate(false),
                                    onClear: tempTo == null ? null : () => setSheet(() => tempTo = null),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheet(() {
                                  tempFilter = 'TUDO';
                                  tempInsumoId = null;
                                  tempFrom = null;
                                  tempTo = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: EstoquePalette.text,
                                backgroundColor: EstoquePalette.surfaceAlt,
                                side: const BorderSide(color: EstoquePalette.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Limpar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = tempFilter;
                                  _filterInsumoId = tempInsumoId;
                                  _filterDateFrom = tempFrom;
                                  _filterDateTo = tempTo;
                                });
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: EstoquePalette.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
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
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
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

    if (movs.isEmpty) {
      String message;
      if (_filterInsumoId != null) {
        final insumo = _insumos.firstWhere(
          (i) => i.id == _filterInsumoId,
          orElse: () => Insumo(nome: ''),
        );
        final nome = insumo.nome.isEmpty ? 'Este produto' : insumo.nome;
        message = '$nome não tem movimentação de estoque.';
      } else if (_filterDateFrom != null || _filterDateTo != null) {
        message = 'Nenhuma movimentação encontrada no período selecionado.';
      } else {
        message = 'Nenhuma movimentação encontrada com os filtros aplicados.';
      }
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EstoquePalette.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: EstoquePalette.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: EstoquePalette.inputFill,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.inbox_outlined,
                    color: EstoquePalette.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: EstoquePalette.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'TUDO';
                      _filterInsumoId = null;
                      _filterDateFrom = null;
                      _filterDateTo = null;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Limpar filtros'),
                  style: TextButton.styleFrom(foregroundColor: EstoquePalette.primary),
                ),
              ],
            ),
          ),
        ],
      );
    }

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16), 
            _buildTabBar(),
            const SizedBox(height: 16),

            if (_tabIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TipoFilterChips(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (filter) =>
                            setState(() => _selectedFilter = filter),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeaderIconButton(
                      icon: Icons.filter_alt_outlined,
                      showBadge: _hasAdvancedFilters,
                      onTap: _openFiltersSheet,
                    ),
                  ],
                ),
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
  final bool showBadge;

  const _HeaderIconButton({required this.icon, this.onTap, this.showBadge = false});

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
          child: Stack(
            children: [
              Center(child: Icon(icon, color: EstoquePalette.text, size: 22)),
              if (showBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: EstoquePalette.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: EstoquePalette.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateBox({required this.label, required this.value, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: EstoquePalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: EstoquePalette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: EstoquePalette.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 16, color: EstoquePalette.textMuted),
                ),
              )
            else
              const Icon(Icons.calendar_today_rounded, size: 16, color: EstoquePalette.textMuted),
          ],
        ),
      ),
    );
  }
}