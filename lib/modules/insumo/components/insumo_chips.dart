import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_chip.dart';

class UnidadesMedidasChips extends StatelessWidget {
  final List<UnidadeMedidaResponse> unidadesMedidas;
  final int? selectedUnidadeMedidaId;
  final VoidCallback onClear;
  final ValueChanged<UnidadeMedidaResponse> onSelected;

  const UnidadesMedidasChips({
    super.key,
    required this.unidadesMedidas,
    required this.selectedUnidadeMedidaId,
    required this.onClear,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      UnidadeMedidaChip(
        label: 'Todos',
        selected: selectedUnidadeMedidaId == null,
        onSelected: onClear,
      ),
      ...unidadesMedidas.map(
        (unidade) => UnidadeMedidaChip(
          label: unidade.nome ?? "",
          selected: selectedUnidadeMedidaId == unidade.id,
          onSelected: () => onSelected(unidade),
        )
      )
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: chips.length,
        itemBuilder: (context, index) => chips[index],
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }
}