import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/lote/dto/lote_create_request.dart';
import 'package:my_app_teste/modules/lote/dto/lote_patch.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_update.dart';

class LoteService {
  final _dio = ApiClient.dio;

  Future<LoteResponse> criar(LoteCreateRequest criarReq) async {
    try {
      final resposta = await _dio.post(
        ConstantsApi.urlLotes,
        data: criarReq.toJson(),
      );
      return LoteResponse.fromJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Lista os lotes de um insumo. O backend exige `insumoId` e devolve os
  /// lotes já ordenados por validade (FEFO). Busca por código/insumo e
  /// filtros por validade são aplicados no cliente.
  Future<List<LoteResponse>> listar({required int insumoId}) async {
    try {
      final resposta = await _dio.get(
        ConstantsApi.urlLotes,
        queryParameters: <String, dynamic>{'insumoId': insumoId},
      );

      final dados = resposta.data;
      if (dados is List) {
        return dados.cast<Map<String, dynamic>>().map(LoteResponse.fromJson).toList();
      }
      if (dados is Map && dados['data'] is List) {
        return (dados['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(LoteResponse.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<LoteResponse> buscarPorId(int id) async {
    try {
      final resposta = await _dio.get('${ConstantsApi.urlLotes}/$id');
      return LoteResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<LoteResponse> atualizar(int id, LoteUpdate update) async {
    try {
      final resposta = await _dio.put(
        '${ConstantsApi.urlLotes}/$id',
        data: update.toJson(),
      );
      return LoteResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<LoteResponse> patch(int id, LotePatch patch) async {
    try {
      final resposta = await _dio.patch(
        '${ConstantsApi.urlLotes}/$id',
        data: patch.toJson(),
      );
      return LoteResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<LoteResponse> alterarStatus(int id, bool ativo) async {
    return patch(id, LotePatch(ativo: ativo));
  }

  Future<void> excluir(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlLotes}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
