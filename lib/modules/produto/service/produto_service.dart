import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';

class ProdutoService {
  final _dio = ApiClient.dio;

  Future<Map<String, dynamic>> criarProduto(Map<String, dynamic> produto) async {
    try {
      final response = await _dio.post('/produtos', data: produto);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> buscarPorId(int id) async {
    try {
      final response = await _dio.get('/produtos/$id');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> listar({bool apenasAtivos = true, int? categoriaId}) async {
    try {
      final queryParameters = <String, dynamic>{'apenasAtivos': apenasAtivos};
      if (categoriaId != null) queryParameters['categoriaId'] = categoriaId;
      final response = await _dio.get('/produtos', queryParameters: queryParameters);
      if (response.data is List) return List<dynamic>.from(response.data as List);
      // some APIs wrap the list in an object
      if (response.data is Map && response.data['data'] is List) {
        return List<dynamic>.from(response.data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> editarProduto(int id, Map<String, dynamic> produto) async {
    try {
      final response = await _dio.put('/produtos/$id', data: produto);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> excluirProduto(int id) async {
    try {
      await _dio.delete('/produtos/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
