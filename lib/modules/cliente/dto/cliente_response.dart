import 'cliente_endereco.dart';

class ClienteResponse {
  String? id;
  String? nome;
  String? telefone;
  String? email;
  String? linkWhatsApp;
  ClienteEndereco? endereco;
  bool? ativo;
  String? message;
  String? error;
  int? statusCode;
  String? detail;

  ClienteResponse({
    this.id,
    this.nome,
    this.telefone,
    this.email,
    this.linkWhatsApp,
    this.endereco,
    this.ativo,
    this.message,
    this.error,
    this.statusCode,
    this.detail,
  });

  ClienteResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    telefone = json['telefone'];
    email = json['email'];
    linkWhatsApp = json['linkWhatsApp'];
    endereco = json['endereco'] != null ? ClienteEndereco.fromJson(json['endereco']) : null;
    ativo = json['ativo'];
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['telefone'] = this.telefone;
    data['email'] = this.email;
    data['linkWhatsApp'] = this.linkWhatsApp;
    data['endereco'] = this.endereco?.toJson();
    data['ativo'] = this.ativo;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    data['detail'] = this.detail;
    return data;
  }
}