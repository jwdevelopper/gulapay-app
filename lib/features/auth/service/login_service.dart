import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/features/auth/dto/login_response.dart';

class LoginService {
  final _dio = ApiClient.dio;

  Future<LoginResponse> efetuarLogin(String email, String password) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlLogin,
        data: {"login": email, "senha": password},
      );
      final loginResponse = LoginResponse.fromJson(response.data);

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
