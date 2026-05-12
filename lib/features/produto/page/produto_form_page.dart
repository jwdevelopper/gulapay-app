import 'package:flutter/material.dart';
import 'package:my_app_teste/features/produto/model/produto.dart';
import 'package:my_app_teste/features/produto/page/components/product_form_component.dart';
import 'package:my_app_teste/features/produto/service/produto_service.dart';

class ProdutoFormPage extends StatelessWidget {
  final Produto? produto;

  const ProdutoFormPage({super.key, this.produto});

  @override
  Widget build(BuildContext context) {
    final service = ProdutoService();
    return Scaffold(
      appBar: AppBar(
        title: Text(produto == null ? 'Cadastrar produto' : 'Editar produto'),
      ),
      body: ProductFormComponent(
        produto: produto,
        onSubmit: (Produto p) async {
          if (produto == null) {
            return await service.createProduto(p);
          } else {
            final id = produto!.id!;
            return await service.updateProduto(id, p);
          }
        },
      ),
    );
  }
}
