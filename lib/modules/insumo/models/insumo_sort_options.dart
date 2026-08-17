import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

class InsumoSortOption {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;

  final int Function(InsumoResponse a, InsumoResponse b) comparator;

  final String? Function(InsumoResponse insumo)? grouper;

  final int Function(String a, String b)? groupOrder;

  const InsumoSortOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.comparator,
    this.grouper,
    this.groupOrder,
  });
}

final List<InsumoSortOption> insumoSortOptions = [
   InsumoSortOption(
    value: 'below_min_first',
    label: 'Estoque',
    subtitle: 'Abaixo do mínimo primeiro',
    icon: Icons.priority_high_rounded,
    comparator: (a, b) => (a.nome ?? '').toLowerCase().compareTo((b.nome ?? '').toLowerCase()),
    grouper: (i) => i.abaixoDoMinimo == true ? 'Abaixo do mínimo' : 'Estoque padrão',
    groupOrder: (a, b) {
      if (a == 'ABAIXO DO MÍNIMO') return -1;
      if (b == 'ABAIXO DO MÍNIMO') return 1;
      return 0;
    }
  ),
  InsumoSortOption(
    value: 'stock_asc',
    label: 'Estoque crescente',
    subtitle: 'Do menor para o maior',
    icon: Icons.arrow_upward_rounded,
    comparator: (a, b) =>
        (a.estoqueAtual ?? 0).compareTo(b.estoqueAtual ?? 0),
  ),
  InsumoSortOption(
    value: 'stock_desc',
    label: 'Estoque decrescente',
    subtitle: 'Do maior para o menor',
    icon: Icons.arrow_downward_rounded,
    comparator: (a, b) =>
        (b.estoqueAtual ?? 0).compareTo(a.estoqueAtual ?? 0),
  ),
  InsumoSortOption(
    value: 'name_asc',
    label: 'Nome A-Z',
    subtitle: 'Agrupado por letra inicial',
    icon: Icons.sort_by_alpha_rounded,
    comparator: (a, b) =>
        (a.nome ?? '').toLowerCase().compareTo((b.nome ?? '').toLowerCase()),
    grouper: (i) {
      final nome = (i.nome ?? '').trim();
      return nome.isEmpty ? '#' : nome[0].toUpperCase();
    },
  ),
  InsumoSortOption(
    value: 'name_desc',
    label: 'Nome Z-A',
    subtitle: 'Alfabética decrescente',
    icon: Icons.sort_by_alpha_rounded,
    comparator: (a, b) =>
        (b.nome ?? '').toLowerCase().compareTo((a.nome ?? '').toLowerCase()),
  ),
  InsumoSortOption(
    value: 'unit',
    label: 'Por unidade de medida',
    subtitle: 'Agrupado por kg, L, un...',
    icon: Icons.straighten_rounded,
    comparator: (a, b) =>
        (a.nome ?? '').toLowerCase().compareTo((b.nome ?? '').toLowerCase()),
    grouper: (i) => i.unidadePadraoSimbolo ?? 'sem unidade',
  ),
];
