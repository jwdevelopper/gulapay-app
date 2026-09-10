class EntregadorResponse {
  final int? id;
  final String nome;
  final String telefone;
  final bool ativo;

  const EntregadorResponse({
    this.id,
    required this.nome,
    required this.telefone,
    required this.ativo,
  });

  factory EntregadorResponse.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final ativoRaw = json['ativo'];

    return EntregadorResponse(
      id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? ''),
      nome: json['nome']?.toString() ?? '',
      telefone: json['telefone']?.toString() ?? '',
      ativo: ativoRaw is bool ? ativoRaw : ativoRaw?.toString() == 'true',
    );
  }

  EntregadorResponse copyWith({
    int? id,
    String? nome,
    String? telefone,
    bool? ativo,
  }) {
    return EntregadorResponse(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      ativo: ativo ?? this.ativo,
    );
  }
}
