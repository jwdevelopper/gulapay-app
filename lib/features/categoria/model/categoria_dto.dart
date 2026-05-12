/// DTO de categoria usado tanto para receber dados da API
/// quanto para enviar criar/atualizar.
class CategoriaDto {
  String? message;
  String? error;
  int? statusCode;
  int? id;
  String nome;
  String? descricao;
  bool? ativo;

  CategoriaDto({
    this.message,
    this.error,
    this.statusCode,
    this.id,
    required this.nome,
    this.descricao,
    this.ativo,
  });

  CategoriaDto.fromJson(Map<String, dynamic> json) : nome = json['nome'] ?? '' {
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    id = json['id'];
    descricao = json['descricao'];
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    if (descricao != null) data['descricao'] = descricao;
    if (ativo != null) data['ativo'] = ativo;
    return data;
  }
}
