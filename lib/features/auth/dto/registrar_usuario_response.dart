/// Resposta da API ao cadastrar um novo usuário.
class RegistrarUsuarioResponse {
  String? message;
  String? error;
  int? statusCode;
  String? id;
  String? name;
  String? email;
  String? role;
  String? createdAt;

  RegistrarUsuarioResponse({
    this.message,
    this.error,
    this.statusCode,
    this.id,
    this.name,
    this.email,
    this.role,
    this.createdAt,
  });

  RegistrarUsuarioResponse.fromJson(Map<String, dynamic> json) {
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
    return {
      'message': message,
      'error': error,
      'statusCode': statusCode,
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
