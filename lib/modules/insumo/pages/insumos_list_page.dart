import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_card.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_search_field.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_sort_sheet.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_list_filter.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_filter_component.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_sort_options.dart';
import 'package:my_app_teste/modules/insumo/pages/insumo_form_page.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';
import 'package:my_app_teste/modules/insumo/components/empty_state_card.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_chips.dart';
import 'package:my_app_teste/modules/unidade_medida/service/unidade_medida_service.dart';

enum _LoadStatus {loading, ready, error}

class InsumosListPage extends StatefulWidget {
  final InsumoService? insumoService;
  final Future<List<UnidadeMedidaResponse>> Function()? listarUnidades;

  const InsumosListPage({
    super.key,
    this.insumoService,
    this.listarUnidades,
  });

  @override
  State<InsumosListPage> createState() => _InsumosListPageState();
}

class _InsumosListPageState extends State<InsumosListPage> {
  late final InsumoService _insumoService =
      widget.insumoService ?? InsumoService();
  late final Future<List<UnidadeMedidaResponse>> Function() _listarUnidades =
      widget.listarUnidades ?? listarUnidadesMedida;
  final TextEditingController _searchController = TextEditingController();

  List<InsumoResponse> _insumos = [];
  List<UnidadeMedidaResponse> unidadesMedidas = [];
  InsumosFilters _filter = InsumosFilters();
  String _search = '';
  String _sort = 'stock_asc';

  _LoadStatus _insumosStatus = _LoadStatus.loading;
  _LoadStatus _unidadeStatus = _LoadStatus.loading;
  String? _erroInsumos;
  String? _erroUnidades;

  @override
  void initState() {
    super.initState();
    _load();
    _loadUnidades();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Estado derivado
  // ---------------------------------------------------------------------------

  InsumoSortOption get _currentSortOption => insumoSortOptions.firstWhere(
        (o) => o.value == _sort,
        orElse: () => insumoSortOptions.first,
      );

  String get _sortLabel => _currentSortOption.label;
  bool get _hasActiveSearch => _search.trim().isNotEmpty;
  int get _totalAtivos => _insumos.where((i) => i.ativo == true).length;
  int get _abaixoDoMinimoCount =>
      _insumos.where((i) => i.abaixoDoMinimo == true).length;

  List<InsumoResponse> get _filtered {
    var list = List<InsumoResponse>.from(_insumos);

    if (_filter.unidadePadraoId != null) {
      list = list.where((insumo) {
        return insumo.unidadePadraoId == _filter.unidadePadraoId;
      }).toList();
    }

    if (_filter.abaixoDoMinimo == true) {
      list = list.where((insumo) {
        return insumo .abaixoDoMinimo == true;
      }).toList();
    }

    if (_filter.ativo != null) {
      list = list.where((insumo) {
        return insumo.ativo == _filter.ativo;
      }).toList();
    }

    if (_hasActiveSearch) {
      final query = _search.toLowerCase().trim();
      list = list.where((insumo) {
        final nome = (insumo.nome ?? '').toLowerCase();
        return nome.contains(query);
      }).toList();
    }

    list.sort(_currentSortOption.comparator);
    return list;
  }

  // ---------------------------------------------------------------------------
  // Carregamento e ações
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    _setLoadingInsumo();
    try {
      final lista = await _insumoService.listar(apenasAtivos: false);
      _setReadyInsumo(lista);
    } catch (e) {
      if(!mounted) return;
      _setErrorInsumo(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar insumos: $e')),
      );
    }
  }

  Future<void> _loadUnidades() async {
    _setLoadingUnidade();
    try {
      final unidades = await _listarUnidades();
      _setReadyUnidade(unidades);
    } catch (e) {
      if(!mounted) return;
      _setErrorUnidade(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar unidades de medida: $e')),
      );
    }
  }

