# Rateio (2/4) — Aplicar rateio

`POST /comandas/{id}/rateio`

Este é o endpoint central da Sprint 3 — a tela mais trabalhosa dos 4. Leia primeiro o arquivo `01_definir_participantes.md` (define quem participa antes de chegar aqui) e o `RateioComandaResponse`/`RateioParticipanteResponse` já definidos lá, que são reaproveitados por este endpoint.

## Quando o app chama isso

Só depois que a comanda `COMPARTILHADA` foi **fechada** (`POST /comandas/{id}/fechar`, endpoint da Sprint 2 que o app também ainda não consome — ver `PLANO.md` Fase B) e tem pelo menos 1 participante marcado. É o passo em que o Caixa escolhe a estratégia e confirma os valores antes de cada `INDIVIDUAL` ir para pagamento (Sprint 4, ainda não implementada).

## Contrato da API

**Papéis:** CAIXA, ADMIN.

**Pré-condições que o backend valida (o app deve orientar o usuário antes de deixar tentar):**
- comanda precisa estar `AGUARDANDO_PAGAMENTO` (feche a comanda antes);
- precisa ter ao menos 1 participante marcado (arquivo `01`);
- **só pode haver 1 estratégia aplicada por vez** — se o Caixa quiser trocar de estratégia depois de aplicar, primeiro chama o `04_reverter_rateio.md`.

**Request body** — o campo `estrategia` decide quais dos outros dois campos são obrigatórios:

| `estrategia` | Campos usados | Regra de validação no backend |
|---|---|---|
| `SEM_RATEIO` | nenhum | exige **exatamente 1** participante selecionado |
| `IGUALITARIO` | nenhum | divide em partes iguais; resto de centavos (se houver) vai pros primeiros participantes da lista — a soma sempre fecha com o total |
| `MANUAL` | `valoresManuais` | soma dos valores informados precisa bater **exatamente** com `totalLiquido` da comanda |
| `PROPORCIONAL` | nenhum | pondera pelo `totalLiquido` de itens **próprios** de cada participante; 422 se todos tiverem peso zero (ninguém pediu nada fora da compartilhada) |
| `POR_ITEM` | `itensConsumidores` | **todo** item ativo da comanda (não cancelado/transferido) precisa aparecer na lista, senão 422 |

Exemplo `MANUAL`:
```json
{
  "estrategia": "MANUAL",
  "valoresManuais": [
    { "comandaIndividualId": 101, "valor": 25.00 },
    { "comandaIndividualId": 102, "valor": 20.00 }
  ]
}
```

Exemplo `POR_ITEM`:
```json
{
  "estrategia": "POR_ITEM",
  "itensConsumidores": [
    { "itemComandaId": 900, "comandaIndividualIds": [101, 102] },
    { "itemComandaId": 901, "comandaIndividualIds": [101] }
  ]
}
```
Um item pode ter mais de um consumidor — o subtotal dele é dividido igualmente entre os marcados (mesma lógica de arredondamento do `IGUALITARIO`, resto de centavos pros primeiros da lista).

**Response — `200 OK`:** mesmo formato de `RateioComandaResponse` do arquivo `01`, agora com `estrategia` preenchida e `valorRateio`/`valorTotal` calculados em cada participante.

**Erros esperados (todos com `detail` pronto pra exibir):**
| Status | Quando |
|---|---|
| 422 | comanda não está `AGUARDANDO_PAGAMENTO` — "Feche a comanda (...) antes de aplicar o rateio" |
| 422 | rateio já aplicado — "Rateio já aplicado nesta comanda — reverta (...)" |
| 422 | nenhum participante — "Nenhum participante selecionado — use PATCH /comandas/{id}/participantes antes do rateio." |
| 422 | `SEM_RATEIO` com != 1 participante |
| 422 | `MANUAL` com soma errada, participante faltando ou id que não é participante |
| 422 | `PROPORCIONAL` sem nenhum peso |
| 422 | `POR_ITEM` com item sem consumidor marcado, ou apontando pra alguém que não é participante |
| 403 | perfil não é CAIXA/ADMIN |

