import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/categoria.dart';

class CategoriaService {
  final _dio = ApiClient.dio;

  Future<List<Categoria>> listar({bool apenasAtivos = true}) async {
    try {
      final response = await _dio.get(ConstantsApi.urlCategorias, queryParameters: {'apenasAtivos': apenasAtivos});
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

  Future<Categoria> buscarPorId(int id) async {
    try {
      final response = await _dio.get('${ConstantsApi.urlCategorias}/$id');
      return Categoria.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Categoria> criar(Categoria categoria) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlCategorias,
        data: categoria.toJson(),
      );
      return Categoria.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Categoria> atualizar(int id, Categoria categoria) async {
    try {
      final response = await _dio.put(
        '${ConstantsApi.urlCategorias}/$id',
        data: categoria.toJson(),
      );
      return Categoria.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Inativa a categoria (soft delete). Ela continua no banco com
  /// ativo=false e pode ser reativada depois.
  Future<void> inativar(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlCategorias}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Reativa uma categoria inativa via PUT com ativo=true.
  Future<Categoria> ativar(Categoria categoria) async {
    try {
      final body = Categoria(
        nome: categoria.nome,
        descricao: categoria.descricao,
        ativo: true,
      );
      final response = await _dio.put(
        '${ConstantsApi.urlCategorias}/${categoria.id}',
        data: body.toJson(),
      );
      return Categoria.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
