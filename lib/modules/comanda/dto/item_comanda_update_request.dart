class ItemComandaUpdateRequest {
  const ItemComandaUpdateRequest({
    this.quantidade,
    this.valorDesconto,
    this.valorAcrescimo,
    this.observacao,
  });

  final double? quantidade;
  final double? valorDesconto;
  final double? valorAcrescimo;
  final String? observacao;

  Map<String, dynamic> toJson() => {
        if (quantidade != null) 'quantidade': quantidade,
        if (valorDesconto != null) 'valorDesconto': valorDesconto,
        if (valorAcrescimo != null) 'valorAcrescimo': valorAcrescimo,
        if (observacao != null) 'observacao': observacao,
      };
}
