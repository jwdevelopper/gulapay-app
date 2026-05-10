import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import '../dto/categoria.dart';

class CategoriaService {
  final _dio = ApiClient.dio;

  Future<List<Categoria>> listar({bool apenasAtivos = true}) async {
    try {
      final response = await _dio.get('/categorias', queryParameters: {'apenasAtivos': apenasAtivos});
      if (response.data is List) {
        return (response.data as List).map((e) => Categoria.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List).map((e) => Categoria.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
