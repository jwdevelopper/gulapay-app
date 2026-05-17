import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

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

  
}