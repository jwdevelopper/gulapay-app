/// Uma linha de [RateioComandaResponse.participantes]. Representa uma
/// comanda INDIVIDUAL que participa (ou não) do rateio da COMPARTILHADA.
class RateioParticipanteResponse {
  final int comandaIndividualId;
  final String codigo;
  final String? clienteNome;
  final bool participante;
  final double valorProprio;
  final double valorRateio;
  final double valorTotal;

  const RateioParticipanteResponse({
    required this.comandaIndividualId,
    required this.codigo,
    required this.clienteNome,
    required this.participante,
    required this.valorProprio,
    required this.valorRateio,
    required this.valorTotal,
  });

  factory RateioParticipanteResponse.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return RateioParticipanteResponse(
      comandaIndividualId: json['comandaIndividualId'] as int,
      codigo: json['codigo']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString(),
      participante: json['participante'] == true,
      valorProprio: asDouble(json['valorProprio']),
      valorRateio: asDouble(json['valorRateio']),
      valorTotal: asDouble(json['valorTotal']),
    );
  }
}

/// Payload de resposta compartilhado pelos 4 endpoints de rateio.
/// `estrategia` vem `null` enquanto o rateio não foi aplicado.
class RateioComandaResponse {
  final int comandaId;
  final String codigo;
  final String? estrategia;
  final double totalLiquido;
  final List<RateioParticipanteResponse> participantes;

  const RateioComandaResponse({
    required this.comandaId,
    required this.codigo,
    required this.estrategia,
    required this.totalLiquido,
    required this.participantes,
  });

  bool get rateioAplicado => estrategia != null;

  factory RateioComandaResponse.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return RateioComandaResponse(
      comandaId: json['comandaId'] as int,
      codigo: json['codigo']?.toString() ?? '',
      estrategia: json['estrategia']?.toString(),
      totalLiquido: asDouble(json['totalLiquido']),
      participantes: (json['participantes'] as List? ?? [])
          .whereType<Map>()
          .map((p) => RateioParticipanteResponse.fromJson(
              Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}
