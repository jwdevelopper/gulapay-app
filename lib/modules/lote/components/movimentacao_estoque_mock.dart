class MovimentacaoEstoqueMock {
  final int id;
  final String tipo;
  final int loteId;
  final String unidadeSimbolo;
  final String unidadePadraoSimbolo;
  final double quantidade;
  final String dataHora;
  final String responsavel;

  const MovimentacaoEstoqueMock({
    required this.id,
    required this.tipo,
    required this.loteId,
    required this.unidadeSimbolo,
    required this.unidadePadraoSimbolo,
    required this.quantidade,
    required this.dataHora,
    required this.responsavel,
  });
}

class MovimentacaoEstoqueServiceMock {
  /// Simula uma chamada de API com latência de 600ms, retornando as
  /// movimentações do lote informado. Para testar o estado de erro, mude
  /// `simulateError` para true.
  Future<List<MovimentacaoEstoqueMock>> listarPorLote(
    int loteId, {
    bool simulateError = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (simulateError) {
      throw Exception('Falha simulada ao carregar movimentações');
    }

    return [
      MovimentacaoEstoqueMock(
        id: 1,
        tipo: 'ENTRADA_COMPRA',
        loteId: loteId,
        unidadeSimbolo: 'kg',
        unidadePadraoSimbolo: 'kg',
        quantidade: 10,
        dataHora: '2026-06-01T09:30:00',
        responsavel: 'Ana Souza',
      ),
      MovimentacaoEstoqueMock(
        id: 2,
        tipo: 'SAIDA_VENDA',
        loteId: loteId,
        unidadeSimbolo: 'kg',
        unidadePadraoSimbolo: 'kg',
        quantidade: 3,
        dataHora: '2026-06-05T14:10:00',
        responsavel: 'Carlos Lima',
      ),
      MovimentacaoEstoqueMock(
        id: 3,
        tipo: 'AJUSTE_INVENTARIO',
        loteId: loteId,
        unidadeSimbolo: 'kg',
        unidadePadraoSimbolo: 'kg',
        quantidade: 1,
        dataHora: '2026-06-08T11:00:00',
        responsavel: 'Ana Souza',
      ),
    ];
  }
}
