# Relatório de Testes QA — Módulo de Lotes


**Data do Teste:** 12/08/2026

**Escopo:** Homologação do Módulo de Lotes (Backend API & Frontend Flutter)

**Status Geral:** Aprovado com Ressalvas no Frontend (Backend 100% Homologado / Frontend com Bugs Mapeados)


---


## 1. Resumo da Execução


| Camada | Escopo Avaliado | Status | Observação |
| :--- | :--- | :--- | :--- |
| **Backend (API)** | Regras de Negócio, FEFO, Split, Validações e Banco | **APROVADO** | Todas as regras e respostas HTTP validadas via Swagger/Postman. |
| **Frontend (UI)** | Interface de Usuário, Formulários e Mapeamento de Erros | **REPROVADO** | Identificados 5 bugs de validação visual e UX. |


---


## 2. Homologação do Backend (API & Regras de Negócio)


Todas as funcionalidades do backend descritas no escopo do lote foram validadas com sucesso:


- [x] **Integridade de FK (`Insumo`):** Requisições com `insumoId` inexistente retornam `HTTP 400 Bad Request` (`InvalidRequestException`).

- [x] **Regra de Negócio de Validade:** Lançamentos com data de validade no passado são bloqueados via API com `HTTP 422 Unprocessable Entity` (`BusinessException`).

- [x] **Listagem e Ordenação FEFO:** O endpoint `GET /lotes?insumoId=X` retorna os lotes ordenados prioritariamente pelas datas de vencimento mais próximas.

- [x] **Consumo e Split de Lotes:** O endpoint `POST /movimentacoes-estoque` realiza o abate sequencial (FEFO), consumindo o lote mais próximo de vencer e dividindo o saldo excedente no lote seguinte.

- [x] **Estrutura de Banco de Dados:** Migrações da tabela e relacionamentos executados via Flyway V10.


---


## 3. Bugs Mapeados na Interface (Frontend Flutter)


### [BUG-01] Permissão de Seleção de Data de Validade no Passado na UI


* **Categoria:** Validação de Entrada / UX


* **Severidade:** Média


* **Comportamento Atual:** A interface permite que o usuário selecione e submeta datas de validade (dia/mês/ano) anteriores à data atual no campo de formulário.


* **Comportamento Esperado:** O componente de calendário (`DatePicker`) e a validação do formulário no aplicativo devem bloquear a seleção/digitação de datas passadas antes de enviar a requisição ao backend.


* **Nota de Integração:** O backend rejeita a chamada com `HTTP 422`, mas a validação deve ocorrer também no client-side para evitar requisições desnecessárias.


---


### [BUG-02] Campo "Código Opcional" Aceitando Caracteres Especiais


* **Categoria:** Validação de Input


* **Severidade:** Baixa


* **Comportamento Atual:** O campo aceita a inserção de caracteres especiais (ex: `@, #, $, %, &`).


* **Comportamento Esperado:** O campo deve possuir máscara de entrada ou `inputFormatter` permitindo apenas caracteres alfanuméricos (letras e números), visto que se trata de um código identificador.


---


### [BUG-03] Ausência de Limite Máximo de Caracteres no Campo "Quantidade Inicial"


* **Categoria:** UX / Estabilidade de UI


* **Severidade:** Baixa


* **Comportamento Atual:** O campo aceita entradas de texto numérico com extensão ilimitada, gerando quebra visual no layout e potencial *overflow*.


* **Comportamento Esperado:** Implementar limite máximo (`maxLength`) de 9 a 12 caracteres no campo numérico.


---


### [BUG-04] Ausência de Limite Máximo de Caracteres no Campo "Custo Unitário"


* **Categoria:** UX / Estabilidade de UI


* **Severidade:** Baixa


* **Comportamento Atual:** O campo aceita entradas numéricas/monetárias sem restrição de tamanho de dígitos.


* **Comportamento Esperado:** Aplicar máscara monetária/decimal apropriada e delimitar o tamanho máximo (`maxLength`) de 9 a 12 caracteres.


---


### [BUG-05] Inversão de Nomenclatura na Mensagem de Erro de Incompatibilidade de Unidade de Medida


* **Categoria:** Mensagem de Erro / Tradução / UX


* **Severidade:** Média


* **Comportamento Atual:** Ao selecionar a unidade **"Litros"**, o alerta de erro exibe que a unidade **"mililitros"** é incompatível com o produto (e vice-versa ao selecionar "mililitros"). O mesmo comportamento trocado ocorre entre **"KG"** e **"G"**.


* **Comportamento Esperado:** A mensagem de erro deve referenciar corretamente a unidade que foi selecionada pelo usuário na interface.


* **Observação:** A unidade de medida **"Un"** (Unidade) comporta-se corretamente.