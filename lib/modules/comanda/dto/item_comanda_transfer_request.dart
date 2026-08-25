class ItemComandaTransferRequest {
  const ItemComandaTransferRequest({required this.comandaDestinoId});

  final int comandaDestinoId;

  Map<String, dynamic> toJson() => {'comandaDestinoId': comandaDestinoId};
}
