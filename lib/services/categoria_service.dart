import 'package:dio/dio.dart';
import 'package:my_app_teste/model/categoria_dto.dart';
import 'package:my_app_teste/utils/constants_api.dart';

class CategoriaService {
  late final Dio dio;

  CategoriaService() {
    dio = Dio(BaseOptions(
      baseUrl: ConstantsApi.baseUrl + ConstantsApi.porta,
    ));
  }

  Future<List<CategoriaDto>> listarCategorias({bool apenasAtivas = false}) async {
    try {
      final response = await dio.get(
        ConstantsApi.urlCategorias,
        queryParameters: {
          "apenasAtivas": apenasAtivas,
        },
      );

      List<dynamic> data = response.data;
      return data.map((json) => CategoriaDto.fromJson(json)).toList();

    } on DioException catch (e) {
      return [_tratarErroDio(e)]; 
    }
  }

  Future<CategoriaDto> buscarPorId(int id) async {
    try {
      final response = await dio.get('${ConstantsApi.urlCategorias}/$id');
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      return _tratarErroDio(e);
    }
  }

  Future<CategoriaDto> criarCategoria(CategoriaDto categoria, String token) async {
    try {
      final response = await dio.post(
        ConstantsApi.urlCategorias,
        data: categoria.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      return _tratarErroDio(e);
    }
  }

  Future<CategoriaDto> atualizarCategoria(int id, CategoriaDto categoria, String token) async {
    try {
      final response = await dio.put(
        '${ConstantsApi.urlCategorias}/$id',
        data: categoria.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      return _tratarErroDio(e);
    }
  }

  Future<CategoriaDto> inativarCategoria(int id, String token) async {
    try {
      await dio.delete(
        '${ConstantsApi.urlCategorias}/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return CategoriaDto(nome: "Sucesso", message: "Categoria inativada com sucesso");
    } on DioException catch (e) {
      return _tratarErroDio(e);
    }
  }

  CategoriaDto _tratarErroDio(DioException e) {
    print("Erro capturado no CategoriaService: $e");
    if (e.response != null) {
      if (e.response!.statusCode == 400 || e.response!.statusCode == 403) {
        return CategoriaDto(
          nome: "Erro", 
          message: e.response!.data['message'] ?? "Acesso negado ou erro nos dados."
        );
      } else if (e.response!.statusCode == 500) {
        return CategoriaDto(nome: "Erro", message: "Erro inesperado do servidor!");
      }
    }
    return CategoriaDto(nome: "Erro", message: e.toString());
  }
}
