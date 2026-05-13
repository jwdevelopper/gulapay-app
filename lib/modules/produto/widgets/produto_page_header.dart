import 'package:flutter/material.dart';

import 'produto_header_icon_button.dart';
import 'produtos_palette.dart';

class ProdutoPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasCategoryFilter;
  final bool hasActiveFilter;
  final VoidCallback onBackTap;
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
    required this.onMenuTap,
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
          ProdutoHeaderIconButton(
            icon: hasCategoryFilter
                ? Icons.arrow_back_rounded
                : Icons.menu_rounded,
            onTap: hasCategoryFilter ? onBackTap : onMenuTap,
          ),
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
