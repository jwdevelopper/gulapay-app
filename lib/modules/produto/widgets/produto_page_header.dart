import 'package:flutter/material.dart';

import 'produto_header_icon_button.dart';
import 'produtos_palette.dart';

class ProdutoPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasCategoryFilter;
  final VoidCallback onBackTap;
  /// Se null e sem filtro de categoria, o botão de menu não aparece (navegação no shell).
  final VoidCallback? onMenuTap;

  const ProdutoPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hasCategoryFilter,
    required this.onBackTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasCategoryFilter)
            ProdutoHeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBackTap,
            )
          else if (onMenuTap != null)
            ProdutoHeaderIconButton(
              icon: Icons.menu_rounded,
              onTap: onMenuTap,
            )
          else
            const SizedBox(width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ProdutosPalette.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ProdutosPalette.textMuted,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}