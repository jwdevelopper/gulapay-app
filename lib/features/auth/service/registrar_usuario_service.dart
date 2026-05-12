import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/features/auth/dto/registrar_usuario_response.dart';

class RegistrarUsuarioService {
  final _dio = ApiClient.dio;

  Future<RegistrarUsuarioResponse> registrarUsuario(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlRegistrarUsuario,
        data: {"name": name, "email": email, "password": password},
      );
      return RegistrarUsuarioResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
