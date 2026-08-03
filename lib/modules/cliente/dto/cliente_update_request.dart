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

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'telefone': telefone,
        'email': email,
        'endereco': endereco?.toJson(),
        'ativo': ativo,
      };
}
