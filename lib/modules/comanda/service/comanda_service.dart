import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/comanda_create_request.dart';
import '../dto/comanda_patch_request.dart';
import '../dto/comanda_response.dart';

class ComandaService {
  final _dio = ApiClient.dio;

  Future<ComandaResponse> criar(ComandaCreateRequest request) => _mutate(() async =>
      ComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.post(ConstantsApi.urlComandas, data: request.toJson())).data as Map)));

  Future<List<ComandaResponse>> listar({String? status, String? tipoOrigem, int? mesaId, int? clienteId, int? garcomId, DateTime? dataInicio, DateTime? dataFim}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      if (tipoOrigem != null) params['tipoOrigem'] = tipoOrigem;
      if (mesaId != null) params['mesaId'] = mesaId;
      if (clienteId != null) params['clienteId'] = clienteId;
      if (garcomId != null) params['garcomId'] = garcomId;
      if (dataInicio != null) params['dataInicio'] = dataInicio.toIso8601String();
      if (dataFim != null) params['dataFim'] = dataFim.toIso8601String();
      final data = (await _dio.get(ConstantsApi.urlComandas, queryParameters: params)).data;
      final list = data is List ? data : data is Map && data['data'] is List ? data['data'] : const [];
      return (list as List).whereType<Map>().map((e) => ComandaResponse.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) { throw ApiError.fromDioException(e); }
  }

  Future<ComandaResponse> buscarPorId(int id) => _get('$id');
  Future<ComandaResponse> patch(int id, ComandaPatchRequest request) => _mutate(() async => ComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.patch('${ConstantsApi.urlComandas}/$id', data: request.toJson())).data as Map)));
  Future<ComandaResponse> fechar(int id) => _action(id, 'fechar');
  Future<ComandaResponse> cancelar(int id) => _action(id, 'cancelar');
  Future<ComandaResponse> reabrir(int id) => _action(id, 'reabrir');

  Future<ComandaResponse> _get(String path) => _mutate(() async => ComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.get('${ConstantsApi.urlComandas}/$path')).data as Map)));
  Future<ComandaResponse> _action(int id, String action) => _mutate(() async => ComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.post('${ConstantsApi.urlComandas}/$id/$action')).data as Map)));
  Future<ComandaResponse> _mutate(Future<ComandaResponse> Function() call) async { try { return await call(); } on DioException catch (e) { throw ApiError.fromDioException(e); } }
}
