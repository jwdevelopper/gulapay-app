import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/registrar_usuario/dto/registrar_usuario_response.dart';

class RegistrarUsuarioService {
  final _dio = ApiClient.dio;

  Future<ResponseCadastrarUsuario> registrarUsuario(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlRegistrarUsuario,
        data: {"name": name, "email": email, "password": password},
      );
      return ResponseCadastrarUsuario.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
