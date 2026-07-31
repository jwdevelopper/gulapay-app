class UnidadeMedidaResponse {
  final int? id;
  final String? nome;
  final String? simbolo;
  final String? tipoMedida;
  final double? fatorParaBase;
  final bool? ativo;

  const UnidadeMedidaResponse({
    this.id,
    this.nome,
    this.simbolo,
    this.tipoMedida,
    this.fatorParaBase,
    this.ativo,
  });

  factory UnidadeMedidaResponse.fromJson(Map<String, dynamic> json) =>
      UnidadeMedidaResponse(
        id: json['id'],
        nome: json['nome'],
        simbolo: json['simbolo'],
        tipoMedida: json['tipoMedida'],
        fatorParaBase: (json['fatorParaBase'] as num?)?.toDouble(),
        ativo: json['ativo'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'simbolo': simbolo,
        'tipoMedida': tipoMedida,
        'fatorParaBase': fatorParaBase,
        'ativo': ativo,
      };
}
