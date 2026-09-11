import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';

/// Chip de categoria da vitrine de produtos.
///
/// É o [AppChipFiltro] com sombra: aqui os chips são a navegação principal
/// da tela, não um filtro discreto, então o selecionado ganha elevação.
class ProdutoCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ProdutoCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppChipFiltro(
    rotulo: label,
    icone: icon,
    selecionado: selected,
    aoTocar: onTap,
    comSombra: true,
  );
}
