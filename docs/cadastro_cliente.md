# Cadastro de Cliente

Data da revisão: 2026-09-15

Este documento descreve onde está e como funciona o cadastro de clientes do GulaPay:
telas, campos, validações, DTOs, chamadas de API e os pontos que ainda precisam de ajuste.

O histórico de alterações do módulo está em `CHANGES_CLIENTE.md`, na raiz do projeto.
Este documento descreve o estado atual do código, não o histórico.

## 1. Onde está o código

Todo o cadastro vive em um único módulo:

```text
lib/modules/cliente/
├── dto/
│   ├── cliente_create_request.dart   payload do POST (novo cliente)
│   ├── cliente_update_request.dart   payload do PUT (edição e reativação)
│   ├── cliente_response.dart         resposta da API
│   └── cliente_endereco.dart         endereço, usado nos três DTOs acima
├── page/
│   ├── cliente_page.dart             lista, busca, filtro e ações
│   ├── cliente_form_page.dart        FORMULÁRIO DE CADASTRO E EDIÇÃO
│   └── cliente_detalhe_page.dart     ficha do cliente
└── service/
    └── cliente_service.dart          chamadas HTTP do módulo
```

O arquivo central do cadastro é **`lib/modules/cliente/page/cliente_form_page.dart`**.
É a mesma tela para criar e para editar.

Arquivos de apoio fora do módulo:

| Arquivo | Papel no cadastro |
|---|---|
| `lib/core/api_client.dart` | instância única do Dio; injeta o token JWT em todas as chamadas |
| `lib/core/constants_api.dart` | `urlClientes = "/clientes"` e a base URL do ambiente |
| `lib/core/api_error.dart` | converte `DioException` em `ApiError` com mensagem exibível |
| `lib/core/utils/telefone_formatter.dart` | máscara do campo telefone (documentado em `docs/utils_telefone_formatter.md`) |
| `lib/core/widgets/app_campo_texto.dart` | campo de texto padrão, recebe o `validador` |
| `lib/core/widgets/app_rotulo.dart` | rótulo dos campos, com suporte a `opcional: true` |
| `lib/core/widgets/app_barra_acoes.dart` | barra fixa com Cancelar e Salvar/Atualizar |
| `lib/core/widgets/app_dica.dart` | caixa de instrução no rodapé do formulário |
| `lib/modules/home/page/home_page.dart` | registra a aba "Clientes" que abre a `ClientePage` |

## 2. Como se chega na tela de cadastro

A `ClientePage` é uma aba dentro do `IndexedStack` da `Home` — ela não tem `AppBar` próprio.
Existem três caminhos até o formulário:

1. **Novo cliente pelo botão flutuante** — `cliente_page.dart:246`, `_abrirFormulario()` sem argumento.
2. **Novo cliente pela ação global de criação** — `AcoesCriacao.registrar('Clientes', () => _abrirFormulario())`
   no `initState` (`cliente_page.dart:35`), que liga o botão de criar da `Home` a esta tela.
3. **Edição** — menu de três pontos do card (`cliente_page.dart:443`) ou o ícone de lápis
   da `ClienteDetalhesPage`, ambos chamando `_abrirFormulario(cliente: c)`.

O modo é decidido pelo parâmetro do construtor:

```dart
ClienteFormPage({super.key, this.cliente});

bool get ehEdicao => cliente != null;
```

Com `cliente == null` a tela é "Novo cliente" e usa `POST`.
Com um cliente preenchido, o `initState` carrega os controllers e a tela usa `PUT`.

Ao salvar com sucesso, a tela fecha com `Navigator.pop(context, true)`.
A lista escuta esse retorno e recarrega:

```dart
final resultado = await Navigator.push<bool>(...);
if (resultado == true && mounted) _carregar();
```

Esse `true` é o contrato entre formulário e lista. Se um dia o `pop` deixar de enviá-lo,
o cadastro funciona mas a lista não atualiza.

## 3. Campos do formulário

Os campos estão em duas seções: dados do cliente e endereço, separadas por um divisor
com o ícone `locationDot`.

| Campo | Controller | Teclado | Limite | Validação no app |
|---|---|---|---|---|
| Nome completo | `_controleNome` | texto | 120 | obrigatório, mínimo 3 caracteres |
| Telefone (WhatsApp) | `_controleTelefone` | `phone` | 19 | obrigatório (não vazio) + máscara `TelefoneFormatter` |
| E-mail | `_controleEmail` | `emailAddress` | 150 | **nenhuma** |
| CEP | `_controleCep` | `number` | 9 | **nenhuma** |
| Logradouro | `_controleLogradouro` | texto | 150 | **nenhuma** |
| Número | `_controleNumero` | texto | 10 | **nenhuma** |
| Complemento | `_controleComplemento` | texto | 60 | nenhuma (marcado como opcional) |
| Bairro | `_controleBairro` | texto | 80 | **nenhuma** |
| Cidade | `_controleCidade` | texto | 80 | **nenhuma** |
| UF | `_controleUf` | texto | 2 | **nenhuma** |

Todos os controllers são liberados no `dispose()`.

O asterisco no rótulo é apenas texto. Hoje só **Nome** e **Telefone** bloqueiam o salvamento —
veja a seção 7.

## 4. O que acontece ao salvar

`_salvar()` em `cliente_form_page.dart:79`:

1. `_chaveFormulario.currentState!.validate()` — se algum validador falhar, a função retorna
   e nada é enviado.
