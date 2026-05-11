import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';

import 'produto_form_page.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _WarmPalette {
  static const background = Color(0xFFFCF6EC);
  static const surface = Color(0xFFFFF9F1);
  static const surfaceAlt = Color(0xFFFFFDF9);
  static const primary = Color(0xFFF07330);
  static const primaryPressed = Color(0xFFE85F1E);
  static const text = Color(0xFF3D261A);
  static const textMuted = Color(0xFFA06E4E);
  static const border = Color(0xFFE8D8C2);
  static const borderSoft = Color(0xFFF0E3D0);
  static const inputFill = Color(0xFFFFF4E8);
  static const warningBg = Color(0xFFFCEEDC);
  static const shadow = Color(0x1A9C5A1E);
}

class _SortOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;

  const _SortOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class _BottomNavItem {
  final String label;
  final IconData icon;

  const _BottomNavItem({required this.label, required this.icon});
}

const List<_SortOption> _sortOptions = [
  _SortOption(
    value: 'featured',
    label: 'Mais vendidos',
    subtitle: 'Ordem padrão da lista',
    icon: Icons.local_fire_department_rounded,
  ),
  _SortOption(
    value: 'price_asc',
    label: 'Preço crescente',
    subtitle: 'Do menor para o maior',
    icon: Icons.arrow_upward_rounded,
  ),
  _SortOption(
    value: 'price_desc',
    label: 'Preço decrescente',
    subtitle: 'Do maior para o menor',
    icon: Icons.arrow_downward_rounded,
  ),
  _SortOption(
    value: 'name_asc',
    label: 'Nome A-Z',
    subtitle: 'Alfabética crescente',
    icon: Icons.sort_by_alpha_rounded,
  ),
  _SortOption(
    value: 'name_desc',
    label: 'Nome Z-A',
    subtitle: 'Alfabética decrescente',
    icon: Icons.sort_by_alpha_rounded,
  ),
];

const List<_BottomNavItem> _bottomNavItems = [
  _BottomNavItem(label: 'Início', icon: Icons.home_outlined),
  _BottomNavItem(label: 'Mesas', icon: Icons.grid_view_rounded),
  _BottomNavItem(label: 'Produtos', icon: Icons.inventory_2_outlined),
  _BottomNavItem(label: 'Clientes', icon: Icons.people_alt_outlined),
  _BottomNavItem(label: 'Mais', icon: Icons.more_horiz_rounded),
];

class _ProdutosPageState extends State<ProdutosPage> {
  final ProdutoService _service = ProdutoService();
  final TextEditingController _searchController = TextEditingController();

  List<Produto> _produtos = [];
  List<Categoria> _categorias = [];
  int? _selectedCategoriaId;
  bool _loading = true;
  String _search = '';
  String _sort = 'featured';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Categoria? get _selectedCategoria {
    if (_selectedCategoriaId == null) return null;
    for (final categoria in _categorias) {
      if (categoria.id == _selectedCategoriaId) return categoria;
    }
    return null;
  }

  String get _screenTitle => _selectedCategoria?.nome.isNotEmpty == true
      ? _selectedCategoria!.nome
      : 'Produtos';

  String get _screenSubtitle {
    if (_loading) return 'Carregando produtos...';
    if (_selectedCategoria != null)
      return '${_filtered.length} itens • filtro ativo';
    if (_produtos.isEmpty) return 'Comece a cadastrar';
    return '${_produtos.length} itens • ${_categorias.length} categorias';
  }

  String get _sortLabel => _sortOptions
      .firstWhere(
        (option) => option.value == _sort,
        orElse: () => _sortOptions.first,
      )
      .label;

