import 'package:flutter/material.dart';
import 'package:my_app_teste/features/produto/model/produto.dart';
import 'package:my_app_teste/features/produto/page/produto_form_page.dart';
import 'package:my_app_teste/features/produto/service/produto_service.dart';

class ProdutoListPage extends StatefulWidget {
  const ProdutoListPage({super.key});

  @override
  State<ProdutoListPage> createState() => _ProdutoListPageState();
}

class _ProdutoListPageState extends State<ProdutoListPage> {
  final ProdutoService _service = ProdutoService();
  List<Produto> _produtos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    setState(() => _loading = true);
    try {
      final lista = await _service.listProdutos(apenasAtivos: false);
      setState(() => _produtos = lista);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProdutoFormPage()),
    );
    if (result == true) await _loadProdutos();
  }

  Future<void> _onEdit(Produto p) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: p)),
    );
    if (result == true) await _loadProdutos();
  }

  Future<void> _onDelete(Produto p) async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${p.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteProduto(p.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído')),
        );
        await _loadProdutos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProdutos,
              child: _produtos.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Nenhum produto cadastrado')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _produtos.length,
                      itemBuilder: (context, index) {
                        final p = _produtos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(p.nome),
                            subtitle: Text(p.descricao ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _onEdit(p),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => _onDelete(p),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
