import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/models/produto_list_filter.dart';
import 'package:my_app_teste/modules/produto/models/produto_sort_option.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:my_app_teste/modules/produto/widgets/produtos_palette.dart';
import 'package:my_app_teste/modules/produto/widgets/produtos_widgets.dart';
import 'produto_form_page.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final ProdutoService _service = ProdutoService();
  final TextEditingController _searchController = TextEditingController();

  List<Produto> _produtos = [];
  List<Categoria> _categorias = [];
  ProdutoListFilter _filters = const ProdutoListFilter();
  bool _loading = true;
  String _search = '';
  String _sort = 'featured';

  @override
  void initState() {
    super.initState();
    AcoesCriacao.registrar('Produtos', _openCreate);
    _loadCategories();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Categoria? get _selectedCategoria {
    if (_filters.categoriaId == null) return null;
    for (final categoria in _categorias) {
      if (categoria.id == _filters.categoriaId) return categoria;
    }
    return null;
  }

  List<Produto> get _filtered {
    var list = List<Produto>.from(_produtos);

    if (_filters.categoriaId != null) {
      list = list
          .where((produto) => produto.categoriaId == _filters.categoriaId)
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

    if (_filters.precoMin != null) {
      list = list.where((p) => (p.preco ?? 0) >= _filters.precoMin!).toList();
    }
    if (_filters.precoMax != null) {
      list = list.where((p) => (p.preco ?? 0) <= _filters.precoMax!).toList();
    }
    if (_filters.descricao.trim().isNotEmpty) {
      final descricao = _filters.descricao.toLowerCase().trim();
      list = list
          .where((p) => (p.descricao ?? '').toLowerCase().contains(descricao))
          .toList();
    }
    if (_filters.tipoProduto != null && _filters.tipoProduto!.isNotEmpty) {
      final tipo = _filters.tipoProduto!.toUpperCase();
      list = list
          .where((p) => (p.tipoProduto ?? '').toUpperCase().contains(tipo))
          .toList();
    }
    if (_filters.setorProducao != null && _filters.setorProducao!.isNotEmpty) {
      final setor = _filters.setorProducao!.toUpperCase();
      list = list
          .where((p) => (p.setorProducao ?? '').toUpperCase().contains(setor))
          .toList();
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

  String get _screenTitle => _selectedCategoria?.nome.isNotEmpty == true
      ? _selectedCategoria!.nome
      : 'Produtos';

  String get _screenSubtitle {
    if (_loading) return 'Carregando produtos...';
    if (_selectedCategoria != null) {
      return '${_filtered.length} itens • filtro ativo';
    }
    if (_produtos.isEmpty) return 'Comece a cadastrar';
    return '${_produtos.length} itens • ${_categorias.length} categorias';
  }

  String get _sortLabel => produtoSortOptions
      .firstWhere(
        (option) => option.value == _sort,
        orElse: () => produtoSortOptions.first,
      )
      .label;

  bool get _hasActiveFilter =>
      _filters.hasActiveFilter || _search.trim().isNotEmpty;

  Future<void> _loadCategories() async {
    try {
      final lista = await CategoriaService().listar(apenasAtivos: true);
      if (!mounted) return;
      setState(() {
        _categorias = lista;
      });
    } catch (_) {
      // A tela continua funcional mesmo sem categorias.
    }
  }

  Future<void> _load({int? categoriaId}) async {
    if (mounted) {
      setState(() => _loading = true);
    }
    try {
      final lista = await _service.listar(
        apenasAtivos: true,
        categoriaId: categoriaId ?? _filters.categoriaId,
      );
      if (!mounted) return;
      setState(() {
        _produtos = lista
            .map((item) => Produto.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar produtos: $e')));
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

  /// Padrão da [UsuarioListaPagina]: AlertDialog estilizado com FaIcon de
  /// aviso, botões "Cancelar" e "Excluir" (vermelho).
  Future<bool> _confirmarExclusao(Produto produto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: ProdutosPalette.primary,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Excluir produto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ProdutosPalette.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja realmente excluir "${produto.nome}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: ProdutosPalette.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: ProdutosPalette.textMuted,
            ),
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

  /// Executa o delete na API e remove o item do estado local. Devolve [true]
  /// quando o card pode sair da lista (o [Dismissible] usa esse retorno para
  /// concluir a animação).
  Future<bool> _excluir(Produto produto) async {
    if (produto.id == null) return false;
    try {
      await _service.excluirProduto(produto.id!);
      if (!mounted) return false;
      setState(() => _produtos.removeWhere((x) => x.id == produto.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produto "${produto.nome}" excluído.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } on ApiError catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
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

  /// Função única usada pelo swipe (Dismissible) e pelo PopupMenu do card:
  /// mostra a confirmação e, se aprovada, executa a exclusão. Devolve [true]
  /// se o card pode ser removido visualmente (após sucesso da API).
  Future<bool> _confirmarEExcluir(Produto produto) async {
    final confirmou = await _confirmarExclusao(produto);
    if (!confirmou) return false;
    return await _excluir(produto);
  }

  Future<void> _openSortSheet() async {
    final selected = await ProdutoSortSheet.show(context, selectedSort: _sort);
    if (selected == null || selected == _sort) return;
    setState(() => _sort = selected);
  }

  Future<void> _openFilterSheet() async {
    final selectedFilters = await ProdutoFilterSheet.show(
      context,
      categorias: _categorias,
      initialFilter: _filters,
      iconForCategoryName: _iconForCategoryName,
      categoryNameBuilder: _categoriaNome,
    );
    if (selectedFilters == null) return;

    setState(() {
      _filters = selectedFilters;
    });
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
    if (lower.contains('prato') || lower.contains('principal')) {
      return Icons.dinner_dining_rounded;
    }
    return Icons.restaurant_rounded;
  }

  IconData _iconForProduct(Produto produto) {
    final tipo = (produto.tipoProduto ?? '').toUpperCase();
    final categoria = _categoriaNome(produto.categoriaId).toLowerCase();
    if (tipo.contains('BEBIDA') || categoria.contains('beb')) {
      return Icons.local_bar_rounded;
    }
    if (tipo.contains('SOBREMESA') || categoria.contains('sob')) {
      return Icons.cake_rounded;
    }
    if (tipo.contains('PORCAO') || categoria.contains('por')) {
      return Icons.lunch_dining_rounded;
    }
    if (tipo.contains('PRATO') ||
        categoria.contains('prato') ||
        categoria.contains('principal')) {
      return Icons.dinner_dining_rounded;
    }
    return Icons.restaurant_rounded;
  }

  Color _accentForProduct(Produto produto) {
    final seed = _categoriaNome(produto.categoriaId).isNotEmpty
        ? _categoriaNome(produto.categoriaId)
        : produto.nome;
    const palette = <Color>[
      Color(0xFFF8C39C),
      Color(0xFFF6C48A),
      Color(0xFFE7C7F3),
      Color(0xFFF3D0A3),
      Color(0xFFDCE7C1),
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
    if (_filters.categoriaId == null) return;
    setState(() {
      _filters = _filters.clearCategory();
    });
    _load();
  }

  void _clearSearchAndFilter() {
    setState(() {
      _filters = const ProdutoListFilter();
      _search = '';
      _searchController.clear();
    });
    _load();
  }

  Widget _buildCategoryChips() {
    return ProdutoCategoryChips(
      categorias: _categorias,
      selectedCategoriaId: _filters.categoriaId,
      iconForCategoryName: _iconForCategoryName,
      onClearCategory: _clearCategoryFilter,
      onSelectCategory: (categoria) {
        if (_filters.categoriaId == categoria.id) {
          _clearCategoryFilter();
          return;
        }
        setState(() {
          _filters = _filters.copyWith(categoriaId: categoria.id);
        });
        _load(categoriaId: categoria.id);
      },
    );
  }

  Widget _buildProductCard(Produto produto) {
    final categoriaNome = _categoriaNome(produto.categoriaId);
    final descricao = (produto.descricao ?? '').trim();
    final subtitleParts = <String>[];
    if (categoriaNome.isNotEmpty) subtitleParts.add(categoriaNome);
    if (descricao.isNotEmpty) subtitleParts.add(descricao);

    return ProdutoCard(
      produto: produto,
      subtitle: subtitleParts.join(' • '),
      categoriaNome: categoriaNome,
      icon: _iconForProduct(produto),
      accentColor: _accentForProduct(produto),
      sectorLabel: _friendlySector(produto.setorProducao).toUpperCase(),
      sectorColor: _sectorColor(produto.setorProducao),
      priceText: _priceText(produto.preco),
      onTap: () => _openEdit(produto),
      onEdit: () => _openEdit(produto),
      onConfirmDelete: () => _confirmarEExcluir(produto),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 96),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(color: ProdutosPalette.primary),
          ),
        ],
      );
    }

    if (_produtos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
        children: [
          const SizedBox(height: 24),
          EmptyStateCard(
            title: 'Sem produtos por aqui',
            subtitle:
                'Cadastre seu primeiro produto pra comecar a montar o cardapio.',
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
        children: [
          const SizedBox(height: 24),
          EmptyStateCard(
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildProductCard(_filtered[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: ProdutosPalette.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      backgroundColor: ProdutosPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            ProdutoSearchField(
              controller: _searchController,
              search: _search,
              onChanged: (value) => setState(() => _search = value),
              onClear: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            ),
            const SizedBox(height: 10),
            _buildCategoryChips(),
            ProdutoResultsHeader(
              resultCount: _filtered.isEmpty && _produtos.isNotEmpty
                  ? 0
                  : _filtered.length,
              sortLabel: _sortLabel,
              onSortTap: _openSortSheet,
            ),
            Expanded(
              child: RefreshIndicator(
                color: ProdutosPalette.primary,
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
