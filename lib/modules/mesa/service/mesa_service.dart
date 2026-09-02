import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/mesa/dto/mesa_dto.dart';

class MesaServico {
  final _dio = ApiClient.dio;

  Future<List<MesaResposta>> listar() async {
    try {
      final resposta = await _dio.get(ConstantsApi.urlMesas);
      final lista = (resposta.data as List).cast<Map<String, dynamic>>();
      return lista.map(MesaResposta.deJson).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaResposta> buscarPorId(int id) async {
    try {
      final resposta = await _dio.get('${ConstantsApi.urlMesas}/$id');
      return MesaResposta.deJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaResposta> criar(MesaSalvarRequisicao requisicao) async {
    try {
      final resposta = await _dio.post(
        ConstantsApi.urlMesas,
        data: requisicao.paraJson(),
      );
      return MesaResposta.deJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaResposta> atualizar(
    int id,
    MesaSalvarRequisicao requisicao,
  ) async {
    try {
      final resposta = await _dio.put(
        '${ConstantsApi.urlMesas}/$id',
        data: requisicao.paraJson(),
      );
      return MesaResposta.deJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> inativar(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlMesas}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // Mantem a API usada pela tela de comandas sem alterar codigo fora de mesas.
  Future<List<MesaResposta>> listarMesas() => listar();
}

typedef MesaService = MesaServico;
