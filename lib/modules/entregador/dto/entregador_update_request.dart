class EntregadorUpdateRequest {
  final String nome;
  final String telefone;
  final bool ativo;

  const EntregadorUpdateRequest({
    required this.nome,
    required this.telefone,
    required this.ativo,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'telefone': telefone,
    'ativo': ativo,
  };
}