  Future<void> _reload() async {
    await Future.wait([
      _load(),
      _loadUnidades(),
    ]);
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InsumoFormPage(
        insumoService: widget.insumoService,
        listarUnidades: widget.listarUnidades,)),
    );
    if (created == true) {
      await _reload();
    }
  }

  Future<void> _openEdit(InsumoResponse insumo) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InsumoFormPage(
        insumo: insumo,
        insumoId: insumo.id ,
        insumoService: widget.insumoService,
        listarUnidades: widget.listarUnidades,
        )),
    );
    if (updated == true) {
      await _reload();
    }
  }

  Future<bool> _confirmarExclusao(InsumoResponse insumo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation, size: 20),
            SizedBox(width: 10),
            Text(
              'Excluir insumo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir "${insumo.nome ?? ''}"? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _excluir(InsumoResponse insumo) async {
    if (insumo.id == null) return false;
    try {
      await _insumoService.excluir(insumo.id!);
      if (!mounted) return false;
      setState(() => _insumos.removeWhere((x) => x.id == insumo.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insumo "${insumo.nome ?? ''}" excluído.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _confirmarEExcluir(InsumoResponse insumo) async {
    final confirmou = await _confirmarExclusao(insumo);
    if (!confirmou) return false;
    return await _excluir(insumo);
  }

  Future<void> _openSortSheet() async {
    final selected = await InsumoSortSheet.show(context, selectedSort: _sort);
    if (selected == null || selected == _sort) return;
    setState(() => _sort = selected);
  }

  Future<void> _openFilterSheet() async {
    final result = await InsumoFilterComponent.show(
      context,
      initialFilter: _filter,
    );
    if (result == null) return;
    setState(() => _filter = result);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _search = '');
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatEstoque(double? valor, String? simbolo) {
    final v = valor ?? 0;
    final formatted = v.toStringAsFixed(3).replaceAll('.', ',');
    return '$formatted ${simbolo ?? ''}'.trim();
  }

  double? _percentualVsMinimo(InsumoResponse insumo) {
    final atual = insumo.estoqueAtual ?? 0;
    final min = insumo.estoqueMinimo ?? 0;
    if (min == 0) return null;
    return ((atual - min) / min) * 100;
  }

  Color _stockBarColor(InsumoResponse insumo) {
    if (insumo.abaixoDoMinimo == true) {
      final pct = _percentualVsMinimo(insumo) ?? 0;
      return pct < -30 ? Colors.red.shade400 : Colors.orange.shade400;
    }
    return Colors.green.shade500;
  }

  Color _accentForInsumo(InsumoResponse insumo) {
    final seed = (insumo.nome ?? '').isNotEmpty ? insumo.nome! : 'insumo';
    const palette = <Color>[
      Color(0xFFF8C39C),
      Color(0xFFF6C48A),
      Color(0xFFE7C7F3),
      Color(0xFFF3D0A3),
      Color(0xFFDCE7C1),
    ];
    return palette[seed.hashCode.abs() % palette.length];
  }

  IconData _iconForInsumo(InsumoResponse insumo) {
    final nome = (insumo.nome ?? '').toLowerCase();
    if (nome.contains('tomate') ||
        nome.contains('alface') ||
        nome.contains('cebola')) {
      return Icons.eco_rounded;
    }
    if (nome.contains('queijo') ||
        nome.contains('leite') ||
        nome.contains('mussarela')) {
      return Icons.icecream_rounded;
    }
    if (nome.contains('carne') ||
        nome.contains('picanha') ||
        nome.contains('frango')) {
      return Icons.set_meal_rounded;
    }
    if (nome.contains('vinho') ||
        nome.contains('cerveja') ||
        nome.contains('refri')) {
      return Icons.wine_bar_rounded;
    }
    if (nome.contains('macarrao') ||
        nome.contains('macarrão') ||
        nome.contains('arroz')) {
      return Icons.rice_bowl_rounded;
    }
    return Icons.inventory_2_rounded;
  }

  void _setStatusInsumos(_LoadStatus estado, {String? erro}){
    setState(() {
      _insumosStatus = estado;
      _erroInsumos = erro;
    });
  }

  void _setStatusUnidades(_LoadStatus estado, {String? erro}){
    setState(() {
      _unidadeStatus = estado;
      _erroUnidades = erro;
    });
  }

  void _setLoadingInsumo() {
    if(!mounted) return;
    _setStatusInsumos(_LoadStatus.loading);
  }

  void _setErrorInsumo(String erro) {
    if(!mounted) return;
    _setStatusInsumos(_LoadStatus.error, erro: erro.toString());
  }

  void _setReadyInsumo(List<InsumoResponse> insumos) {
    if(!mounted) return;
    setState(() {
      _insumos = insumos;
      _insumosStatus = _LoadStatus.ready;
    });
  } 

  void _setLoadingUnidade() {
    if(!mounted) return;
    _setStatusUnidades(_LoadStatus.loading);
  }

  void _setErrorUnidade(String erro) {
    if(!mounted) return;
    _setStatusUnidades(_LoadStatus.error, erro: erro.toString());
  }

  void _setReadyUnidade(List<UnidadeMedidaResponse> unidades) {
    if(!mounted) return;
    setState(() {
      unidadesMedidas = unidades;
      _unidadeStatus = _LoadStatus.ready;
    });
  }

  // ---------------------------------------------------------------------------
  // Builders de UI
  // ---------------------------------------------------------------------------

  List<Object> _construirItensComCabecalhos(
    List<InsumoResponse> lista,
    InsumoSortOption option,
  ) {
    if (option.grouper == null) {
      return List<Object>.from(lista);
    }

    final grupos = <String, List<InsumoResponse>>{};
    for (final insumo in lista) {
      final chave = option.grouper!(insumo) ?? 'Outros';
      grupos.putIfAbsent(chave, () => []).add(insumo);
    }

    final chavesOrdenadas = grupos.keys.toList();
    if (option.groupOrder != null) {
      chavesOrdenadas.sort(option.groupOrder!);
    } else {
      chavesOrdenadas.sort();
    }

    final items = <Object>[];
    for (final chave in chavesOrdenadas) {
      final itensDoGrupo = grupos[chave]!;
      items.add(_SectionHeaderData(chave, itensDoGrupo.length));
      items.addAll(itensDoGrupo);
    }
    return items;
  }

  Widget _buildSectionHeader(String label, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
      child: Text(
        '$label · $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildSummaryStrip() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        '$_totalAtivos ativos · $_abaixoDoMinimoCount abaixo do mínimo',
        style: TextStyle(
          fontSize: 13,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Spacer(),
          if (_hasActiveSearch)
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Limpar busca'),
            ),
          TextButton.icon(
            onPressed: _openSortSheet,
            icon: const Icon(Icons.sort_rounded, size: 18),
            style: TextButton.styleFrom(
              foregroundColor: AppTema.primaria, // Changes the text and icon color
            ),
            label: Text(_sortLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildInsumoCard(InsumoResponse insumo) {
    return InsumoCard(
      insumo: insumo,
      icon: _iconForInsumo(insumo),
      accentColor: _accentForInsumo(insumo),
      stockBarColor: _stockBarColor(insumo),
      stockText: _formatEstoque(
        insumo.estoqueAtual,
        insumo.unidadePadraoSimbolo,
      ),
      percentVsMinimo: _percentualVsMinimo(insumo),
      onTap: () => _openEdit(insumo),
      onConfirmDelete: () => _confirmarEExcluir(insumo),
    );
  }

  Widget _buildList() {
    if (_insumosStatus == _LoadStatus.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 140),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_insumosStatus == _LoadStatus.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
        children: [
          const SizedBox(height: 24),
          EmptyStateCard(
            title: 'Houve um erro no carregamento de insumos.',
            subtitle:
                'Por favor, tente novamente.',
            icon: Icons.error_outline,
            buttonLabel: 'Recarregar',
            onPressed: _reload,
          ),
        ],
      );
    }

    if (_insumos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
        children: [
          const SizedBox(height: 24),
          EmptyStateCard(
            title: 'Sem insumos por aqui',
            subtitle:
                'Cadastre seu primeiro insumo pra começar a controlar o estoque.',
            icon: Icons.inventory_2_rounded,
            buttonLabel: 'Cadastrar insumo',
            onPressed: _openCreate,
          ),
        ],
      );
    }

    if (_filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
        children: [
          const SizedBox(height: 24),
          EmptyStateCard(
            title: 'Nenhum insumo encontrado',
            subtitle:
                'Tente um termo diferente ou limpe a busca para ver todos.',
            icon: Icons.search_off_rounded,
            buttonLabel: 'Limpar busca',
            onPressed: _clearSearch,
            secondary: true,
          ),
        ],
      );
    }

    final items = _construirItensComCabecalhos(_filtered, _currentSortOption);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is _SectionHeaderData) {
          return _buildSectionHeader(item.label, item.count);
        }
        return _buildInsumoCard(item as InsumoResponse);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        foregroundColor: Colors.white,
        backgroundColor: AppTema.primaria,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildSummaryStrip(),
          const SizedBox(height: 4),
          Row(
            children: [
            Expanded(
              child: InsumoSearchField(
                controller: _searchController,
                search: _search,
                onChanged: (value) => setState(() => _search = value),
                onClear: _clearSearch,
              ),
            ),
            IconButton(
              onPressed: _openFilterSheet,
              icon: const Icon(Icons.filter_alt_outlined),
              iconSize: 35,
            ),
            ]
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: switch (_unidadeStatus) {
                    
                    _LoadStatus.loading => const SizedBox(
                      height: 32,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),

                    _LoadStatus.error => TextButton.icon(
                      onPressed: _loadUnidades,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Recarregar unidades'),
                    ),

                    _LoadStatus.ready => UnidadesMedidasChips(
                    unidadesMedidas: unidadesMedidas,
                    selectedUnidadeMedidaId: _filter.unidadePadraoId,
                    onClear: () => setState(() {
                      _filter = _filter.copyWith(clearUnidadePadraoId: true);
                    }),
                    onSelected: (unidade) => setState(() {
                      _filter = _filter.copyWith(unidadePadraoId: unidade.id);
                    }),
                  ),
              }),],
          ),
          const SizedBox(height: 4),
          _buildResultsHeader(),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderData {
  final String label;
  final int count;
  _SectionHeaderData(this.label, this.count);
}