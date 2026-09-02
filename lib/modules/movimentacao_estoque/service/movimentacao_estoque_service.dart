import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';

class MovimentacaoEstoqueService {
  final _dio = ApiClient.dio;

  Future<List<dynamic>> listarInsumos({
    bool apenasAtivos = false,
    bool abaixoDoMinimo = false,
  }) async {
    try {
      final response = await _dio.get('/insumos', queryParameters: {
        'apenasAtivos': apenasAtivos,
        'abaixoDoMinimo': abaixoDoMinimo,
      });
      if (response.data is List) return List<dynamic>.from(response.data as List);
      if (response.data is Map && response.data['data'] is List) {
        return List<dynamic>.from(response.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> buscarInsumo(int id) async {
    try {
      final response = await _dio.get('/insumos/$id');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> listarMovimentacoes(int insumoId) async {
    try {
      final response = await _dio.get('/movimentacoes-estoque',
          queryParameters: {'insumoId': insumoId});
      if (response.data is List) return List<dynamic>.from(response.data as List);
      if (response.data is Map && response.data['data'] is List) {
        return List<dynamic>.from(response.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> criarMovimentacao(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/movimentacoes-estoque', data: payload);
      if (response.data is List) return List<dynamic>.from(response.data as List);
      if (response.data is Map) return [Map<String, dynamic>.from(response.data as Map)];
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> listarLotes(int insumoId) async {
    try {
      final response =
          await _dio.get('/lotes', queryParameters: {'insumoId': insumoId});
      if (response.data is List) return List<dynamic>.from(response.data as List);
      if (response.data is Map && response.data['data'] is List) {
        return List<dynamic>.from(response.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> listarUnidades({String? tipoMedida}) async {
    try {
      final params = <String, dynamic>{'apenasAtivas': false};
      if (tipoMedida != null) params['tipoMedida'] = tipoMedida;
      final response =
          await _dio.get('/unidades-medida', queryParameters: params);
      if (response.data is List) return List<dynamic>.from(response.data as List);
      if (response.data is Map && response.data['data'] is List) {
        return List<dynamic>.from(response.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
