class UnidadeMedidaCreateRequest {
  final String nome;
  final String simbolo;
  final String tipoMedida;
  final double fatorParaBase;

  const UnidadeMedidaCreateRequest({
    required this.nome,
    required this.simbolo,
    required this.tipoMedida,
    required this.fatorParaBase,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'simbolo': simbolo,
        'tipoMedida': tipoMedida,
        'fatorParaBase': fatorParaBase,
      };
}
