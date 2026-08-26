# Rateio (3/4) — Consultar rateio

`GET /comandas/{id}/rateio`

Reaproveita o `RateioComandaResponse` definido em `01_definir_participantes.md`. É o endpoint mais simples dos 4 — leitura pura, sem efeito colateral.

## Quando o app chama isso

Sempre que a tela de rateio abre ou é reaberta (não assume que o estado calculado na Fase B do PLANO.md ainda está fresco em memória — busque de novo). Serve tanto para mostrar o estado **antes** de aplicar (participantes marcados, tudo zerado) quanto **depois** (valores calculados por participante). Também é o endpoint certo para uma eventual tela do Garçom que só acompanha "quanto cada um vai pagar" sem poder alterar nada.

## Contrato da API

**Papéis:** CAIXA, ADMIN, **GARÇOM** (mas só o dono da comanda — o backend reaproveita a mesma regra de `GET /comandas/{id}`: um garçom só vê comandas que ele mesmo atende).

**Response — `200 OK`:** idêntico ao formato do arquivo `01`/`02`. Se `estrategia` vier `null`, o rateio ainda não foi calculado — todo `valorRateio` estará zerado e a tela deve levar o usuário para o fluxo do arquivo `02`.

```json
{
  "comandaId": 55,
  "codigo": "M-12-001",
  "estrategia": "IGUALITARIO",
  "totalLiquido": 87.50,
  "participantes": [
    { "comandaIndividualId": 101, "codigo": "M-12-002", "clienteNome": "Ana", "participante": true, "valorProprio": 0.00, "valorRateio": 43.75, "valorTotal": 43.75 },
    { "comandaIndividualId": 102, "codigo": "M-12-003", "clienteNome": "Bia", "participante": true, "valorProprio": 0.00, "valorRateio": 43.75, "valorTotal": 43.75 }
  ]
}
```

Note o campo `valorTotal` — é `valorProprio + valorRateio`, ou seja, já soma itens que a pessoa pediu por conta própria (fora da compartilhada) com a parte que ela deve da conta rateada. **É esse o número que a tela de pagamento (Sprint 4) vai cobrar de cada `INDIVIDUAL`**, não `valorRateio` isolado.

**Erros esperados:**
| Status | Quando |
|---|---|
| 404 | comanda não existe |
| 403 | garçom tentando ver comanda que não é dele |
| 422 | a comanda referenciada não é `COMPARTILHADA` (não faz sentido consultar rateio de uma `INDIVIDUAL` diretamente) |

## Método de serviço sugerido

Acrescente ao `RateioService`:
```dart
Future<RateioComandaResponse> buscarRateio(int comandaId) async {
  try {
    final response = await _dio.get('${ConstantsApi.urlComandas}/$comandaId/rateio');
    return RateioComandaResponse.fromJson(Map<String, dynamic>.from(response.data));
  } on DioException catch (e) {
    throw ApiError.fromDioException(e);
  }
}
```

## Onde encaixa na UI

Chame este `GET` no `initState`/entrada da tela de rateio (arquivo `02`) para carregar o estado atual antes de decidir o que mostrar: se `estrategia == null`, abre direto no formulário de escolha de estratégia; se já tem uma estratégia aplicada, abre num modo "resumo" (mostrando `participantes` com os valores calculados) com um botão "Recalcular" que dispara o fluxo de reverter (arquivo `04`) e volta pro formulário. Esse é o padrão mais simples de evitar que o usuário perca o resultado já calculado ao simplesmente reabrir a tela.
