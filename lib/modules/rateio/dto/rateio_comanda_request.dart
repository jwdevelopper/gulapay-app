/// Estratégias de rateio (enum espelho do backend). O valor string em
/// [valorApi] é o que a API espera receber/devolver.
enum EstrategiaRateio {
  semRateio,
  igualitario,
  manual,
  proporcional,
  porItem;

  String get valorApi => switch (this) {
        EstrategiaRateio.semRateio => 'SEM_RATEIO',
        EstrategiaRateio.igualitario => 'IGUALITARIO',
        EstrategiaRateio.manual => 'MANUAL',
        EstrategiaRateio.proporcional => 'PROPORCIONAL',
        EstrategiaRateio.porItem => 'POR_ITEM',
      };

  String get rotulo => switch (this) {
        EstrategiaRateio.semRateio => 'Sem rateio',
        EstrategiaRateio.igualitario => 'Igualitário',
        EstrategiaRateio.manual => 'Manual',
        EstrategiaRateio.proporcional => 'Proporcional',
        EstrategiaRateio.porItem => 'Por item',
      };

  String get descricao => switch (this) {
        EstrategiaRateio.semRateio =>
          'Uma única pessoa paga a comanda inteira.',
        EstrategiaRateio.igualitario =>
          'Divide o total em partes iguais entre os participantes.',
        EstrategiaRateio.manual =>
          'Caixa informa quanto cada um paga (soma deve fechar com o total).',
        EstrategiaRateio.proporcional =>
          'Pondera pelo total consumido (itens próprios) de cada participante.',
        EstrategiaRateio.porItem =>
          'Cada item é atribuído a um ou mais consumidores.',
      };

  static EstrategiaRateio? fromApi(String? v) => switch (v) {
        null => null,
        'SEM_RATEIO' => EstrategiaRateio.semRateio,
        'IGUALITARIO' => EstrategiaRateio.igualitario,
        'MANUAL' => EstrategiaRateio.manual,
        'PROPORCIONAL' => EstrategiaRateio.proporcional,
        'POR_ITEM' => EstrategiaRateio.porItem,
        _ => null,
      };
}

/// Item de [RateioComandaRequest.valoresManuais] — estratégia MANUAL.
class RateioValorManualItem {
  final int comandaIndividualId;
  final double valor;

  const RateioValorManualItem({
    required this.comandaIndividualId,
    required this.valor,
  });

  Map<String, dynamic> toJson() => {
        'comandaIndividualId': comandaIndividualId,
        'valor': valor,
      };
}

/// Item de [RateioComandaRequest.itensConsumidores] — estratégia POR_ITEM.
/// Um item pode ter mais de um consumidor (pizza dividida entre 3).
class RateioConsumidoresItem {
  final int itemComandaId;
  final List<int> comandaIndividualIds;

  const RateioConsumidoresItem({
    required this.itemComandaId,
    required this.comandaIndividualIds,
  });

  Map<String, dynamic> toJson() => {
        'itemComandaId': itemComandaId,
        'comandaIndividualIds': comandaIndividualIds,
      };
}

/// Payload de `POST /comandas/{id}/rateio`. [valoresManuais] só é lido
/// quando `estrategia == MANUAL`; [itensConsumidores] só é lido quando
/// `estrategia == POR_ITEM`. Para as demais os dois campos são ignorados.
class RateioComandaRequest {
  final EstrategiaRateio estrategia;
  final List<RateioValorManualItem>? valoresManuais;
  final List<RateioConsumidoresItem>? itensConsumidores;

  const RateioComandaRequest({
    required this.estrategia,
    this.valoresManuais,
    this.itensConsumidores,
  });

  Map<String, dynamic> toJson() => {
        'estrategia': estrategia.valorApi,
        if (valoresManuais != null)
          'valoresManuais':
              valoresManuais!.map((v) => v.toJson()).toList(),
        if (itensConsumidores != null)
          'itensConsumidores':
              itensConsumidores!.map((v) => v.toJson()).toList(),
      };
}
