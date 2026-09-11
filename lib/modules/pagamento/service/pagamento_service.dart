import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/modules/pagamento/dto/pagamento_response.dart';

/// Pagamentos de uma comanda.
///
/// Fecha o ciclo de venda: quitada a comanda, ela sai de
/// `AGUARDANDO_PAGAMENTO` para `FECHADA` e a mesa é reavaliada — mas quem
/// faz isso é o backend; aqui só registramos e consultamos.
class PagamentoService {
  final _dio = ApiClient.dio;

  /// Registra um pagamento.
  ///
  /// Exige um caixa **aberto**, qualquer que seja a forma — sem isso a
  /// conferência de turno não teria como saber o que entrou. O backend
  /// também recusa valor acima do saldo restante: não há troco no MVP, o
  /// caixa informa o valor exato recebido.
  Future<PagamentoResponse> registrar(
    int comandaId, {
    required String formaPagamento,
    required double valor,
    String? observacao,
  }) async {
    try {
      final resposta = await _dio.post(
        '${ConstantsApi.urlComandas}/$comandaId/pagamentos',
        data: {
          'formaPagamento': formaPagamento,
          'valor': valor,
          if (observacao != null && observacao.trim().isNotEmpty)
            'observacao': observacao.trim(),
        },
      );
      return PagamentoResponse.fromJson(
        Map<String, dynamic>.from(resposta.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// O que a comanda deve, o que já foi pago e o que falta.
  Future<PagamentosDaComanda> consultar(int comandaId) async {
    try {
      final resposta = await _dio.get(
        '${ConstantsApi.urlComandas}/$comandaId/pagamentos',
      );
      return PagamentosDaComanda.fromJson(
        Map<String, dynamic>.from(resposta.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// Cancela um pagamento já registrado.
  ///
  /// Cancelar o pagamento de uma comanda fechada a traz de volta para
  /// `AGUARDANDO_PAGAMENTO`.
  Future<PagamentoResponse> cancelar(int pagamentoId, {String? motivo}) async {
    try {
      final resposta = await _dio.post(
        '${ConstantsApi.urlPagamentos}/$pagamentoId/cancelar',
        data: {if (motivo != null) 'motivo': motivo},
      );
      return PagamentoResponse.fromJson(
        Map<String, dynamic>.from(resposta.data as Map),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
