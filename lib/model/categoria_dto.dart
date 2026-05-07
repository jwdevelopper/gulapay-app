class CategoriaDto {
  String? message;
  String? error;
  int? statusCode;
  int? id;
  String? nome;
  String? descricao;
  bool? ativo;
  

  CategoriaDto(
      {this.message,
      this.error,
      this.statusCode,
      this.id,
      this.nome,
      this.descricao,
      this.ativo});

  CategoriaDto.fromJson(Map<String, dynamic> json) {
    print("serializacao");
    print(json);
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    id = json['id'];
    nome = json['nome'];
    descricao = json['descricao'];
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['error'] = error;  
    data['statusCode'] = statusCode;
    data['id'] = id;
    data['nome'] = nome;
    data['descricao'] = descricao;

    data['ativo'] = ativo;

    return data;  
  }
}