## DTOs Dart sugeridos

`lib/modules/rateio/dto/rateio_comanda_request.dart`:
```dart
enum EstrategiaRateio { semRateio, igualitario, manual, proporcional, porItem }

extension EstrategiaRateioJson on EstrategiaRateio {
  String get valorApi => switch (this) {
        EstrategiaRateio.semRateio => 'SEM_RATEIO',
        EstrategiaRateio.igualitario => 'IGUALITARIO',
        EstrategiaRateio.manual => 'MANUAL',
        EstrategiaRateio.proporcional => 'PROPORCIONAL',
        EstrategiaRateio.porItem => 'POR_ITEM',
      };

  static EstrategiaRateio fromApi(String v) => switch (v) {
        'SEM_RATEIO' => EstrategiaRateio.semRateio,
        'IGUALITARIO' => EstrategiaRateio.igualitario,
        'MANUAL' => EstrategiaRateio.manual,
        'PROPORCIONAL' => EstrategiaRateio.proporcional,
        'POR_ITEM' => EstrategiaRateio.porItem,
        _ => throw ArgumentError('Estratégia de rateio desconhecida: $v'),
      };
}

class RateioValorManualItem {
  final int comandaIndividualId;
  final double valor;

  const RateioValorManualItem({required this.comandaIndividualId, required this.valor});

  Map<String, dynamic> toJson() => {
        'comandaIndividualId': comandaIndividualId,
        'valor': valor,
      };
}

class RateioConsumidoresItem {
  final int itemComandaId;
  final List<int> comandaIndividualIds;

  const RateioConsumidoresItem({required this.itemComandaId, required this.comandaIndividualIds});

  Map<String, dynamic> toJson() => {
        'itemComandaId': itemComandaId,
        'comandaIndividualIds': comandaIndividualIds,
      };
}

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
          'valoresManuais': valoresManuais!.map((v) => v.toJson()).toList(),
        if (itensConsumidores != null)
          'itensConsumidores': itensConsumidores!.map((v) => v.toJson()).toList(),
      };
}
```

## Método de serviço sugerido

Acrescente ao `RateioService` do arquivo `01`:
```dart
Future<RateioComandaResponse> aplicarRateio(
  int comandaId,
  RateioComandaRequest request,
) async {
  try {
    final response = await _dio.post(
      '${ConstantsApi.urlComandas}/$comandaId/rateio',
      data: request.toJson(),
    );
    return RateioComandaResponse.fromJson(Map<String, dynamic>.from(response.data));
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}
```

## Onde encaixa na UI

Sugestão de fluxo na tela de fechamento da mesa:
1. Seletor de estratégia (5 opções, com um texto curto explicando cada uma — reaproveite as descrições da tabela acima).
2. Formulário condicional: `MANUAL` mostra um campo de valor por participante com um total rodando (desabilita o botão "Aplicar" enquanto a soma não bater com `totalLiquido`, evitando o 422 antes mesmo de chamar a API); `POR_ITEM` mostra a lista de itens da comanda com chips de participantes pra marcar quem consumiu cada um.
3. `IGUALITARIO`, `PROPORCIONAL` e `SEM_RATEIO` não precisam de formulário — só um botão de confirmação com uma prévia do resultado (dá pra simular o cálculo no client antes de chamar a API, mas o valor que vale é sempre o que volta no `response`).
4. Depois do `200 OK`, mostrar a lista de `participantes` com `valorTotal` de cada um e um botão "Aplicar outra estratégia" que primeiro chama o `reverter` (arquivo `04`) antes de voltar ao passo 1.

Trate os 422 de validação (soma errada, item sem consumidor, etc.) como erro de formulário — `ApiError.message` já vem com o texto certo pra mostrar num `SnackBar` ou abaixo do campo relevante.
