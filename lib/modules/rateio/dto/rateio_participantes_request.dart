/// Payload de `PATCH /comandas/{id}/participantes`. Toda comanda
/// INDIVIDUAL cujo id não estiver na lista é desmarcada — é uma
/// substituição completa do conjunto, não incremento.
class RateioParticipantesRequest {
  final List<int> comandaIndividualIds;

  const RateioParticipantesRequest({required this.comandaIndividualIds});

  Map<String, dynamic> toJson() =>
      {'comandaIndividualIds': comandaIndividualIds};
}
