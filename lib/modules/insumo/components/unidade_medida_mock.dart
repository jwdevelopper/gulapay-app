class UnidadeMedidaMock {
  final int id;
  final String nome;
  final String simbolo;

  const UnidadeMedidaMock({
    required this.id,
    required this.nome,
    required this.simbolo,
  });
}

class UnidadeMedidaServiceMock {
  /// Simula uma chamada de API com latência de 600ms.
  /// Para testar o estado de erro, mude `simulateError` para true.
  Future<List<UnidadeMedidaMock>> listar({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (simulateError) {
      throw Exception('Falha simulada ao carregar unidades');
    }

    return const [
      UnidadeMedidaMock(id: 1, nome: 'Quilograma', simbolo: 'kg'),
      UnidadeMedidaMock(id: 2, nome: 'Grama', simbolo: 'g'),
      UnidadeMedidaMock(id: 3, nome: 'Litro', simbolo: 'L'),
      UnidadeMedidaMock(id: 4, nome: 'Mililitro', simbolo: 'mL'),
      UnidadeMedidaMock(id: 5, nome: 'Unidade', simbolo: 'un'),
    ];
  }
}