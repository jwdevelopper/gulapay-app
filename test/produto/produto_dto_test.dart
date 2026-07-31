import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

void main() {
  group('Produto.fromJson', () {
    test('parses numeric values correctly', () {
      final produto = Produto.fromJson({
        'id': 10,
        'nome': 'Coxinha',
        'descricao': 'Salgado',
        'preco': 12.5,
        'tipoProduto': 'Unitario',
        'setorProducao': 'Cozinha',
        'categoriaId': 2,
        'ativo': true,
      });

      expect(produto.id, 10);
      expect(produto.nome, 'Coxinha');
      expect(produto.descricao, 'Salgado');
      expect(produto.preco, 12.5);
      expect(produto.tipoProduto, 'Unitario');
      expect(produto.setorProducao, 'Cozinha');
      expect(produto.categoriaId, 2);
      expect(produto.ativo, true);
    });

    test('parses string values and defaults', () {
      final produto = Produto.fromJson({
        'id': '11',
        'nome': null,
        'preco': '15.90',
        'categoriaId': '3',
        'ativo': 'true',
      });

      expect(produto.id, 11);
      expect(produto.nome, '');
      expect(produto.preco, 15.9);
      expect(produto.categoriaId, 3);
      expect(produto.ativo, true);
    });
  });

  group('Produto.toJson', () {
    test('omits ativo by default', () {
      final produto = Produto(nome: 'Pastel', ativo: false);
      final json = produto.toJson();

      expect(json['nome'], 'Pastel');
      expect(json.containsKey('ativo'), false);
    });

    test('includes ativo when forUpdate is true', () {
      final produto = Produto(nome: 'Pastel', ativo: false);
      final json = produto.toJson(forUpdate: true);

      expect(json['ativo'], false);
    });

    test('defaults ativo to true on update when null', () {
      final produto = Produto(nome: 'Pastel');
      final json = produto.toJson(forUpdate: true);

      expect(json['ativo'], true);
    });
  });
}
