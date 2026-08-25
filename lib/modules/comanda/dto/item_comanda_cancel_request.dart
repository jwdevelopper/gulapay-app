class ItemComandaCancelRequest {
  const ItemComandaCancelRequest({required this.motivo});

  final String motivo;

  Map<String, dynamic> toJson() => {'motivo': motivo};
}
