import 'cliente_endereco.dart';

class ClienteUpdateRequest {
  String? nome;
  String? telefone;
  String? email;
  ClienteEndereco? endereco;
  bool? ativo;

  ClienteUpdateRequest({
    this.nome,
    this.telefone,
    this.email,
    this.endereco,
    this.ativo,
  });

  ClienteUpdateRequest.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    telefone = json['telefone'];
    email = json['email'];
    endereco = json['endereco'] != null ? ClienteEndereco.fromJson(json['endereco']) : null;
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['telefone'] = this.telefone;
    data['email'] = this.email;
    data['endereco'] = this.endereco?.toJson();
    data['ativo'] = this.ativo;
    return data;
  }
}