import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class UnidadeMedidaChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const UnidadeMedidaChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(12),
      child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppTema.primaria : AppTema.fundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppTema.primaria : AppTema.bordaCampo,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? AppTema.fundo : AppTema.textoSecundario,
        ),
      ),
    )
    );
  }
}