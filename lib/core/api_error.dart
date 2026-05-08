import 'package:dio/dio.dart';

class ApiError implements Exception {
  final int? statusCode;
  final String message;

  ApiError({this.statusCode, required this.message});

  factory ApiError.fromDioException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? mensagem;
    if (data is Map) {
      mensagem = data['detail'] ?? data['message'] ?? data['error'];
    }

    mensagem ??= switch (status) {
      400 => 'Requisição inválida',
      401 => 'Não autorizado',
      403 => 'Acesso negado',
      404 => 'Recurso não encontrado',
      500 => 'Erro inesperado do servidor!',
      _ => _mensagemPadrao(e),
    };

    return ApiError(statusCode: status, message: mensagem);
  }

  static String _mensagemPadrao(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado';
      case DioExceptionType.connectionError:
        return 'Não foi possível conectar ao servidor';
      default:
        return 'Erro de comunicação com o servidor';
    }
  }

  @override
  String toString() => message;
}
