import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';

import 'produto_form_page.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final ProdutoService _service = ProdutoService();
  List<Produto> _produtos = [];
  List<Categoria> _categorias = [];
  int? _selectedCategoriaId;
  bool _loading = false;
  String _search = '';
  String _sort = 'none';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
  }

  Future<void> _loadCategories() async {
    try {
      final lista = await CategoriaService().listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() {
        _categorias = lista;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _load({int? categoriaId}) async {
    setState(() => _loading = true);
    try {
      final lista = await _service.listar(apenasAtivos: false, categoriaId: categoriaId ?? _selectedCategoriaId);
      if (!mounted) return;
      setState(() {
        _produtos = lista.map((e) => Produto.fromJson(Map<String, dynamic>.from(e))).toList();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar produtos: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir produto'),
        content: const Text('Deseja excluir este produto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.excluirProduto(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto excluído')));
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  List<Produto> get _filtered {
    var list = List<Produto>.from(_produtos);
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((p) => p.nome.toLowerCase().contains(q) || (p.descricao ?? '').toLowerCase().contains(q)).toList();
    }
    switch (_sort) {
      case 'price_asc':
        list.sort((a, b) => (a.preco ?? 0).compareTo(b.preco ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.preco ?? 0).compareTo(a.preco ?? 0));
        break;
      case 'name_asc':
        list.sort((a, b) => a.nome.compareTo(b.nome));
        break;
      case 'name_desc':
        list.sort((a, b) => b.nome.compareTo(a.nome));
        break;
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar produto...'),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // category chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: _selectedCategoriaId == null,
                    onSelected: (s) async {
                      setState(() => _selectedCategoriaId = null);
                      await _load();
                    },
                  ),
                ),
                ..._categorias.map((c) {
                  final selected = _selectedCategoriaId == c.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c.nome),
                      selected: selected,
                      onSelected: (s) async {
                        setState(() => _selectedCategoriaId = s ? c.id : null);
                        await _load(categoriaId: s ? c.id : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text('${_filtered.length} produtos')),
                PopupMenuButton<String>(
                  onSelected: (v) => setState(() => _sort = v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'none', child: Text('Mais vendidos')),
                    const PopupMenuItem(value: 'price_asc', child: Text('Preço ↑')),
                    const PopupMenuItem(value: 'price_desc', child: Text('Preço ↓')),
                    const PopupMenuItem(value: 'name_asc', child: Text('Nome A-Z')),
                    const PopupMenuItem(value: 'name_desc', child: Text('Nome Z-A')),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Text('Ordenar'), SizedBox(width: 6), Icon(Icons.sort)],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? ListView(padding: const EdgeInsets.all(24), children: const [Center(child: Text('Sem produtos'))])
                        : ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              final p = _filtered[index];
                              final categoria = _categorias.firstWhere((c) => c.id == p.categoriaId, orElse: () => Categoria(id: 0, nome: ''));
                              return InkWell(
                                onTap: () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: p)),
                                  );
                                  if (changed == true) await _load();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color.fromRGBO(255, 152, 0, 0.12)),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.orange.shade200]),
                                        ),
                                        child: Center(child: Text(p.nome.isNotEmpty ? p.nome[0].toUpperCase() : '?')),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text(categoria.nome.isNotEmpty ? '${categoria.nome} • ${p.descricao ?? ''}' : (p.descricao ?? ''),
                                                style: const TextStyle(color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                                              child: Text((p.setorProducao ?? '').toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('R\$ ${p.preco != null ? p.preco!.toStringAsFixed(2) : '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                final changed = await Navigator.push<bool>(
                                                  context,
                                                  MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: p)),
                                                );
                                                if (changed == true) await _load();
                                              } else if (value == 'delete' && p.id != null) {
                                                await _delete(p.id!);
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ProdutoFormPage()),
          );
          if (created == true) await _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
