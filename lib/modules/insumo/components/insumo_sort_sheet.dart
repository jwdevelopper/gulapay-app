import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_sort_options.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class InsumoSortSheet extends StatelessWidget {
  final String selectedSort;

  const InsumoSortSheet({super.key, required this.selectedSort});

  static Future<String?> show(
    BuildContext context, {
    required String selectedSort,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return InsumoSortSheet(selectedSort: selectedSort);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.56,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTema.fundo,
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
                      color: AppTema.primariaEscura,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ordenar insumos',
                        style: TextStyle(
                          color: AppTema.textoEscuro,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTema.primaria,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: insumoSortOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option = insumoSortOptions[index];
                      final selected = option.value == selectedSort;
                      return InkWell(
                        onTap: () => Navigator.pop(context, option.value),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTema.fundo
                                : AppTema.cartao,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppTema.primaria
                                  : AppTema.bordaCampo,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTema.primaria
                                      : AppTema.cartao,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: selected
                                      ? Colors.white
                                      : AppTema.primaria,
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
                                        color: AppTema.textoEscuro,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option.subtitle,
                                      style: const TextStyle(
                                        color: AppTema.textoSecundario,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppTema.primariaEscura,
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
