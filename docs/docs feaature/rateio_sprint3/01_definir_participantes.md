# Rateio (1/4) — Definir participantes

`PATCH /comandas/{id}/participantes`

Backend pronto desde 2026-08-24 (Sprint 3). Este documento cobre só este endpoint — os outros 3 estão nos arquivos `02`, `03` e `04` desta mesma pasta. Contexto completo do domínio (o que é uma comanda `COMPARTILHADA`, por que ela tem `individuais`) está no `CLAUDE.md` seção 5.2 do repositório raiz.

## Quando o app chama isso

Depois que o Caixa (ou o garçom) monta uma mesa com uma comanda `COMPARTILHADA` e uma comanda `INDIVIDUAL` por pessoa sentada (cada uma criada com `comandaPaiId` apontando pra compartilhada), toda `INDIVIDUAL` já nasce marcada como participante do rateio (`participanteRateio = true` por padrão no backend). Esse endpoint só precisa ser chamado quando o Caixa **desmarca** alguém — o cenário "4 amigos, 3 comeram pizza": a pessoa que não participa é removida da lista antes de aplicar o rateio.

Pode ser chamado antes ou depois de fechar a comanda compartilhada, mas **não depois que o rateio já foi aplicado** — nesse caso o backend responde 422 e a tela precisa orientar o usuário a reverter primeiro (arquivo `04`).

## Contrato da API

**Papéis:** CAIXA, ADMIN (o backend rejeita com 403 qualquer outro perfil — não precisa nem tentar mostrar esse botão pro GARÇOM).

**Request body:**
```json
{
  "comandaIndividualIds": [101, 102]
}
```
Todo id de `INDIVIDUAL` que não estiver nessa lista é desmarcado. É uma substituição completa do conjunto de participantes, não um incremento — sempre mande a lista inteira de quem participa.

**Response — `200 OK`:**
```json
{
  "comandaId": 55,
  "codigo": "M-12-001",
  "estrategia": null,
  "totalLiquido": 87.50,
  "participantes": [
    { "comandaIndividualId": 101, "codigo": "M-12-002", "clienteNome": "Ana", "participante": true,  "valorProprio": 0.00, "valorRateio": 0.00, "valorTotal": 0.00 },
    { "comandaIndividualId": 102, "codigo": "M-12-003", "clienteNome": "Bia", "participante": true,  "valorProprio": 0.00, "valorRateio": 0.00, "valorTotal": 0.00 },
    { "comandaIndividualId": 103, "codigo": "M-12-004", "clienteNome": "Caio","participante": false, "valorProprio": 0.00, "valorRateio": 0.00, "valorTotal": 0.00 }
  ]
}
```
`valorRateio` continua zerado aqui — este endpoint só marca quem participa, não calcula nada (isso é o arquivo `02`).

**Erros esperados:**
| Status | Quando | Mensagem (`detail`, já pronta pra exibir) |
|---|---|---|
| 404 | `id` não é uma comanda existente | "Comanda não encontrada: {id}" |
| 422 | a comanda não é `COMPARTILHADA` | "Rateio só se aplica a comandas COMPARTILHADA (...)" |
| 422 | rateio já foi aplicado | "Rateio já aplicado nesta comanda — reverta antes de alterar participantes." |
| 403 | usuário logado não é CAIXA/ADMIN | "Apenas Caixa/Admin podem gerenciar o rateio de uma comanda." |

Todas essas mensagens já vêm prontas no campo `detail` do corpo RFC 7807 — `ApiError.fromDioException` (`lib/core/api_error.dart`) já extrai isso automaticamente, não precisa mapear status code manualmente na tela.

## DTOs Dart sugeridos

Local sugerido: `lib/modules/rateio/dto/`. Os DTOs de resposta (`RateioComandaResponse` e `RateioParticipanteResponse`) são compartilhados pelos 4 endpoints — defina uma vez só e importe nos outros services.

`lib/modules/rateio/dto/rateio_comanda_response.dart`:
```dart
class RateioParticipanteResponse {
  final int comandaIndividualId;
  final String codigo;
  final String? clienteNome;
  final bool participante;
  final double valorProprio;
  final double valorRateio;
  final double valorTotal;

  const RateioParticipanteResponse({
    required this.comandaIndividualId,
    required this.codigo,
    required this.clienteNome,
    required this.participante,
    required this.valorProprio,
    required this.valorRateio,
    required this.valorTotal,
  });

  factory RateioParticipanteResponse.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return RateioParticipanteResponse(
      comandaIndividualId: json['comandaIndividualId'] as int,
      codigo: json['codigo']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString(),
      participante: json['participante'] == true,
      valorProprio: asDouble(json['valorProprio']),
      valorRateio: asDouble(json['valorRateio']),
      valorTotal: asDouble(json['valorTotal']),
    );
  }
}

class RateioComandaResponse {
  final int comandaId;
  final String codigo;
  final String? estrategia; // null = ainda não aplicado
  final double totalLiquido;
  final List<RateioParticipanteResponse> participantes;

  const RateioComandaResponse({
    required this.comandaId,
    required this.codigo,
    required this.estrategia,
    required this.totalLiquido,
    required this.participantes,
  });

  factory RateioComandaResponse.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return RateioComandaResponse(
      comandaId: json['comandaId'] as int,
      codigo: json['codigo']?.toString() ?? '',
      estrategia: json['estrategia']?.toString(),
      totalLiquido: asDouble(json['totalLiquido']),
      participantes: (json['participantes'] as List? ?? [])
          .whereType<Map>()
          .map((p) => RateioParticipanteResponse.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}
```

`lib/modules/rateio/dto/rateio_participantes_request.dart`:
```dart
class RateioParticipantesRequest {
  final List<int> comandaIndividualIds;

  const RateioParticipantesRequest({required this.comandaIndividualIds});

  Map<String, dynamic> toJson() => {'comandaIndividualIds': comandaIndividualIds};
}
```

## Método de serviço sugerido

`lib/modules/rateio/service/rateio_service.dart` (mesmo padrão de `EntregadorService` — Dio via `ApiClient.dio`, erros convertidos com `ApiError.fromDioException`):

```dart
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
      return RateioComandaResponse.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  // aplicarRateio, buscarRateio, reverterRateio — ver arquivos 02, 03, 04.
}
```

Adicione `urlComandas = "/comandas"` em `ConstantsApi` se ainda não existir (hoje o app não tem nenhuma constante de Comanda — ver `PLANO.md` Fase B na raiz do repositório, que trata da integração completa do app com a Sprint 2/3).

## Onde encaixa na UI

Sugestão: um bottom sheet ou tela de "Fechar conta da mesa" (chamado a partir de `mesa_order_page.dart`, que hoje simula esse fluxo localmente — ver nota abaixo) mostrando a lista de comandas individuais da mesa como checkboxes marcados por padrão (`participante: true`), permitindo desmarcar quem não vai pagar. Um botão "Avançar para o rateio" chama este PATCH e leva para a tela do arquivo `02`.

**Atenção:** `mesa_order_page.dart` hoje tem um fluxo "provisório" de comanda inteiramente local/simulado (comentário no próprio código-fonte). Esse fluxo precisa ser substituído por chamadas reais à API antes de plugar esta tela de rateio — do contrário não existirá `comandaId` real para passar aqui.
