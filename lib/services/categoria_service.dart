import 'package:dio/dio.dart';
import 'package:my_app_teste/model/categoria_dto.dart';
import 'package:my_app_teste/utils/constants_api.dart';
import 'package:my_app_teste/utils/api_client.dart'; // Importe o seu ApiClient!

class CategoriaService {
  // 1. Usamos o Dio configurado que já possui o Interceptor com Token!
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

  // 2. Não precisamos mais passar o token por parâmetro nem no Options!
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

  Future<CategoriaDto> inativarCategoria(int id) async {
    try {
      await dio.delete('${ConstantsApi.urlCategorias}/$id');
      return CategoriaDto(nome: "Sucesso", message: "Categoria inativada com sucesso");
    } on DioException catch (e) {
      return _tratarErroDio(e);
    }
  }

  CategoriaDto _tratarErroDio(DioException e) {
    // Isso vai imprimir o erro real no console do seu VS Code / Android Studio
    print("=== ERRO NA API ===");
    print("Status Code: ${e.response?.statusCode}");
    print("Dados da Resposta: ${e.response?.data}");
    print("===================");
    
    String mensagemErro = "Erro de conexão ou servidor indisponível.";

    if (e.response != null) {
      if (e.response!.data != null && e.response!.data.toString().trim().isNotEmpty) {
        if (e.response!.data is Map<String, dynamic>) {
          mensagemErro = e.response!.data['message'] ?? 
                         e.response!.data['error'] ?? 
                         "Erro ${e.response!.statusCode}: Acesso negado ou dados inválidos.";
        } else {
          mensagemErro = e.response!.data.toString();
        }
      } else {
        if (e.response!.statusCode == 403) {
          mensagemErro = "Acesso Negado (403). Seu usuário é ADMINISTRADOR?";
        } else if (e.response!.statusCode == 401) {
          mensagemErro = "Não Autorizado (401). Token inválido ou expirado.";
        } else if (e.response!.statusCode == 400) {
          mensagemErro = "Requisição inválida (400). Verifique os dados.";
        } else {
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