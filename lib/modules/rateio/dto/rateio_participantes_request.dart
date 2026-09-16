class RateioParticipantesRequest {
  final List<int> comandaIndividualIds;

  const RateioParticipantesRequest({required this.comandaIndividualIds});

  Map<String, dynamic> toJson() =>
      {'comandaIndividualIds': comandaIndividualIds};
}
