import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_patch.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';

class InsumoService {
  final _dio = ApiClient.dio;

  Future<InsumoResponse> criar(InsumoCreateRequest criarReq) async {
    try {
      final resposta = await _dio.post(
        ConstantsApi.urlInsumos,
        data: criarReq.toJson(),
      );
      return InsumoResponse.fromJson(resposta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<InsumoResponse>> listar({bool apenasAtivos = true, String? pesquisa}) async {
    try {
      final queryParameters = <String, dynamic>{'apenasAtivos': apenasAtivos};
      if (pesquisa != null && pesquisa.trim().isNotEmpty) {
        queryParameters['nome'] = pesquisa.trim();
      }

      final resposta = await _dio.get(
        ConstantsApi.urlInsumos,
        queryParameters: queryParameters,
      );

      final dados = resposta.data;
      if (dados is List) {
        return dados.cast<Map<String, dynamic>>().map(InsumoResponse.fromJson).toList();
      }
      if (dados is Map && dados['data'] is List) {
        return (dados['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(InsumoResponse.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> buscarPorId(int id) async {
    try {
      final resposta = await _dio.get('${ConstantsApi.urlInsumos}/$id');
      return InsumoResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> atualizar(int id, InsumoUpdate update) async {
    try {
      final resposta = await _dio.put(
        '${ConstantsApi.urlInsumos}/$id',
        data: update.toJson(),
      );
      return InsumoResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> patch(int id, InsumoPatch patch) async {
    try {
      final resposta = await _dio.patch(
        '${ConstantsApi.urlInsumos}/$id',
        data: patch.toJson(),
      );
      return InsumoResponse.fromJson(Map<String, dynamic>.from(resposta.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> alterarStatus(int id, bool ativo) async {
    return patch(id, InsumoPatch(ativo: ativo));
  }

  Future<List<LoteResponse>> listarLotes(int insumoId, {bool apenasAtivos = true}) async {
    try {
      final resposta = await _dio.get(
        '${ConstantsApi.urlInsumos}/$insumoId/lotes',
        queryParameters: {'apenasAtivos': apenasAtivos},
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

  Future<void> excluir(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlInsumos}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}