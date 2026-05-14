class ResponseLogin {
  String? token;
  String? tokenType;
  String? expiresIn;
  String? message;
  String? error;
  int? statusCode;
  String? detail;

  ResponseLogin({this.token, this.tokenType, this.expiresIn, this.message, this.error, this.statusCode, this.detail});

  ResponseLogin.fromJson(Map<String, dynamic> json) {
    token = json['accessToken'] ?? json['token'];
    tokenType = json['tokenType'];
    expiresIn = json['expiresInMinutes']?.toString() ?? json['expiresIn'];
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['tokenType'] = this.tokenType;
    data['expiresIn'] = this.expiresIn;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    data['detail'] = this.detail;
    return data;
  }
}
