import 'package:my_app_teste/model/response_login.dart';
import 'package:dio/dio.dart';
import 'package:my_app_teste/utils/api_client.dart';
import 'package:my_app_teste/utils/api_error.dart';
import 'package:my_app_teste/utils/constants_api.dart';


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
      if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
        await ApiClient.salvarToken(loginResponse.token!);
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