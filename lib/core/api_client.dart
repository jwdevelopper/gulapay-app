import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_teste/core/constants_api.dart';

class ApiClient {
  ApiClient._();

  static const String _tokenKey = 'access_token';

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final options = BaseOptions(
      baseUrl: ConstantsApi.baseUrl + ConstantsApi.porta,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    final dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // don't attach token to login/register endpoints
            if (!options.path.contains(ConstantsApi.urlLogin) &&
                !options.path.contains(ConstantsApi.urlRegistrarUsuario)) {
              final token = await getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          } catch (_) {}
          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removerToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
