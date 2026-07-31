import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_create_request.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';

class UsuarioServico {
  final _dio = ApiClient.dio;

  Future<UsuarioResposta> criar(UsuarioCriarRequisicao requisicao) async {
    try {
      final resposta = await _dio.post(
        ConstantsApi.urlUsuarios,
        data: requisicao.paraJson(),
      );
      return UsuarioResposta.deJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<UsuarioResposta>> listar({String? perfil}) async {
    try {
      final resposta = await _dio.get(
        ConstantsApi.urlUsuarios,
        queryParameters: perfil == null ? null : {'perfil': perfil},
      );
      final lista = (resposta.data as List).cast<Map<String, dynamic>>();
      return lista.map(UsuarioResposta.deJson).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> deletar(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlUsuarios}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
