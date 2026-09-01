class ComandaPatchRequest {
  const ComandaPatchRequest({this.observacao, this.garcomId, this.enderecoEntregaId});

  final String? observacao;
  final int? garcomId;
  final int? enderecoEntregaId;

  Map<String, dynamic> toJson() => {
        if (observacao != null) 'observacao': observacao,
        if (garcomId != null) 'garcomId': garcomId,
        if (enderecoEntregaId != null) 'enderecoEntregaId': enderecoEntregaId,
      };
}
