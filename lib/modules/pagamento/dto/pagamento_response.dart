/// Um pagamento registrado numa comanda.
///
/// Espelha o `PagamentoResponse` do backend. Uma comanda pode ter 1..N
/// pagamentos — conta dividida é a regra, não a exceção (seção 3.7).
class PagamentoResponse {
  final int? id;
  final int? comandaId;
  final String? comandaCodigo;

  /// Caixa em que o pagamento entrou. Todo pagamento exige um caixa
  /// aberto, qualquer que seja a forma — sem isso a conferência de turno
  /// não fecha.
  final int? caixaId;

  /// `DINHEIRO`, `CREDITO`, `DEBITO`, `PIX` ou `VALE_ALIMENTACAO`.
  final String? formaPagamento;

  final double? valor;

  /// `ATIVO` ou `CANCELADO`. Um pagamento cancelado não conta no total
  /// recebido, mas continua no histórico.
  final String? status;

  final String? motivoCancelamento;
  final String? registradoPor;
  final String? canceladoPor;
  final String? dataHora;

  const PagamentoResponse({
    this.id,
    this.comandaId,
    this.comandaCodigo,
    this.caixaId,
    this.formaPagamento,
    this.valor,
    this.status,
    this.motivoCancelamento,
    this.registradoPor,
    this.canceladoPor,
    this.dataHora,
  });

  bool get ativo => status != 'CANCELADO';

  factory PagamentoResponse.fromJson(Map<String, dynamic> json) =>
      PagamentoResponse(
        id: _inteiro(json['id']),
        comandaId: _inteiro(json['comandaId']),
        comandaCodigo: json['comandaCodigo']?.toString(),
        caixaId: _inteiro(json['caixaId']),
        formaPagamento: json['formaPagamento']?.toString(),
        valor: _decimal(json['valor']),
        status: json['status']?.toString(),
        motivoCancelamento: json['motivoCancelamento']?.toString(),
        registradoPor: json['registradoPor']?.toString(),
        canceladoPor: json['canceladoPor']?.toString(),
        dataHora: json['dataHora']?.toString(),
      );

  static int? _inteiro(dynamic valor) =>
      valor is int ? valor : int.tryParse('$valor');

  static double? _decimal(dynamic valor) =>
      valor is num ? valor.toDouble() : double.tryParse('$valor');
}

/// Situação de pagamento de uma comanda.
///
/// Espelha o `ComandaPagamentosResponse`: o que a comanda deve, o que já
/// foi pago e o que falta.
class PagamentosDaComanda {
  final int? comandaId;
  final String? comandaCodigo;

  /// Total devido: os itens da comanda mais a parte recebida de um rateio.
  final double totalDevido;

  /// Soma dos pagamentos ativos.
  final double totalPago;

  /// Quanto ainda falta receber.
  final double saldoRestante;

  final List<PagamentoResponse> pagamentos;

  const PagamentosDaComanda({
    this.comandaId,
    this.comandaCodigo,
    this.totalDevido = 0,
    this.totalPago = 0,
    this.saldoRestante = 0,
    this.pagamentos = const [],
  });

  /// A comanda está quitada?
  bool get quitada => saldoRestante <= 0;

  factory PagamentosDaComanda.fromJson(
    Map<String, dynamic> json,
  ) => PagamentosDaComanda(
    comandaId: PagamentoResponse._inteiro(json['comandaId']),
    comandaCodigo: json['comandaCodigo']?.toString(),
    totalDevido: PagamentoResponse._decimal(json['totalDevido']) ?? 0,
    totalPago: PagamentoResponse._decimal(json['totalPago']) ?? 0,
    saldoRestante: PagamentoResponse._decimal(json['saldoRestante']) ?? 0,
    pagamentos: (json['pagamentos'] is List ? json['pagamentos'] as List : [])
        .whereType<Map>()
        .map((p) => PagamentoResponse.fromJson(Map<String, dynamic>.from(p)))
        .toList(),
  );
}
