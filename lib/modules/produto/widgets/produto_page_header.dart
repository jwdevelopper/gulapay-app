import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';

import 'produto_header_icon_button.dart';

class ProdutoPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasCategoryFilter;
  final bool hasActiveFilter;
  final VoidCallback onBackTap;
  /// Se null e sem filtro de categoria, o botão de menu não aparece (navegação no shell).
  final VoidCallback? onMenuTap;
  final VoidCallback onFilterTap;
  final VoidCallback onClearFiltersTap;

  const ProdutoPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hasCategoryFilter,
    required this.hasActiveFilter,
    required this.onBackTap,
    this.onMenuTap,
    required this.onFilterTap,
    required this.onClearFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: PaletaApp.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PaletaApp.textMuted,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          ProdutoHeaderIconButton(
            icon: hasActiveFilter
                ? Icons.close_rounded
                : Icons.filter_alt_outlined,
            onTap: hasActiveFilter ? onClearFiltersTap : onFilterTap,
          ),
        ],
      ),
    );
  }
}
