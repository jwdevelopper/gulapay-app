import 'package:flutter/material.dart';
import 'package:my_app_teste/model/produto.dart';
import 'package:my_app_teste/pages/produtos/produto_form_page.dart';
import 'package:my_app_teste/services/produto_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar produtos: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onAdd() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProdutoFormPage()));
    if (result == true) await _loadProdutos();
  }

  Future<void> _onEdit(Produto p) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: p)));
    if (result == true) await _loadProdutos();
  }

  Future<void> _onDelete(Produto p) async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${p.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Excluir')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteProduto(p.id!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produto excluído')));
        await _loadProdutos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProdutos,
              child: _produtos.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 80),
                        Center(child: Text('Nenhum produto cadastrado')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _produtos.length,
                      itemBuilder: (context, index) {
                        final p = _produtos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(p.nome),
                            subtitle: Text(p.descricao ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () => _onEdit(p), icon: Icon(Icons.edit)),
                                IconButton(onPressed: () => _onDelete(p), icon: Icon(Icons.delete, color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: Icon(Icons.add),
      ),
    );
  }
}
