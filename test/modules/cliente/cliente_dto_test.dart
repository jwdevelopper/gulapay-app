import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_create_request.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_endereco.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';

void main() {
  group('ClienteResponse', () {
    test('carrega nome, telefone, bairro, complemento, cidade, numero e uf do endereco', () {
      final cliente = ClienteResponse.fromJson({
        'id': 10,
        'nome': 'Maria Souza',
        'telefone': '11999990000',
        'email': 'maria@email.com',
        'ativo': true,
        'endereco': {
          'logradouro': 'Avenida Paulista',
          'numero': '1578',
          'complemento': 'Apto 42',
          'bairro': 'Bela Vista',
          'cidade': 'São Paulo',
          'uf': 'SP',
          'cep': '01310-100',
        },
      });

      expect(cliente.nome, 'Maria Souza');
      expect(cliente.telefone, '11999990000');
      expect(cliente.endereco, isNotNull);
      expect(cliente.endereco!.numero, '1578');
      expect(cliente.endereco!.complemento, 'Apto 42');
      expect(cliente.endereco!.bairro, 'Bela Vista');
      expect(cliente.endereco!.cidade, 'São Paulo');
      expect(cliente.endereco!.uf, 'SP');
    });
  });

  group('ClienteCreateRequest', () {
    test('serializa nome, telefone, bairro, complemento, cidade, numero e uf no payload', () {
      final request = ClienteCreateRequest(
        nome: 'Maria Souza',
        telefone: '11999990000',
        endereco: ClienteEndereco(
          numero: '1578',
          complemento: 'Apto 42',
          bairro: 'Bela Vista',
          cidade: 'São Paulo',
          uf: 'SP',
        ),
      );

      final json = request.toJson();

      expect(json['nome'], 'Maria Souza');
      expect(json['telefone'], '11999990000');
      expect(json['endereco']['numero'], '1578');
      expect(json['endereco']['complemento'], 'Apto 42');
      expect(json['endereco']['bairro'], 'Bela Vista');
      expect(json['endereco']['cidade'], 'São Paulo');
      expect(json['endereco']['uf'], 'SP');
    });
  });
}
