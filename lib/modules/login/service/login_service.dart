import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/login/dto/login_response.dart';

class LoginService {
  final _dio = ApiClient.dio;

  Future<ResponseLogin> efetuarLogin(String email, String password) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlLogin,
        data: {"login": email, "senha": password},
      );
      final loginResponse = ResponseLogin.fromJson(response.data);

      // Salva o token automaticamente após login bem-sucedido
      if (loginResponse.accessToken != null && loginResponse.accessToken!.isNotEmpty) {
        await ApiClient.salvarToken(loginResponse.accessToken!);
      }

      return loginResponse;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> logout() async {
    await ApiClient.removerToken();
  }
}
