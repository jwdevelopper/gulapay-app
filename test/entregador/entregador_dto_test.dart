import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_create_request.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_update_request.dart';

void main() {
  group('EntregadorResponse', () {
    test('desserializa os campos retornados pela API', () {
      final entregador = EntregadorResponse.fromJson({
        'id': 12,
        'nome': 'Carlos Silva',
        'telefone': '11987654321',
        'ativo': true,
      });

      expect(entregador.id, 12);
      expect(entregador.nome, 'Carlos Silva');
      expect(entregador.telefone, '11987654321');
      expect(entregador.ativo, isTrue);
    });

    test('tolera id e ativo representados como texto', () {
      final entregador = EntregadorResponse.fromJson({
        'id': '7',
        'nome': 'Ana',
        'telefone': '1133334444',
        'ativo': 'true',
      });

      expect(entregador.id, 7);
      expect(entregador.ativo, isTrue);
    });
  });

  test('payload de criacao envia somente nome e telefone', () {
    const request = EntregadorCreateRequest(
      nome: 'Carlos Silva',
      telefone: '(11) 98765-4321',
    );

    expect(request.toJson(), {
      'nome': 'Carlos Silva',
      'telefone': '(11) 98765-4321',
    });
    expect(request.toJson().containsKey('id'), isFalse);
    expect(request.toJson().containsKey('ativo'), isFalse);
  });

  test('payload de atualizacao inclui o status obrigatorio', () {
    const request = EntregadorUpdateRequest(
      nome: 'Carlos Silva',
      telefone: '11987654321',
      ativo: false,
    );

    expect(request.toJson(), {
      'nome': 'Carlos Silva',
      'telefone': '11987654321',
      'ativo': false,
    });
    expect(request.toJson().containsKey('id'), isFalse);
  });
}
