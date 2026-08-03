import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class ProdutoResultsHeader extends StatelessWidget {
  final int resultCount;
  final String sortLabel;
  final VoidCallback onSortTap;

  /// Quando informado, mostra um botão de filtro à direita (ícone de funil).
  /// Se [hasActiveFilter] for [true] o ícone vira um "x" para indicar
  /// que o tap vai limpar os filtros ativos via [onClearFiltersTap].
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearFiltersTap;
  final bool hasActiveFilter;

  const ProdutoResultsHeader({
    super.key,
    required this.resultCount,
    required this.sortLabel,
    required this.onSortTap,
    this.onFilterTap,
    this.onClearFiltersTap,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$resultCount produtos${hasActiveFilter ? ' • filtros ativos' : ''}',
              style: const TextStyle(
                color: ProdutosPalette.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onFilterTap != null || onClearFiltersTap != null)
            InkWell(
              onTap: hasActiveFilter ? onClearFiltersTap : onFilterTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasActiveFilter
                          ? Icons.close_rounded
                          : Icons.filter_alt_outlined,
                      size: 16,
                      color: hasActiveFilter
                          ? ProdutosPalette.primaryPressed
                          : ProdutosPalette.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasActiveFilter ? 'Limpar' : 'Filtros',
                      style: TextStyle(
                        color: hasActiveFilter
                            ? ProdutosPalette.primaryPressed
                            : ProdutosPalette.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (onFilterTap != null || onClearFiltersTap != null)
            const SizedBox(width: 8),
          InkWell(
            onTap: onSortTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: ProdutosPalette.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sortLabel,
                    style: const TextStyle(
                      color: ProdutosPalette.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
