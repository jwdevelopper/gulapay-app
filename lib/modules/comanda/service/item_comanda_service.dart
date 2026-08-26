import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import '../dto/evento_item_comanda_response.dart';
import '../dto/item_comanda_cancel_request.dart';
import '../dto/item_comanda_create_request.dart';
import '../dto/item_comanda_response.dart';
import '../dto/item_comanda_transfer_request.dart';
import '../dto/item_comanda_update_request.dart';

class ItemComandaService {
  final _dio = ApiClient.dio;

  Future<ItemComandaResponse> adicionar(int comandaId, ItemComandaCreateRequest request) => _mutate(() async =>
      ItemComandaResponse.fromJson(Map<String, dynamic>.from(
          (await _dio.post('${ConstantsApi.urlComandas}/$comandaId/itens', data: request.toJson())).data as Map)));

  Future<ItemComandaResponse> editar(int id, ItemComandaUpdateRequest request) => _mutate(() async =>
      ItemComandaResponse.fromJson(Map<String, dynamic>.from(
          (await _dio.patch('${ConstantsApi.urlItensComanda}/$id', data: request.toJson())).data as Map)));

  Future<ItemComandaResponse> marcarEntregue(int id) => _mutate(() async =>
      ItemComandaResponse.fromJson(Map<String, dynamic>.from(
          (await _dio.post('${ConstantsApi.urlItensComanda}/$id/entregar')).data as Map)));

  Future<ItemComandaResponse> transferir(int id, int comandaDestinoId) => _mutate(() async =>
      ItemComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.post(
        '${ConstantsApi.urlItensComanda}/$id/transferir',
        data: ItemComandaTransferRequest(comandaDestinoId: comandaDestinoId).toJson(),
      ))
              .data as Map)));

  Future<ItemComandaResponse> cancelar(int id, String motivo) => _mutate(() async =>
      ItemComandaResponse.fromJson(Map<String, dynamic>.from((await _dio.post(
        '${ConstantsApi.urlItensComanda}/$id/cancelar',
        data: ItemComandaCancelRequest(motivo: motivo).toJson(),
      ))
              .data as Map)));

  Future<List<EventoItemComandaResponse>> listarEventos(int id) async {
    try {
      final data = (await _dio.get('${ConstantsApi.urlItensComanda}/$id/eventos')).data;
      final list = data is List ? data : data is Map && data['data'] is List ? data['data'] : const [];
      return (list as List)
          .whereType<Map>()
          .map((e) => EventoItemComandaResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<ItemComandaResponse> _mutate(Future<ItemComandaResponse> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
