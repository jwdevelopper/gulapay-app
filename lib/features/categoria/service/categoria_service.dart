import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/features/categoria/model/categoria_dto.dart';

class CategoriaService {
  final Dio dio = ApiClient.dio;

  Future<List<CategoriaDto>> listarCategorias({bool apenasAtivas = false}) async {
    try {
      final response = await dio.get(
        ConstantsApi.urlCategorias,
        queryParameters: {"apenasAtivas": apenasAtivas},
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

  Future<CategoriaDto> criarCategoria(CategoriaDto categoria) async {
    try {
      final response = await dio.post(
        ConstantsApi.urlCategorias,
        data: categoria.toJson(),
      );
      return CategoriaDto.fromJson(response.data);
    } on DioException catch (e) {
      return _tratarErroDio(e);
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
      return _tratarErroDio(e);
    }
  }

  /// Inativa a categoria (soft delete). A categoria fica com ativo=false
  /// mas continua no banco, podendo ser reativada depois.
  Future<CategoriaDto> inativarCategoria(int id) async {
    try {
      await dio.delete('${ConstantsApi.urlCategorias}/$id');
      return CategoriaDto(nome: "Sucesso", message: "Categoria inativada com sucesso");
    } on DioException catch (e) {
      return _tratarErroDio(e);
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
      return _tratarErroDio(e);
    }
  }

  CategoriaDto _tratarErroDio(DioException e) {
    String mensagemErro = "Erro de conexão ou servidor indisponível.";

    if (e.response != null) {
      if (e.response!.data != null &&
          e.response!.data.toString().trim().isNotEmpty) {
        if (e.response!.data is Map<String, dynamic>) {
          // Backend usa ProblemDetail (RFC 7807): campo "detail" tem a mensagem
          mensagemErro = e.response!.data['detail'] ??
              e.response!.data['message'] ??
              e.response!.data['error'] ??
              "Erro ${e.response!.statusCode}: Acesso negado ou dados inválidos.";
        } else {
          mensagemErro = e.response!.data.toString();
        }
      } else {
        switch (e.response!.statusCode) {
          case 403:
            mensagemErro = "Acesso Negado (403). Seu usuário é ADMINISTRADOR?";
            break;
          case 401:
            mensagemErro = "Não Autorizado (401). Token inválido ou expirado.";
            break;
          case 400:
            mensagemErro = "Requisição inválida (400). Verifique os dados.";
            break;
          default:
            mensagemErro = "Erro no servidor (Status ${e.response!.statusCode}).";
        }
      }
    } else {
      mensagemErro = e.message ?? "Não foi possível conectar ao servidor.";
    }

    if (mensagemErro.trim().isEmpty) {
      mensagemErro = "Erro desconhecido ao comunicar com a API.";
    }

    return CategoriaDto(nome: "Erro", message: mensagemErro);
  }
}
