import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/cliente_response.dart';
import '../dto/cliente_create_request.dart';
import '../dto/cliente_update_request.dart';

final _dio = ApiClient.dio;

Future<List<ClienteResponse>> listarClientes() async {
  try {
    final response = await _dio.get(ConstantsApi.urlClientes);
    return (response.data as List)
        .map((item) => ClienteResponse.fromJson(item))
        .toList();
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

// Cadastrar novo cliente
Future<ClienteResponse> criarCliente(ClienteCreateRequest dados) async {
  try {
    final response = await _dio.post(
      ConstantsApi.urlClientes,
      data: dados.toJson(),
    );
    return ClienteResponse.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}

// Editar cliente
Future<ClienteResponse> editarCliente(int id, ClienteUpdateRequest dados) async {
  try {
    final response = await _dio.put(
      '${ConstantsApi.urlClientes}/$id',
      data: dados.toJson(),
    );
    return ClienteResponse.fromJson(response.data);
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

// Reativar cliente
Future<ClienteResponse> reativarCliente(int id, ClienteResponse dados) async {
  final dto = ClienteUpdateRequest(
    nome: dados.nome,
    telefone: dados.telefone,
    email: dados.email,
    endereco: dados.endereco,
    ativo: true,
  );
  return editarCliente(id, dto);
}