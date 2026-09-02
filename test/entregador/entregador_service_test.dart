import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_create_request.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_update_request.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late EntregadorService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.gulapay.test'));
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    service = EntregadorService(dio: dio);
  });

  test('lista apenas entregadores ativos por padrao', () async {
    adapter.onGet(
      '/entregadores',
      (server) => server.reply(200, [
        {
          'id': 1,
          'nome': 'Ana Souza',
          'telefone': '11999990000',
          'ativo': true,
        },
      ]),
      queryParameters: {'apenasAtivos': true},
    );

    final result = await service.listar();

    expect(result, hasLength(1));
    expect(result.single.nome, 'Ana Souza');
  });

  test('cria com o payload especifico de criacao', () async {
    const request = EntregadorCreateRequest(
      nome: 'Bruno Lima',
      telefone: '(11) 98888-7777',
    );
    adapter.onPost(
      '/entregadores',
      (server) =>
          server.reply(200, {'id': 2, ...request.toJson(), 'ativo': true}),
      data: request.toJson(),
    );

    final result = await service.criar(request);

    expect(result.id, 2);
    expect(result.ativo, isTrue);
  });

  test('atualiza com nome, telefone e ativo', () async {
    const request = EntregadorUpdateRequest(
      nome: 'Bruno Lima',
      telefone: '11988887777',
      ativo: false,
    );
    adapter.onPut(
      '/entregadores/2',
      (server) => server.reply(200, {'id': 2, ...request.toJson()}),
      data: request.toJson(),
    );

    final result = await service.atualizar(2, request);

    expect(result.ativo, isFalse);
  });

  test('inativa pelo endpoint DELETE com id', () async {
    adapter.onDelete('/entregadores/3', (server) => server.reply(200, null));

    await service.inativar(3);
  });

  test('converte erro HTTP em ApiError', () async {
    adapter.onGet(
      '/entregadores',
      (server) => server.reply(401, {'detail': 'Token invalido'}),
      queryParameters: {'apenasAtivos': true},
    );

    expect(
      service.listar,
      throwsA(
        predicate(
          (error) =>
              error is ApiError &&
              error.statusCode == 401 &&
              error.message == 'Token invalido',
        ),
      ),
    );
  });
}
