import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_create_request.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_update_request.dart';

class EntregadorService {
  final Dio _dio;

  EntregadorService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<EntregadorResponse>> listar({bool apenasAtivos = true}) async {
    try {
      final response = await _dio.get(
        ConstantsApi.urlEntregadores,
        queryParameters: {'apenasAtivos': apenasAtivos},
      );
      final data = response.data;
      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map(
            (item) =>
                EntregadorResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<EntregadorResponse> buscarPorId(int id) async {
    try {
      final response = await _dio.get('${ConstantsApi.urlEntregadores}/$id');
      return _converterResposta(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<EntregadorResponse> criar(EntregadorCreateRequest request) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlEntregadores,
        data: request.toJson(),
      );
      return _converterResposta(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<EntregadorResponse> atualizar(
    int id,
    EntregadorUpdateRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '${ConstantsApi.urlEntregadores}/$id',
        data: request.toJson(),
      );
      return _converterResposta(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> inativar(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlEntregadores}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  EntregadorResponse _converterResposta(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Resposta de entregador invalida.');
    }
    return EntregadorResponse.fromJson(Map<String, dynamic>.from(data));
  }
}
