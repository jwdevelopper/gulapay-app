# Rateio (4/4) — Reverter rateio

`POST /comandas/{id}/rateio/reverter`

Reaproveita o `RateioComandaResponse` definido em `01_definir_participantes.md`. Endpoint sem body.

## Quando o app chama isso

Sempre que o Caixa quiser trocar de estratégia depois de já ter aplicado uma (o backend não permite reaplicar por cima — ver `02_aplicar_rateio.md`), ou corrigir um erro de digitação num valor `MANUAL`/marcação `POR_ITEM`. É uma ação **destrutiva do cálculo**, não da comanda: zera o valor que cada `INDIVIDUAL` ia pagar e libera um novo cálculo, mas não mexe em itens, participantes marcados ou no total da compartilhada.

## Contrato da API

**Papéis:** CAIXA, ADMIN.

**Request:** sem body.

**Response — `200 OK`:** mesmo `RateioComandaResponse`, agora com `estrategia: null` e todo `valorRateio` zerado de novo — os participantes marcados (`participante: true/false`) continuam como estavam, só o cálculo é que volta à estaca zero.

**Erros esperados:**
| Status | Quando | Mensagem |
|---|---|---|
| 404 | comanda não existe | "Comanda não encontrada: {id}" |
| 422 | não havia nenhum rateio aplicado | "Nenhum rateio aplicado nesta comanda." |
| 422 | comanda não é `COMPARTILHADA` | "Rateio só se aplica a comandas COMPARTILHADA (...)" |
| 403 | perfil não é CAIXA/ADMIN | "Apenas Caixa/Admin podem gerenciar o rateio de uma comanda." |

## Método de serviço sugerido

Acrescente ao `RateioService` (fechando os 4 métodos do módulo):
```dart
Future<RateioComandaResponse> reverterRateio(int comandaId) async {
  try {
    final response = await _dio.post('${ConstantsApi.urlComandas}/$comandaId/rateio/reverter');
    return RateioComandaResponse.fromJson(Map<String, dynamic>.from(response.data));
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}
```

## Onde encaixa na UI

Um botão "Recalcular" (ou ícone de refazer) visível só quando a tela de rateio está no modo "resumo" (`estrategia != null`, ver `03_consultar_rateio.md`). Ao tocar:
1. Confirmar com o usuário antes de chamar — é uma ação que descarta um cálculo já feito (mostre um diálogo simples "Isso vai limpar o rateio calculado. Continuar?").
2. Chamar este endpoint.
3. Com o `200 OK`, voltar a tela para o modo formulário do arquivo `02` (o `response` já vem com `estrategia: null`, então dá pra reaproveitar a mesma lógica de decisão do arquivo `03`).

Não é necessário nenhum tratamento especial de 422 aqui além de mostrar `ApiError.message` — o caso mais comum (usuário aperta "Recalcular" duas vezes seguidas) é inofensivo de mostrar como erro, já que a segunda tentativa realmente não tem mais nada pra reverter.

---

## Resumo do módulo completo

Depois de implementar os 4 arquivos desta pasta, `lib/modules/rateio/` deve ter:
```
rateio/
├── dto/
│   ├── rateio_comanda_response.dart   (01 — RateioComandaResponse + RateioParticipanteResponse)
│   ├── rateio_participantes_request.dart (01)
│   └── rateio_comanda_request.dart    (02 — EstrategiaRateio + RateioValorManualItem + RateioConsumidoresItem)
├── service/
│   └── rateio_service.dart            (definirParticipantes, aplicarRateio, buscarRateio, reverterRateio)
└── page/ ou widget/
    └── (tela de rateio — a construir; não coberta por estes documentos, que tratam só do contrato de API + DTOs + service)
```

Pré-requisito de infraestrutura que **ainda falta no app** antes de qualquer uma dessas telas funcionar de verdade: `ConstantsApi.urlComandas` e o módulo `comanda/` completo (Sprint 2), já que todo endpoint de rateio pende de um `comandaId` real de uma comanda `COMPARTILHADA` fechada. Ver `PLANO.md` (raiz do repositório) seção "Fase B" para o roteiro dessa integração.
