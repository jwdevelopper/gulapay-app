class ResponseLogin {
  String? accessToken;
  String? tokenType;
  String? expiresIn;
  String? message;
  String? error;
  int? statusCode;
  String? detail;

  ResponseLogin({this.accessToken, this.tokenType, this.expiresIn, this.message, this.error, this.statusCode, this.detail});

  ResponseLogin.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'] ?? json['token'];
    tokenType = json['tokenType'];
    expiresIn = json['expiresInMinutes']?.toString() ?? json['expiresIn'];
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['tokenType'] = this.tokenType;
    data['expiresIn'] = this.expiresIn;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    data['detail'] = this.detail;
    return data;
  }
}
