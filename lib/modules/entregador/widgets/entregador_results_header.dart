import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


class EntregadorResultsHeader extends StatelessWidget {
  final int resultCount;
  final bool ascending;
  final VoidCallback onSortTap;

  const EntregadorResultsHeader({
    super.key,
    required this.resultCount,
    required this.ascending,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemLabel = resultCount == 1 ? 'entregador' : 'entregadores';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$resultCount $itemLabel',
              style: const TextStyle(
                color: PaletaApp.text,
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
                    Icons.sort_by_alpha_rounded,
                    size: 16,
                    color: PaletaApp.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ascending ? 'Nome A-Z' : 'Nome Z-A',
                    style: const TextStyle(
                      color: PaletaApp.text,
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
