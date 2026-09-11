import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_create_request.dart';

/// Retrato dos dados do formulário de abertura de comanda.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e seleções, e o [ValidadorComanda] decide se a etapa pode
/// avançar. Mantém as regras por canal fora da árvore de widgets e permite
/// testá-las sem renderizar nada.
class DadosComanda {
  /// Canal de venda: `MESA`, `BALCAO` ou `DELIVERY`.
  final String tipo;

  /// `INDIVIDUAL` ou `COMPARTILHADA`. Só tem efeito em `MESA` — nos demais
  /// canais o backend força `INDIVIDUAL`.
  final String escopo;

  final int? mesaId;
  final int? garcomId;
  final ClienteResponse? cliente;
  final String observacao;

  const DadosComanda({
    this.tipo = canalMesa,
    this.escopo = escopoIndividual,
    this.mesaId,
    this.garcomId,
    this.cliente,
    this.observacao = '',
  });

  static const canalMesa = 'MESA';
  static const canalBalcao = 'BALCAO';
  static const canalDelivery = 'DELIVERY';

  static const escopoIndividual = 'INDIVIDUAL';
  static const escopoCompartilhada = 'COMPARTILHADA';

  bool get ehMesa => tipo == canalMesa;
  bool get ehDelivery => tipo == canalDelivery;

  /// O cliente escolhido tem endereço cadastrado? Pré-requisito do canal
  /// `DELIVERY`.
  bool get clienteTemEndereco => cliente?.endereco?.id != null;

  DadosComanda copiarCom({
    String? tipo,
    String? escopo,
    int? mesaId,
    int? garcomId,
    ClienteResponse? cliente,
    String? observacao,
  }) => DadosComanda(
    tipo: tipo ?? this.tipo,
    escopo: escopo ?? this.escopo,
    mesaId: mesaId ?? this.mesaId,
    garcomId: garcomId ?? this.garcomId,
    cliente: cliente ?? this.cliente,
    observacao: observacao ?? this.observacao,
  );

  /// Monta o payload de `POST /comandas`.
  ///
  /// Zera os campos que não pertencem ao canal — mesa e garçom só vão em
  /// `MESA`, endereço de entrega só em `DELIVERY` — para não enviar dado
  /// que o backend recusaria.
  ComandaCreateRequest paraRequisicao() => ComandaCreateRequest(
    tipoOrigem: tipo,
    escopo: ehMesa ? escopo : escopoIndividual,
    mesaId: ehMesa ? mesaId : null,
    garcomId: ehMesa ? garcomId : null,
    clienteId: cliente?.id,
    enderecoEntregaId: ehDelivery ? cliente?.endereco?.id : null,
    observacao: observacao.trim().isEmpty ? null : observacao.trim(),
  );
}

/// Regras de preenchimento por etapa do formulário de comanda.
///
/// As etapas são: 0 canal, 1 cliente, 2 dados da venda, 3 revisão. Só as
/// etapas 1 e 2 têm campos obrigatórios; as regras da 2 dependem do canal
/// escolhido na 0, espelhando o que o `ComandaService` do backend valida
/// (RN-COM-01..07).
class ValidadorComanda {
  const ValidadorComanda._();

  /// Devolve a mensagem de erro da etapa, ou `null` se ela pode avançar.
  static String? validarEtapa(int etapa, DadosComanda d) {
    if (etapa == 1) return _validarCliente(d);
    if (etapa == 2) return _validarDados(d);
    return null;
  }

  /// Cliente é obrigatório em todos os canais (RF20 — o telefone dele é o
  /// identificador do pedido).
  static String? _validarCliente(DadosComanda d) {
    if (d.cliente?.id == null) return 'Selecione o cliente da comanda.';
    return null;
  }

  static String? _validarDados(DadosComanda d) {
    if (d.ehMesa) {
      if (d.mesaId == null) return 'Selecione a mesa da comanda.';
      if (d.garcomId == null) {
        return 'Selecione o garçom responsável pela comanda.';
      }
    }
    if (d.ehDelivery && !d.clienteTemEndereco) {
      return 'Selecione um cliente com endereço cadastrado.';
    }
    return null;
  }
}
