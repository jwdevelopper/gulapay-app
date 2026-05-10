class Categoria {
  int? id;
  String nome;
  String? descricao;
  bool? ativo;

  Categoria({this.id, required this.nome, this.descricao, this.ativo});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      ativo: json['ativo'] is bool ? json['ativo'] as bool : (json['ativo'] != null ? json['ativo'].toString() == 'true' : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
    };
  }
}
