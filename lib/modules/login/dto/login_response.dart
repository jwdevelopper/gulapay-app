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
    token = json['accessToken'] ?? json['token'];
    tokenType = json['tokenType'];
    expiresIn = json['expiresInMinutes']?.toString() ?? json['expiresIn'];
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
    data['accessToken'] = token;
    data['tokenType'] = tokenType;
    data['expiresInMinutes'] = expiresIn;
    data['message'] = message;
    data['error'] = error;
    data['statusCode'] = statusCode;
    data['detail'] = detail;
    data['usuarioId'] = usuarioId;
    data['login'] = login;
    data['nome'] = nome;
    data['perfil'] = perfil;
    return data;
  }
}
