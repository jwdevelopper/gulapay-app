import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

import 'produto_category_chip.dart';

class ProdutoCategoryChips extends StatelessWidget {
  final List<Categoria> categorias;
  final int? selectedCategoriaId;
  final IconData Function(String name) iconForCategoryName;
  final VoidCallback onClearCategory;
  final ValueChanged<Categoria> onSelectCategory;

  const ProdutoCategoryChips({
    super.key,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.iconForCategoryName,
    required this.onClearCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ProdutoCategoryChip(
        label: 'Todas',
        icon: Icons.grid_view_rounded,
        selected: selectedCategoriaId == null,
        onTap: onClearCategory,
      ),
      ...categorias.map(
        (categoria) => ProdutoCategoryChip(
          label: categoria.nome,
          icon: iconForCategoryName(categoria.nome),
          selected: selectedCategoriaId == categoria.id,
          onTap: () => onSelectCategory(categoria),
        ),
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: chips.length,
        itemBuilder: (context, index) => chips[index],
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }
}
