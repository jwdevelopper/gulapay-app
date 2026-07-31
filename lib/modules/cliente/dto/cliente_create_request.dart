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

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'endereco': endereco?.toJson(),
      };
}
