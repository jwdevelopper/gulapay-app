import 'cliente_endereco.dart';

class ClienteResponse {
  int? id;
  String? nome;
  String? telefone;
  String? email;
  String? linkWhatsApp;
  ClienteEndereco? endereco;
  bool? ativo;

  ClienteResponse({
    this.id,
    this.nome,
    this.telefone,
    this.email,
    this.linkWhatsApp,
    this.endereco,
    this.ativo,
  });

  ClienteResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    telefone = json['telefone'];
    email = json['email'];
    linkWhatsApp = json['linkWhatsApp'];
    endereco = json['endereco'] != null
        ? ClienteEndereco.fromJson(json['endereco'])
        : null;
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'linkWhatsApp': linkWhatsApp,
        'endereco': endereco?.toJson(),
        'ativo': ativo,
      };
}
