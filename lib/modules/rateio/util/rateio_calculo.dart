List<int> dividirCentavos(int totalCentavos, int quantidade) {
  if (quantidade <= 0) return const [];
  final base = totalCentavos ~/ quantidade;
  final resto = totalCentavos % quantidade;
  return List.generate(quantidade, (i) => i < resto ? base + 1 : base);
}

Map<int, int> calcularRateioPorItem({
  required Map<int, int> subtotalCentavosPorItem,
  required Map<int, Set<int>> consumidoresPorItem,
  required List<int> participantes,
}) {
  final totais = {for (final id in participantes) id: 0};

  for (final entrada in subtotalCentavosPorItem.entries) {
    final consumidores = (consumidoresPorItem[entrada.key] ?? const <int>{})
        .toList()
      ..sort();
    if (consumidores.isEmpty) continue;

    final fatias = dividirCentavos(entrada.value, consumidores.length);
    for (var i = 0; i < consumidores.length; i++) {
      totais.update(consumidores[i], (v) => v + fatias[i],
          ifAbsent: () => fatias[i]);
    }
  }

  return totais;
}
