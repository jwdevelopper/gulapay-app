import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';

/// Uma opção da barra de tipos do histórico de estoque.
class TipoFilterChip {
  final String label;
  final String value;
  final IconData? icon;

  const TipoFilterChip({required this.label, required this.value, this.icon});
}

/// As quatro visões do histórico: tudo, entradas, saídas e ajustes.
const List<TipoFilterChip> tipoFilterChips = [
  TipoFilterChip(label: 'Tudo', value: 'TUDO'),
  TipoFilterChip(
    label: 'Entradas',
    value: 'ENTRADAS',
    icon: Icons.arrow_downward_rounded,
  ),
  TipoFilterChip(
    label: 'Saídas',
    value: 'SAIDAS',
    icon: Icons.arrow_upward_rounded,
  ),
  TipoFilterChip(label: 'Ajustes', value: 'AJUSTES', icon: Icons.tune_rounded),
];

/// Barra de tipos do histórico de movimentações.
///
/// Diferente dos filtros de comanda, aqui sempre há um selecionado — tocar
/// no ativo não desmarca, porque "nenhum tipo" não é uma visão válida
/// (o equivalente é o chip "Tudo").
class TipoFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TipoFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) => AppFileiraChips(
    recuoLateral: 0,
    chips: [
      for (final chip in tipoFilterChips)
        AppChipFiltro(
          rotulo: chip.label,
          icone: chip.icon,
          selecionado: chip.value == selectedFilter,
          aoTocar: () => onFilterChanged(chip.value),
        ),
    ],
  );
}
