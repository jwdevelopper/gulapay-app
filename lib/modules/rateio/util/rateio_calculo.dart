/// Cálculos de rateio feitos no cliente só para **prévia** na tela — o
/// valor que vale é sempre o que volta do backend depois do POST.
/// Tudo em centavos (int) porque somar double dá 99,99999 em vez de 100.
library;

/// Divide [totalCentavos] em [quantidade] partes iguais, jogando o resto
/// de centavos nas primeiras partes. É a mesma regra do backend no
/// IGUALITARIO e no POR_ITEM, então a prévia bate com o cálculo real.
List<int> dividirCentavos(int totalCentavos, int quantidade) {
  if (quantidade <= 0) return const [];
  final base = totalCentavos ~/ quantidade;
  final resto = totalCentavos % quantidade;
  return List.generate(quantidade, (i) => i < resto ? base + 1 : base);
}

/// Prévia do POR_ITEM: quanto cada participante paga somando as frações
/// dos itens que consumiu.
///
/// [subtotalCentavosPorItem] — subtotal de cada item ativo da comanda.
/// [consumidoresPorItem] — quem consumiu cada item (ids de comanda
/// INDIVIDUAL). Itens sem consumidor são ignorados aqui; quem barra o
/// envio nesse caso é a validação da tela.
///
/// Devolve `comandaIndividualId -> centavos`, incluindo os participantes
/// que não consumiram nada (zerados) quando aparecem em [participantes].
Map<int, int> calcularRateioPorItem({
  required Map<int, int> subtotalCentavosPorItem,
  required Map<int, Set<int>> consumidoresPorItem,
  required List<int> participantes,
}) {
  final totais = {for (final id in participantes) id: 0};

  for (final entrada in subtotalCentavosPorItem.entries) {
    // Ordem estável por id: o resto de centavos precisa cair sempre na
    // mesma pessoa entre dois rebuilds da tela.
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
