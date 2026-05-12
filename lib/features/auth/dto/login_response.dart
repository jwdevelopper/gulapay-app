/// Resposta da API ao efetuar login.
/// O backend retorna `accessToken` e `expiresInMinutes`; mantemos
/// nomes amigáveis (token / expiresIn) no app.
class LoginResponse {
  String? token;
  String? tokenType;
  String? expiresIn;
  String? message;
  String? error;
  int? statusCode;
  String? detail;
  int? usuarioId;
  String? login;
  String? nome;
  String? perfil;

  LoginResponse({
    this.token,
    this.tokenType,
    this.expiresIn,
    this.message,
    this.error,
    this.statusCode,
    this.detail,
    this.usuarioId,
    this.login,
    this.nome,
    this.perfil,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    token = json['accessToken'] ?? json['token'];
    tokenType = json['tokenType'];
    expiresIn = (json['expiresInMinutes'] ?? json['expiresIn'])?.toString();
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    detail = json['detail'];
    usuarioId = json['usuarioId'];
    login = json['login'];
    nome = json['nome'];
    perfil = json['perfil'];
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': token,
      'tokenType': tokenType,
      'expiresInMinutes': expiresIn,
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'detail': detail,
      'usuarioId': usuarioId,
      'login': login,
      'nome': nome,
      'perfil': perfil,
    };
  }
}
