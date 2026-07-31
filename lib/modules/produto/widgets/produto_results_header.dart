import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class ProdutoResultsHeader extends StatelessWidget {
  final int resultCount;
  final String sortLabel;
  final VoidCallback onSortTap;

  const ProdutoResultsHeader({
    super.key,
    required this.resultCount,
    required this.sortLabel,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$resultCount produtos',
              style: const TextStyle(
                color: ProdutosPalette.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
