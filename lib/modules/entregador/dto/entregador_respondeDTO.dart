class entregador_responseDTO {
  int? id;
  String? nome;
  String? telefone;
  bool? ativo;

  entregador_responseDTO({this.id, this.nome, this.telefone, this.ativo});

  entregador_responseDTO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    telefone = json['telefone'];
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['ativo'] = ativo;
    return data;
  }
}