2. Monta um `ClienteEndereco` com todos os campos de endereço já com `trim()`.
3. `setState(() => _carregando = true)` — a `AppBarraAcoes` mostra o estado de carregando
   e impede toque duplo no botão.
4. Ramifica:
   - **edição**: monta `ClienteUpdateRequest` preservando `ativo: widget.cliente!.ativo ?? true`
     e chama `editarCliente(id, dto)`;
   - **criação**: monta `ClienteCreateRequest` e chama `criarCliente(dto)`.
5. Sucesso: `if (!mounted) return;` e `Navigator.pop(context, true)`.
6. `on ApiError`: snackbar vermelho com `'Erro: ${e.message}'`, a tela continua aberta
   com os dados preenchidos.
7. `finally`: desliga `_carregando` se o widget ainda estiver montado.

A preservação do `ativo` na edição é intencional: sem ela, editar um cliente inativo o
reativaria silenciosamente.

## 5. Contrato com a API

Base: `ConstantsApi.baseUrl + ConstantsApi.porta`, definidos por `--dart-define` (`API_ENV`).
O padrão é o ambiente de teste, `https://gulapay-backend.renannardi.com`.
O `ApiClient` adiciona `Authorization: Bearer <token>` em toda chamada que não seja de login
ou registro.

### Criar

```http
POST /clientes
Content-Type: application/json
```

```json
{
  "nome": "João da Silva",
  "telefone": "(11) 99999-0000",
  "email": "joao@email.com",
  "endereco": {
    "logradouro": "Av. Paulista",
    "numero": "1578",
    "complemento": "Apto 42",
    "bairro": "Bela Vista",
    "cidade": "São Paulo",
    "uf": "SP",
    "cep": "01310-100"
  }
}
```

Resposta convertida em `ClienteResponse`, que traz também `id`, `ativo` e `linkWhatsApp`
(campo gerado pelo backend, usado na ficha do cliente).

### Editar

```http
PUT /clientes/{id}
```

Mesmo corpo do POST, acrescido de `"ativo": true|false`.

### Demais operações do módulo

| Função (`cliente_service.dart`) | Chamada |
|---|---|
| `listarClientes({apenasAtivos, telefone})` | `GET /clientes?apenasAtivos=false` (+ `telefone` quando informado) |
| `criarCliente(dados)` | `POST /clientes` |
| `editarCliente(id, dados)` | `PUT /clientes/{id}` |
| `inativarCliente(id)` | `DELETE /clientes/{id}` — inativação, não exclusão |
| `reativarCliente(id, dados)` | reusa `PUT /clientes/{id}` com `ativo: true` |

Toda função captura `DioException` e relança `ApiError.fromDioException(e)`.
As páginas só tratam `ApiError`.

Observação: a `ClientePage` chama `listarClientes()` sem argumentos — traz ativos e
inativos, e o filtro TODOS/ATIVOS/INATIVOS é aplicado em memória, junto com a busca por
nome e telefone (`_filtrados`, `cliente_page.dart:64`). O parâmetro `telefone` do service
existe mas não é usado pela tela.

## 6. DTOs

```text
ClienteCreateRequest   nome, telefone, email, endereco          → toJson
ClienteUpdateRequest   nome, telefone, email, endereco, ativo   → toJson
ClienteResponse        id, nome, telefone, email, linkWhatsApp,
                       endereco, ativo                          → fromJson / toJson
ClienteEndereco        id, logradouro, numero, complemento,
                       bairro, cidade, uf, cep                  → fromJson / toJson
```

Três contratos separados em vez de um DTO único: o POST não aceita `ativo`, e a resposta
traz campos que o app nunca envia (`id`, `linkWhatsApp`). O `toJson` de `ClienteEndereco`
omite o `id` de propósito — o endereço é sempre enviado como parte do cliente.

Todos os campos são anuláveis, então o consumo usa `?? ''` ou `?? 'Sem nome'` nas telas.

## 7. Pontos em aberto

Levantados na leitura do código atual. Nenhum impede o uso, mas todos afetam a qualidade
do dado que chega no backend:

1. **Sete campos marcados como obrigatórios não têm validador.** E-mail, CEP, logradouro,
   número, bairro, cidade e UF exibem `*` no rótulo, mas o formulário salva com todos
   vazios. Só nome e telefone bloqueiam.
2. **O e-mail não é validado.** Qualquer texto passa, inclusive sem `@`.
3. **O telefone é enviado formatado.** `_controleTelefone.text.trim()` envia
   `(11) 99999-0000` com máscara. Não há normalização para dígitos antes do POST, o que
   dificulta busca e comparação no backend. A máscara só cuida da apresentação — a decisão
   de como persistir é do DTO/service, como documenta o próprio `TelefoneFormatter`.
4. **O endereço é sempre enviado**, mesmo todo em branco, como objeto de strings vazias.
   Não há caminho que envie `endereco: null`.
5. **Não há consulta de CEP.** O endereço é digitado inteiro à mão.
6. **Não há teste automatizado do módulo.** `test/` cobre entregador, produto, mesa e core;
   não há `test/cliente/`. Entregador tem `entregador_dto_test`, `entregador_service_test`
   e `entregador_page_test` — é o modelo a seguir quando o cadastro de cliente for coberto.
7. **Não há tratamento específico de duplicidade.** Se o backend recusar um telefone ou
   e-mail já cadastrado, a mensagem cai no snackbar genérico de `ApiError`, sem destacar
   o campo com problema.