  Future<void> _loadCategories() async {
    try {
      final lista = await CategoriaService().listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() {
        _categorias = lista;
      });
    } catch (_) {
      // The page can still function if categories fail to load.
    }
  }

  Future<void> _load({int? categoriaId}) async {
    if (mounted) {
      setState(() => _loading = true);
    }
    try {
      final lista = await _service.listar(
        apenasAtivos: false,
        categoriaId: categoriaId ?? _selectedCategoriaId,
      );
      if (!mounted) return;
      setState(() {
        _produtos = lista
            .map((e) => Produto.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reload() async {
    await _loadCategories();
    await _load();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProdutoFormPage()),
    );
    if (created == true) {
      await _load();
    }
  }

  Future<void> _openEdit(Produto produto) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: produto)),
    );
    if (changed == true) {
      await _load();
    }
  }

  Future<void> _delete(Produto produto) async {
    if (produto.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _WarmPalette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Excluir produto'),
          content: const Text('Deseja excluir este produto?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    try {
      await _service.excluirProduto(produto.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produto excluído')));
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  Future<void> _openSortSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.56,
          child: Container(
            decoration: const BoxDecoration(
              color: _WarmPalette.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _WarmPalette.borderSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ordenar produtos',
                            style: TextStyle(
                              color: _WarmPalette.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                          color: _WarmPalette.text,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _sortOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final option = _sortOptions[index];
                          final selected = option.value == _sort;
                          return InkWell(
                            onTap: () {
                              setState(() => _sort = option.value);
                              Navigator.pop(sheetContext);
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? _WarmPalette.warningBg
                                    : _WarmPalette.surfaceAlt,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected
                                      ? _WarmPalette.primary
                                      : _WarmPalette.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? _WarmPalette.primary
                                          : _WarmPalette.inputFill,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: selected
                                          ? Colors.white
                                          : _WarmPalette.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.label,
                                          style: const TextStyle(
                                            color: _WarmPalette.text,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.subtitle,
                                          style: const TextStyle(
                                            color: _WarmPalette.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.check_rounded,
                                      color: _WarmPalette.primaryPressed,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Produto> get _filtered {
    var list = List<Produto>.from(_produtos);
    if (_selectedCategoriaId != null) {
      list = list
          .where((produto) => produto.categoriaId == _selectedCategoriaId)
          .toList();
    }
    if (_search.trim().isNotEmpty) {
      final query = _search.toLowerCase().trim();
      list = list.where((produto) {
        final nome = produto.nome.toLowerCase();
        final descricao = (produto.descricao ?? '').toLowerCase();
        final categoriaNome = _categoriaNome(produto.categoriaId).toLowerCase();
        return nome.contains(query) ||
            descricao.contains(query) ||
            categoriaNome.contains(query);
      }).toList();
    }
    switch (_sort) {
      case 'price_asc':
        list.sort((a, b) => (a.preco ?? 0).compareTo(b.preco ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.preco ?? 0).compareTo(a.preco ?? 0));
        break;
      case 'name_asc':
        list.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case 'name_desc':
        list.sort(
          (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
        );
        break;
      case 'featured':
      default:
        break;
    }
    return list;
  }

  String _categoriaNome(int? categoriaId) {
    return _categorias
        .firstWhere(
          (categoria) => categoria.id == categoriaId,
          orElse: () => Categoria(id: 0, nome: ''),
        )
        .nome;
  }

  String _priceText(double? value) {
    final price = value ?? 0;
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  IconData _iconForCategoryName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('beb')) return Icons.local_bar_rounded;
    if (lower.contains('sob')) return Icons.cake_rounded;
    if (lower.contains('entr')) return Icons.ramen_dining_rounded;
    if (lower.contains('por')) return Icons.lunch_dining_rounded;
    if (lower.contains('prato') || lower.contains('principal'))
      return Icons.dinner_dining_rounded;
    return Icons.restaurant_rounded;
  }

  IconData _iconForProduct(Produto produto) {
    final tipo = (produto.tipoProduto ?? '').toUpperCase();
    final categoria = _categoriaNome(produto.categoriaId).toLowerCase();
    if (tipo.contains('BEBIDA') || categoria.contains('beb'))
      return Icons.local_bar_rounded;
    if (tipo.contains('SOBREMESA') || categoria.contains('sob'))
      return Icons.cake_rounded;
    if (tipo.contains('PORCAO') || categoria.contains('por'))
      return Icons.lunch_dining_rounded;
    if (tipo.contains('PRATO') ||
        categoria.contains('prato') ||
        categoria.contains('principal'))
      return Icons.dinner_dining_rounded;
    return Icons.restaurant_rounded;
  }

  Color _accentForProduct(Produto produto) {
    final seed = _categoriaNome(produto.categoriaId).isNotEmpty
        ? _categoriaNome(produto.categoriaId)
        : produto.nome;
    final palette = <Color>[
      const Color(0xFFF8C39C),
      const Color(0xFFF6C48A),
      const Color(0xFFE7C7F3),
      const Color(0xFFF3D0A3),
      const Color(0xFFDCE7C1),
    ];
    return palette[seed.hashCode.abs() % palette.length];
  }

  Color _sectorColor(String? sector) {
    final normalized = (sector ?? '').toUpperCase();
    if (normalized.contains('BAR')) return const Color(0xFFB182D1);
    if (normalized.contains('CAIXA')) return const Color(0xFF8FB37A);
    return const Color(0xFFDA8F56);
  }

  String _friendlySector(String? value) {
    switch (value) {
      case 'COZINHA':
        return 'Cozinha';
      case 'BAR':
        return 'Bar';
      case 'CAIXA':
        return 'Caixa';
      default:
        return value?.isNotEmpty == true ? value! : '-';
    }
  }

  void _clearCategoryFilter() {
    if (_selectedCategoriaId == null) return;
    setState(() {
      _selectedCategoriaId = null;
    });
    _load();
  }

  void _clearSearchAndFilter() {
    setState(() {
      _selectedCategoriaId = null;
      _search = '';
      _searchController.clear();
    });
    _load();
  }

  Widget _buildTopHeader() {
    final hasCategoryFilter = _selectedCategoriaId != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderIconButton(
              icon: hasCategoryFilter ? Icons.arrow_back_rounded : Icons.menu_rounded,
              onTap: hasCategoryFilter ? _clearCategoryFilter : () {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _screenTitle,
                  style: const TextStyle(
                    color: _WarmPalette.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _screenSubtitle,
                  style: const TextStyle(
                    color: _WarmPalette.textMuted,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: hasCategoryFilter ? Icons.close_rounded : Icons.filter_alt_outlined,
            onTap: hasCategoryFilter ? _clearSearchAndFilter : _openSortSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _WarmPalette.surfaceAlt, borderRadius: BorderRadius.circular(16), border: Border.all(color: _WarmPalette.border), boxShadow: const [ BoxShadow(color: Color(0x08A86D37), blurRadius: 12, offset: Offset(0, 4),), ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          style: const TextStyle(
            color: _WarmPalette.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: _WarmPalette.textMuted,
            ),
            hintText: 'Buscar produto...',
            hintStyle: const TextStyle(color: _WarmPalette.textMuted),
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

  Widget _buildCategoryChips() {
    final chips = <Widget>[
      _CategoryChip(
        label: 'Todas',
        icon: Icons.grid_view_rounded,
        selected: _selectedCategoriaId == null,
        onTap: _clearCategoryFilter,
      ),
      ..._categorias.map(
        (categoria) => _CategoryChip(
          label: categoria.nome,
          icon: _iconForCategoryName(categoria.nome),
          selected: _selectedCategoriaId == categoria.id,
          onTap: () {
            if (_selectedCategoriaId == categoria.id) {
              _clearCategoryFilter();
              return;
            }
            setState(() {
              _selectedCategoriaId = categoria.id;
            });
            _load(categoriaId: categoria.id);
          },
        ),
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: chips.length,
        itemBuilder: (context, index) => chips[index],
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _filtered.isEmpty && _produtos.isNotEmpty
                  ? '0 resultados'
                  : '${_filtered.length} produtos',
              style: const TextStyle(
                color: _WarmPalette.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: _openSortSheet,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: _WarmPalette.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortLabel,
                    style: const TextStyle(
                      color: _WarmPalette.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool secondary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _WarmPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _WarmPalette.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: _WarmPalette.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _WarmPalette.inputFill,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: _WarmPalette.primary, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _WarmPalette.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _WarmPalette.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: secondary
                ? OutlinedButton.icon(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _WarmPalette.text,
                      side: const BorderSide(color: _WarmPalette.border),
                      backgroundColor: _WarmPalette.surfaceAlt,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: Text(buttonLabel),
                  )
                : ElevatedButton.icon(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _WarmPalette.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _WarmPalette.primaryPressed.withOpacity(
                        0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Produto produto) {
    final categoriaNome = _categoriaNome(produto.categoriaId);
    final descricao = (produto.descricao ?? '').trim();
    final subtitleParts = <String>[];
    if (categoriaNome.isNotEmpty) subtitleParts.add(categoriaNome);
    if (descricao.isNotEmpty) subtitleParts.add(descricao);
    final subtitle = subtitleParts.join(' • ');

    return _ProductCard(
      onTap: () => _openEdit(produto),
      onLongPress: null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _accentForProduct(produto).withOpacity(0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _iconForProduct(produto),
              color: _WarmPalette.text,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    color: _WarmPalette.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _WarmPalette.textMuted,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProductTag(
                      label: _friendlySector(
                        produto.setorProducao,
                      ).toUpperCase(),
                      color: _sectorColor(produto.setorProducao),
                    ),
                    if (categoriaNome.isNotEmpty)
                      _ProductTag(
                        label: categoriaNome,
                        color: _WarmPalette.primary,
                        filled: false,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _priceText(produto.preco),
                style: const TextStyle(
                  color: _WarmPalette.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              PopupMenuButton<String>(
                tooltip: 'Ações do produto',
                padding: EdgeInsets.zero,
                offset: const Offset(0, 8),
                color: _WarmPalette.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _WarmPalette.borderSoft),
                ),
                constraints: const BoxConstraints(minWidth: 176),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _openEdit(produto);
                      break;
                    case 'delete':
                      _delete(produto);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: _WarmPalette.text,
                        ),
                        SizedBox(width: 12),
                        Text('Editar produto'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: _WarmPalette.primaryPressed,
                        ),
                        SizedBox(width: 12),
                        Text('Excluir produto'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: _WarmPalette.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 140),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: _WarmPalette.primary)),
        ],
      );
    }

    if (_produtos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
        children: [
          const SizedBox(height: 24),
          _buildEmptyState(
            title: 'Sem produtos por aqui',
            subtitle:
                'Cadastre seu primeiro produto pra começar a montar o cardápio.',
            icon: Icons.dinner_dining_rounded,
            buttonLabel: 'Cadastrar produto',
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
          _buildEmptyState(
            title: 'Nenhum produto encontrado',
            subtitle:
                'Tente um termo diferente ou limpe os filtros para ver todos os itens.',
            icon: Icons.search_off_rounded,
            buttonLabel: 'Limpar filtros',
            onPressed: _clearSearchAndFilter,
            secondary: true,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildProductCard(_filtered[index]),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: _WarmPalette.surface,
        border: Border(top: BorderSide(color: _WarmPalette.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Row(
            children: List.generate(_bottomNavItems.length, (index) {
              final item = _bottomNavItems[index];
              final selected = index == 2;
              return Expanded(
                child: InkResponse(
                  onTap: () {},
                  radius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected
                              ? _WarmPalette.warningBg
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: selected
                              ? _WarmPalette.primary
                              : _WarmPalette.textMuted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? _WarmPalette.primary
                              : _WarmPalette.textMuted,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _WarmPalette.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: _WarmPalette.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildSearchField(),
            const SizedBox(height: 10),
            _buildCategoryChips(),
            _buildResultsHeader(),
            Expanded(
              child: RefreshIndicator(
                color: _WarmPalette.primary,
                onRefresh: _reload,
                child: _buildList(),
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
      color: _WarmPalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _WarmPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _WarmPalette.border),
          ),
          child: Icon(icon, color: _WarmPalette.text, size: 22),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _WarmPalette.primary : _WarmPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _WarmPalette.primary : _WarmPalette.border,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x1FD96A4A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : _WarmPalette.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _WarmPalette.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ProductCard({
    required this.child,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _WarmPalette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _WarmPalette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _WarmPalette.border),
            boxShadow: const [
              BoxShadow(
                color: _WarmPalette.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProductTag extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _ProductTag({
    required this.label,
    required this.color,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.12) : _WarmPalette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

