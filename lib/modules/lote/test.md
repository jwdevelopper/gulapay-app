Testes dos Formatadores

Arquivo: test/lote/lote_formatadores_test.dart

LoteFormatadores.formatarData - parses ISO date without timezone regression
Objetivo: garantir que datas no formato ISO (YYYY-MM-DD) sejam convertidas sem sofrer regressao de dia por fuso horario UTC vs Local.
Verifica: conversao correta de "2026-05-25" para "25/05/2026", garantindo que o dia mantem-se 25 em fuso de Brasil/UTC-3.

LoteFormatadores.formatarData - handles null and invalid dates safely
Objetivo: validar o comportamento defensivo do formatador ao receber strings nulas, vazias ou malformatadas.
Verifica: retorno de hifen "-" para valores nulos/vazios e preservacao do texto original para formatos invalidos.

LoteFormatadores.formatarQuantidade - formats integer and decimal numbers
Objetivo: validar a formatacao de quantidades com precisao decimal e substituicao de separador.
Verifica: inteiros sem casas decimais ("10"), substituicao de ponto por virgula em decimais ("10,5") e padrao "0" para nulo.

Testes do Service

Arquivo: test/lote/lote_service_test.dart

criar returns created lote data
Objetivo: validar que o service envia o payload correto e retorna o lote criado.
Mock: POST /lotes com resposta 201.

listar returns list of lotes wrapped or unwrapped
Objetivo: validar desserializacao segura de listas de lotes recebidas como array direto ou encapsuladas em objeto data, prevenindo TypeError.
Mock: GET /lotes?insumoId=X com resposta 200 (array ou envelope data).

buscarPorId returns single lote data
Objetivo: validar retorno de um unico lote pelo identificador.
Mock: GET /lotes/1 com resposta 200.

alterarStatus patches lote active state
Objetivo: validar a atualizacao parcial do status ativo/inativo do lote via patch.
Mock: PATCH /lotes/1 com resposta 200.

excluir completes deletion without content
Objetivo: validar que o metodo de exclusao completa com sucesso em respostas sem corpo.
Mock: DELETE /lotes/1 com resposta 204.

throws ApiError on HTTP failure
Objetivo: validar a captura de excecoes do Dio e a conversao para o tipo ApiError customizado.
Mock: GET /lotes com resposta 400 ou 404.

Testes de Componentes e Widgets

Arquivo: test/lote/lote_insumo_seletor_test.dart

LoteInsumoSeletor - debounces search input and disposes controllers
Objetivo: garantir que as buscas por digotacao aguardem o tempo de debounce antes de chamar a API e que os controllers sejam descartados corretamente.
Verifica: prevencao de race conditions, cancelamento de requisicoes encadeadas e ausencia de vazamento de memoria (memory leak).

Arquivo: test/lote/lote_card_test.dart

LoteCard - renders status tag and safe null fallback
Objetivo: validar a exibicao visual das tags de status (Vencido, Ativo, Inativo) e tratamento de campos zerados.
Verifica: aplicacao de cores de status e renderizacao sem excecoes para valores nulos ou zerados.

Observacoes

Os mocks utilizam isolamento do client Dio via injeção de dependência ou adaptadores de mock HTTP.
Os testes priorizam a prevencao do bug critico de fuso horario e a estabilidade na desserializacao de tipos do JSON.