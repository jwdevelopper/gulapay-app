import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/mesa/dto/mesa_dto.dart';

class MesaService {
  final _dio = ApiClient.dio;

  Future<List<MesaDto>> listarMesas() async {
    try {
      final response = await _dio.get(ConstantsApi.urlMesas);
      
      final List<dynamic> data = response.data;
      return data.map((json) => MesaDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaDto> buscarMesaPorId(int id) async {
    try {
      final response = await _dio.get('${ConstantsApi.urlMesas}/$id');
      
      return MesaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaDto> criarMesa(MesaDto mesa) async {
    try {
      final response = await _dio.post(
        ConstantsApi.urlMesas,
        data: mesa.toJson(),
      );
      
      return MesaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<MesaDto> atualizarMesa(int id, MesaDto mesa) async {
    try {
      final response = await _dio.put(
        '${ConstantsApi.urlMesas}/$id',
        data: mesa.toJson(),
      );
      
      return MesaDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> inativarMesa(int id) async {
    try {
      await _dio.delete('${ConstantsApi.urlMesas}/$id');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}