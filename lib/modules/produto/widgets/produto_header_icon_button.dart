import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


class ProdutoHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ProdutoHeaderIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PaletaApp.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: PaletaApp.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PaletaApp.border),
          ),
          child: Icon(icon, color: PaletaApp.text, size: 22),
        ),
      ),
    );
  }
}
