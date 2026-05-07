class ResponseCadastrarUsuario {
  String? message;
  String? error;
  int? statusCode;
  String? id;
  String? name;
  String? email;
  String? role;
  String? createdAt;

  ResponseCadastrarUsuario(
      {this.message,
      this.error,
      this.statusCode,
      this.id,
      this.name,
      this.email,
      this.role,
      this.createdAt});

  ResponseCadastrarUsuario.fromJson(Map<String, dynamic> json) {
    print("serializacao");
    print(json);
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['role'] = this.role;
    data['createdAt'] = this.createdAt;
    return data;
  }
}