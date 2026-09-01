class ComandaCreateRequest {
  const ComandaCreateRequest({
    required this.tipoOrigem,
    this.escopo,
    this.clienteId,
    this.mesaId,
    this.garcomId,
    this.enderecoEntregaId,
    this.comandaPaiId,
    this.observacao,
  });

  final String tipoOrigem;
  final String? escopo;
  final int? clienteId;
  final int? mesaId;
  final int? garcomId;
  final int? enderecoEntregaId;
  final int? comandaPaiId;
  final String? observacao;

  Map<String, dynamic> toJson() => {
        'tipoOrigem': tipoOrigem,
        if (escopo != null) 'escopo': escopo,
        if (clienteId != null) 'clienteId': clienteId,
        if (mesaId != null) 'mesaId': mesaId,
        if (garcomId != null) 'garcomId': garcomId,
        if (enderecoEntregaId != null) 'enderecoEntregaId': enderecoEntregaId,
        if (comandaPaiId != null) 'comandaPaiId': comandaPaiId,
        if (observacao?.trim().isNotEmpty == true) 'observacao': observacao!.trim(),
      };
}
