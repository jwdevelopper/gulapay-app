/// Estado dos filtros da listagem de comandas.
///
/// Objeto de valor puro (sem Flutter): a página guarda uma instância e a
/// troca por outra a cada toque num chip. Diferente do `FiltroEstoque`,
/// que peneira uma lista em memória, estes campos viram query params de
/// `GET /comandas` — por isso a página recarrega a cada mudança.
class FiltroComandas {
  /// Status da comanda (`ABERTA`, `AGUARDANDO_PAGAMENTO`, `FECHADA`,
  /// `CANCELADA`) ou `null` para todos.
  final String? status;

  /// Canal de venda (`MESA`, `BALCAO`, `DELIVERY`) ou `null` para todos.
  final String? tipoOrigem;

  const FiltroComandas({this.status, this.tipoOrigem});

  /// Status aceitos pelo backend, na ordem do ciclo de vida da comanda.
  static const statusDisponiveis = [
    'ABERTA',
    'AGUARDANDO_PAGAMENTO',
    'FECHADA',
    'CANCELADA',
  ];

  /// Canais aceitos pelo backend.
  static const canaisDisponiveis = ['MESA', 'BALCAO', 'DELIVERY'];

  /// Nenhum filtro escolhido — a listagem mostra tudo.
  bool get vazio => status == null && tipoOrigem == null;

  /// Alterna o status: tocar no que já está escolhido volta para "todas".
  FiltroComandas alternarStatus(String? valor) => FiltroComandas(
    status: status == valor ? null : valor,
    tipoOrigem: tipoOrigem,
  );

  /// Alterna o canal, com a mesma regra de [alternarStatus].
  FiltroComandas alternarCanal(String valor) => FiltroComandas(
    status: status,
    tipoOrigem: tipoOrigem == valor ? null : valor,
  );
}
