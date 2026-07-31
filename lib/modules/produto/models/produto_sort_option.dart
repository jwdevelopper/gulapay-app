import 'package:flutter/material.dart';

class ProdutoSortOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;

  const ProdutoSortOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

const List<ProdutoSortOption> produtoSortOptions = [
  ProdutoSortOption(
    value: 'featured',
    label: 'Mais vendidos',
    subtitle: 'Ordem padrao da lista',
    icon: Icons.local_fire_department_rounded,
  ),
  ProdutoSortOption(
    value: 'price_asc',
    label: 'Preco crescente',
    subtitle: 'Do menor para o maior',
    icon: Icons.arrow_upward_rounded,
  ),
  ProdutoSortOption(
    value: 'price_desc',
    label: 'Preco decrescente',
    subtitle: 'Do maior para o menor',
    icon: Icons.arrow_downward_rounded,
  ),
  ProdutoSortOption(
    value: 'name_asc',
    label: 'Nome A-Z',
    subtitle: 'Alfabetica crescente',
    icon: Icons.sort_by_alpha_rounded,
  ),
  ProdutoSortOption(
    value: 'name_desc',
    label: 'Nome Z-A',
    subtitle: 'Alfabetica decrescente',
    icon: Icons.sort_by_alpha_rounded,
  ),
];
