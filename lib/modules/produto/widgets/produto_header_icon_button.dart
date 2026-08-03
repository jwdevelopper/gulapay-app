import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class ProdutoHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ProdutoHeaderIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProdutosPalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ProdutosPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ProdutosPalette.border),
          ),
          child: Icon(icon, color: ProdutosPalette.text, size: 22),
        ),
      ),
    );
  }
}
