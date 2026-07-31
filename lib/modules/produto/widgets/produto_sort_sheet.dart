import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/produto/models/produto_sort_option.dart';

import 'produtos_palette.dart';

class ProdutoSortSheet extends StatelessWidget {
  final String selectedSort;

  const ProdutoSortSheet({super.key, required this.selectedSort});

  static Future<String?> show(
    BuildContext context, {
    required String selectedSort,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ProdutoSortSheet(selectedSort: selectedSort);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.56,
      child: Container(
        decoration: const BoxDecoration(
          color: ProdutosPalette.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ProdutosPalette.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ordenar produtos',
                        style: TextStyle(
                          color: ProdutosPalette.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: ProdutosPalette.text,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: produtoSortOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option = produtoSortOptions[index];
                      final selected = option.value == selectedSort;
                      return InkWell(
                        onTap: () => Navigator.pop(context, option.value),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? ProdutosPalette.warningBg
                                : ProdutosPalette.surfaceAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? ProdutosPalette.primary
                                  : ProdutosPalette.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ProdutosPalette.primary
                                      : ProdutosPalette.inputFill,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: selected
                                      ? Colors.white
                                      : ProdutosPalette.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.label,
                                      style: const TextStyle(
                                        color: ProdutosPalette.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option.subtitle,
                                      style: const TextStyle(
                                        color: ProdutosPalette.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: ProdutosPalette.primaryPressed,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
