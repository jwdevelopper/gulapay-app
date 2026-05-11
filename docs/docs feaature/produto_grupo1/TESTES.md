# Testes do modulo Produto

Este documento descreve os testes unitarios do modulo Produto, incluindo o objetivo de cada teste e a metodologia aplicada.

## Metodologia

- Testes unitarios focados em regras de negocio e integracao com camada HTTP simulada.
- Dependencias externas sao isoladas com mocks para garantir previsibilidade.
- Casos de sucesso e erro sao cobertos para validar fluxos principais e tratamento de falhas.
- Dados de entrada incluem tipos variados (int, String, bool) para validar conversoes.

## Testes do DTO

Arquivo: [test/produto/produto_dto_test.dart](test/produto/produto_dto_test.dart)

- Produto.fromJson - parses numeric values correctly
  - Objetivo: garantir que valores numericos sejam convertidos corretamente.
  - Verifica: id, nome, descricao, preco, tipoProduto, setorProducao, categoriaId e ativo.

- Produto.fromJson - parses string values and defaults
  - Objetivo: validar conversao de valores numericos vindo como String e default de nome.
  - Verifica: id, nome, preco, categoriaId e ativo.

- Produto.toJson - omits ativo by default
  - Objetivo: confirmar que o campo ativo nao e enviado por padrao.
  - Verifica: chave ativo ausente no mapa quando forUpdate e false.

- Produto.toJson - includes ativo when forUpdate is true
  - Objetivo: garantir que ativo seja incluido quando o payload e para update.
  - Verifica: chave ativo com o valor atual do objeto.

- Produto.toJson - defaults ativo to true on update when null
  - Objetivo: garantir padrao ativo true quando forUpdate e true e ativo e null.
  - Verifica: ativo true no mapa.

## Testes do Service

Arquivo: [test/produto/produto_service_test.dart](test/produto/produto_service_test.dart)

- criarProduto returns created data
  - Objetivo: validar que o service retorna o payload de criacao.
  - Mock: POST /produtos com resposta 201.

- buscarPorId returns data
  - Objetivo: validar que o service retorna o produto correto por id.
  - Mock: GET /produtos/5 com resposta 200.

- listar returns list response
  - Objetivo: validar lista simples de produtos.
  - Mock: GET /produtos com resposta 200 (array).

- listar returns data list when wrapped
  - Objetivo: validar resposta quando a API encapsula lista em data.
  - Mock: GET /produtos com resposta 200 (data: []).

- listar returns empty list for unexpected response
  - Objetivo: validar comportamento seguro para resposta inesperada.
  - Mock: GET /produtos com resposta 200 (objeto sem lista).

- editarProduto returns updated data
  - Objetivo: validar retorno de update de produto.
  - Mock: PUT /produtos/9 com resposta 200.

- excluirProduto completes without error
  - Objetivo: validar que delete nao dispara erro quando sucesso.
  - Mock: DELETE /produtos/3 com resposta 204.

- throws ApiError on bad request
  - Objetivo: validar tratamento de erro e mensagem propagada.
  - Mock: POST /produtos com resposta 400 e detail.

## Observacoes

- Os mocks usam o http_mock_adapter para isolar chamadas HTTP do Dio.
- Os testes priorizam cobertura de conversoes de dados e tratamento de erros.
