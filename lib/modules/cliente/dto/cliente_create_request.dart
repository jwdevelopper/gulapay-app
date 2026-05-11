import 'cliente_endereco.dart';

class ClienteCreateRequest {
  String? nome;
  String? telefone;
  String? email;
  ClienteEndereco? endereco;

  ClienteCreateRequest({
    this.nome,
    this.telefone,
    this.email,
    this.endereco,
  });

  ClienteCreateRequest.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    telefone = json['telefone'];
    email = json['email'];
    endereco = json['endereco'] != null ? ClienteEndereco.fromJson(json['endereco']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['telefone'] = this.telefone;
    data['email'] = this.email;
    data['endereco'] = this.endereco?.toJson();
    return data;
  }
}