class ItemComandaCreateRequest {
  const ItemComandaCreateRequest({
    required this.produtoId,
    required this.quantidade,
    this.valorDesconto,
    this.valorAcrescimo,
    this.observacao,
  });

  final int produtoId;
  final double quantidade;
  final double? valorDesconto;
  final double? valorAcrescimo;
  final String? observacao;

  Map<String, dynamic> toJson() => {
        'produtoId': produtoId,
        'quantidade': quantidade,
        if (valorDesconto != null) 'valorDesconto': valorDesconto,
        if (valorAcrescimo != null) 'valorAcrescimo': valorAcrescimo,
        if (observacao?.trim().isNotEmpty == true) 'observacao': observacao!.trim(),
      };
}
