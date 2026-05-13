import 'package:flutter/material.dart';

import 'produtos_page.dart';

class ProdutoPage extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const ProdutoPage({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return ProdutosPage(onOpenDrawer: onOpenDrawer);
  }
}
