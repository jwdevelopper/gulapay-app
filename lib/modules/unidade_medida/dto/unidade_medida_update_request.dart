class UnidadeMedidaUpdateRequest {
  final String nome;
  final String simbolo;
  final bool ativo;

  const UnidadeMedidaUpdateRequest({
    required this.nome,
    required this.simbolo,
    required this.ativo,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'simbolo': simbolo,
        'ativo': ativo,
      };
}
