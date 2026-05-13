class ResponseLogin {
  String? token; // mapeado de accessToken da API
  String? tokenType;
  String? expiresIn; // armazenamos como string para compatibilidade
  String? message;
  String? error;
  int? statusCode;
  String? detail;
  int? usuarioId;
  String? login;
  String? nome;
  String? perfil;

  ResponseLogin({
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

  ResponseLogin.fromJson(Map<String, dynamic> json) {
    // API returns `accessToken` instead of `token`
    token = json['accessToken'] ?? json['token'];
    tokenType = json['tokenType'];
    // API uses `expiresInMinutes`
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = this.token;
    data['tokenType'] = this.tokenType;
    data['expiresInMinutes'] = this.expiresIn;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    data['detail'] = this.detail;
    data['usuarioId'] = this.usuarioId;
    data['login'] = this.login;
    data['nome'] = this.nome;
    data['perfil'] = this.perfil;
    return data;
  }
}
