import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_teste/core/constants_api.dart';

class ApiClient {
  ApiClient._();

  static const String _tokenKey = 'token';

  static final Dio dio = Dio(
    BaseOptions(baseUrl: ConstantsApi.baseUrl + ConstantsApi.porta),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains(ConstantsApi.urlLogin)) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString(_tokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );

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
