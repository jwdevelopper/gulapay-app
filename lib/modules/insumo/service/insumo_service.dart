import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_patch.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';

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

  Future<List<InsumoResponse>> listar() async {
    try {
      final resposta = await _dio.get(ConstantsApi.urlInsumos);
      return (resposta.data as List)
        .map((item) => InsumoResponse.fromJson(item))
        .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> buscarPorId(int id) async {
    try {
      final resposta = await _dio.get('${ConstantsApi.urlInsumos}/$id');
      return InsumoResponse.fromJson(resposta.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> atualizar(int id, InsumoUpdate update) async {
    try {
      final resposta = await _dio.put('${ConstantsApi.urlInsumos}/$id', data: update.toJson());
      return InsumoResponse.fromJson(resposta.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<InsumoResponse> patch(int id, InsumoPatch patch) async {
    try {
      final resposta = await _dio.patch('${ConstantsApi.urlInsumos}/$id', data: patch.toJson());
      return InsumoResponse.fromJson(resposta.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlInsumos}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}