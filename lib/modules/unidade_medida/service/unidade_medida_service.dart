import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/unidade_medida_response.dart';
import '../dto/unidade_medida_create_request.dart';
import '../dto/unidade_medida_update_request.dart';

final _dio = ApiClient.dio;

Future<List<UnidadeMedidaResponse>> listarUnidadesMedida() async {
  try {
    final response = await _dio.get(ConstantsApi.urlUnidadesMedida);
    return (response.data as List)
        .map((item) => UnidadeMedidaResponse.fromJson(item))
        .toList();
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

Future<UnidadeMedidaResponse> criarUnidadeMedida(
    UnidadeMedidaCreateRequest dados) async {
  try {
    final response = await _dio.post(
      ConstantsApi.urlUnidadesMedida,
      data: dados.toJson(),
    );
    return UnidadeMedidaResponse.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

Future<UnidadeMedidaResponse> editarUnidadeMedida(
    int id, UnidadeMedidaUpdateRequest dados) async {
  try {
    final response = await _dio.put(
      '${ConstantsApi.urlUnidadesMedida}/$id',
      data: dados.toJson(),
    );
    return UnidadeMedidaResponse.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

Future<void> inativarUnidadeMedida(int id) async {
  try {
    await _dio.delete('${ConstantsApi.urlUnidadesMedida}/$id');
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

Future<UnidadeMedidaResponse> reativarUnidadeMedida(
    int id, UnidadeMedidaResponse dados) async {
  final dto = UnidadeMedidaUpdateRequest(
    nome: dados.nome ?? '',
    simbolo: dados.simbolo ?? '',
    ativo: true,
  );
  return editarUnidadeMedida(id, dto);
}
