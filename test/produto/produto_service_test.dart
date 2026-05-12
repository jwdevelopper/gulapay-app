import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  DioAdapter _createAdapter() {
    final dio = ApiClient.dio;
    final adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    return adapter;
  }

  group('ProdutoService', () {
    test('criarProduto returns created data', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onPost(
        '/produtos',
        (server) => server.reply(201, {'id': 1, 'nome': 'X-Burger'}),
        data: {'nome': 'X-Burger'},
      );

      final result = await service.criarProduto({'nome': 'X-Burger'});
      expect(result['id'], 1);
      expect(result['nome'], 'X-Burger');
    });

    test('buscarPorId returns data', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onGet(
        '/produtos/5',
        (server) => server.reply(200, {'id': 5, 'nome': 'Suco'}),
      );

      final result = await service.buscarPorId(5);
      expect(result['id'], 5);
      expect(result['nome'], 'Suco');
    });

    test('listar returns list response', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onGet(
        '/produtos',
        (server) => server.reply(200, [
          {'id': 1, 'nome': 'Refrigerante'},
          {'id': 2, 'nome': 'Batata'},
        ]),
        queryParameters: {'apenasAtivos': true},
      );

      final result = await service.listar();
      expect(result.length, 2);
      expect(result.first['nome'], 'Refrigerante');
    });

    test('listar returns data list when wrapped', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onGet(
        '/produtos',
        (server) => server.reply(200, {
          'data': [
            {'id': 1, 'nome': 'Pao de queijo'},
          ],
        }),
        queryParameters: {'apenasAtivos': true, 'categoriaId': 7},
      );

      final result = await service.listar(categoriaId: 7);
      expect(result.length, 1);
      expect(result.first['nome'], 'Pao de queijo');
    });

    test('listar returns empty list for unexpected response', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onGet(
        '/produtos',
        (server) => server.reply(200, {'unexpected': true}),
        queryParameters: {'apenasAtivos': true},
      );

      final result = await service.listar();
      expect(result, isEmpty);
    });

    test('editarProduto returns updated data', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onPut(
        '/produtos/9',
        (server) => server.reply(200, {'id': 9, 'nome': 'Agua'}),
        data: {'nome': 'Agua'},
      );

      final result = await service.editarProduto(9, {'nome': 'Agua'});
      expect(result['id'], 9);
      expect(result['nome'], 'Agua');
    });

    test('excluirProduto completes without error', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onDelete(
        '/produtos/3',
        (server) => server.reply(204, null),
      );

      await service.excluirProduto(3);
    });

    test('throws ApiError on bad request', () async {
      final adapter = _createAdapter();
      final service = ProdutoService();

      adapter.onPost(
        '/produtos',
        (server) => server.reply(400, {'detail': 'Dados invalidos'}),
        data: {'nome': ''},
      );

      expect(
        () => service.criarProduto({'nome': ''}),
        throwsA(
          predicate(
            (error) =>
                error is ApiError &&
                error.statusCode == 400 &&
                error.message == 'Dados invalidos',
          ),
        ),
      );
    });
  });
}
