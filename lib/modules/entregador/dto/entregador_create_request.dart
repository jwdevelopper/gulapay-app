class EntregadorCreateRequest {
  final String nome;
  final String telefone;

  const EntregadorCreateRequest({required this.nome, required this.telefone});

  Map<String, dynamic> toJson() => {'nome': nome, 'telefone': telefone};
}
