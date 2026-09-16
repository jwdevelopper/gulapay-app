String moeda(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

String moedaCentavos(int centavos) => moeda(centavos / 100);

String quantidadeItem(double quantidade) =>
    quantidade == quantidade.roundToDouble()
        ? quantidade.toStringAsFixed(0)
        : quantidade.toString().replaceAll('.', ',');
