import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';

class ClienteService {
  final _dio = ApiClient.dio;

  // Buscar todos os clientes
  Future<List<dynamic>> listarClientes() async {
    try {
      final response = await _dio.get(ConstantsApi.urlClientes);
      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // Buscar cliente por ID
  Future<dynamic> buscarCliente(int id) async {
    try {
      final response = await _dio.get('${ConstantsApi.urlClientes}/$id');
      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // Cadastrar novo cliente
  Future<dynamic> criarCliente(Map<String, dynamic> dados) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlClientes,
        data: dados,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // Editar cliente
  Future<dynamic> editarCliente(int id, Map<String, dynamic> dados) async {
    try {
      final response = await _dio.put(
        '${ConstantsApi.urlClientes}/$id',
        data: dados,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // Inativar cliente
  Future<void> inativarCliente(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlClientes}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}