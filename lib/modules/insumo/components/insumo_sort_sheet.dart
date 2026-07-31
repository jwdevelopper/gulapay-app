import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_sort_options.dart';

class InsumoSortSheet {
  static Future<String?> show(BuildContext context, {required String selectedSort}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top:Radius.circular(20))),
      builder: (ctx) => _InsumoSortSheetContent(selectedSort: selectedSort),
    );
  }
}

class _InsumoSortSheetContent extends StatelessWidget {
  final String selectedSort;

  const _InsumoSortSheetContent({required this.selectedSort});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center (
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 6),
            ...insumoSortOptions.map((opt) {
              final isSelected = opt.value == selectedSort;
              return _SortOptionTile(
                option: opt,
                selected: isSelected,
                onTap: () => Navigator.pop(context, opt.value),
              );
            }),
          ]
        )
      )
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final InsumoSortOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                option.icon,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if(selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                ),
              )
          ],
        )
      )
    );
  }
}