import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/features/categoria/model/categoria_dto.dart';

class CategoriaService {
  final Dio dio = ApiClient.dio;

  Future<List<CategoriaDto>> listarCategorias() async {
    try {
      final response = await dio.get(ConstantsApi.urlCategorias);
      final List<dynamic> data = response.data;
      return data.map((json) => CategoriaDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CategoriaDto> buscarPorId(int id) async {
    try {
      final response = await dio.get('${ConstantsApi.urlCategorias}/$id');
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CategoriaDto> criarCategoria(CategoriaDto categoria) async {
    try {
      final response = await dio.post(
        ConstantsApi.urlCategorias,
        data: categoria.toJson(),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<CategoriaDto> atualizarCategoria(int id, CategoriaDto categoria) async {
    try {
      final response = await dio.put(
        '${ConstantsApi.urlCategorias}/$id',
        data: categoria.toJson(),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Inativa a categoria (soft delete). A categoria fica com ativo=false
  /// mas continua no banco, podendo ser reativada depois.
  Future<void> inativarCategoria(int id) async {
    try {
      await dio.delete('${ConstantsApi.urlCategorias}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Reativa uma categoria inativa via PUT com ativo=true.
  Future<CategoriaDto> ativarCategoria(CategoriaDto categoria) async {
    try {
      final body = CategoriaDto(
        nome: categoria.nome,
        descricao: categoria.descricao,
        ativo: true,
      );
      final response = await dio.put(
        '${ConstantsApi.urlCategorias}/${categoria.id}',
        data: body.toJson(),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
