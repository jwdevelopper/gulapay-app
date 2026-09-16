import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';

class RateioService {
  final Dio _dio;

  RateioService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<RateioComandaResponse> definirParticipantes(
    int comandaId,
    RateioParticipantesRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '${ConstantsApi.urlComandas}/$comandaId/participantes',
        data: request.toJson(),
      );
      return RateioComandaResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<RateioComandaResponse> aplicarRateio(
    int comandaId,
    RateioComandaRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '${ConstantsApi.urlComandas}/$comandaId/rateio',
        data: request.toJson(),
      );
      return RateioComandaResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<RateioComandaResponse> buscarRateio(int comandaId) async {
    try {
      final response = await _dio
          .get('${ConstantsApi.urlComandas}/$comandaId/rateio');
      return RateioComandaResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<RateioComandaResponse> reverterRateio(int comandaId) async {
    try {
      final response = await _dio.post(
          '${ConstantsApi.urlComandas}/$comandaId/rateio/reverter');
      return RateioComandaResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
