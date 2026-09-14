import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';

/// Cliente HTTP dos 4 endpoints de rateio de comandas COMPARTILHADA
/// (Sprint 3 do backend). Todos os métodos convertem [DioException]
/// em [ApiError] pra facilitar o tratamento na UI.
class RateioService {
  final Dio _dio;

  RateioService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// `PATCH /comandas/{id}/participantes` — marca quais individuais
  /// participam do rateio. Papéis: CAIXA, ADMIN.
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

  /// `POST /comandas/{id}/rateio` — aplica a estratégia escolhida.
  /// Papéis: CAIXA, ADMIN. Exige comanda em AGUARDANDO_PAGAMENTO.
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

  /// `GET /comandas/{id}/rateio` — consulta o rateio (ou os
  /// participantes marcados, se ainda não aplicado). Papéis: CAIXA,
  /// ADMIN, GARCOM (só o dono da comanda).
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

  /// `POST /comandas/{id}/rateio/reverter` — desfaz o cálculo aplicado
  /// para permitir recalcular com outra estratégia. Papéis: CAIXA, ADMIN.
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
