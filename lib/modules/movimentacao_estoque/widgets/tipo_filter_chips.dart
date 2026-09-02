import 'package:flutter/material.dart';

import 'estoque_palette.dart';

class TipoFilterChip {
  final String label;
  final String value;
  final IconData? icon;

  const TipoFilterChip({
    required this.label,
    required this.value,
    this.icon,
  });
}

const List<TipoFilterChip> tipoFilterChips = [
  TipoFilterChip(label: 'Tudo', value: 'TUDO'),
  TipoFilterChip(label: 'Entradas', value: 'ENTRADAS', icon: Icons.arrow_downward_rounded),
  TipoFilterChip(label: 'Saídas', value: 'SAIDAS', icon: Icons.arrow_upward_rounded),
  TipoFilterChip(label: 'Ajustes', value: 'AJUSTES', icon: Icons.tune_rounded),
];

class TipoFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TipoFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tipoFilterChips.map((chip) {
            final selected = chip.value == selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onFilterChanged(chip.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? EstoquePalette.primary
                        : EstoquePalette.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? EstoquePalette.primary
                          : EstoquePalette.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chip.icon != null) ...[
                        Icon(
                          chip.icon,
                          size: 14,
                          color: selected
                              ? Colors.white
                              : EstoquePalette.textMuted,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        chip.label,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : EstoquePalette.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
