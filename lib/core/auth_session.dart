import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:my_app_teste/core/api_client.dart';

class SessaoAutenticacao {
  SessaoAutenticacao._();

  static Future<Map<String, dynamic>> dados() async {
    final token = await ApiClient.getToken();
    if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
      return {};
    }
    return JwtDecoder.decode(token);
  }

  static Future<String?> obterPerfil() async =>
      (await dados())['perfil'] as String?;

  static Future<String?> obterLogin() async =>
      (await dados())['sub'] as String?;

  static Future<bool> ehAdministrador() async =>
      (await obterPerfil()) == 'ADMINISTRADOR';
}
