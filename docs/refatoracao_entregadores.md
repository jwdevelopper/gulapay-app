# Refatoração da tela de entregadores

Data da revisão: 2026-08-04

Este documento é a referência atual do módulo de Entregadores. A implementação anterior, descrita em `DEMANDA ENTREGADOR_DOC.md`, foi substituída porque concentrava um formulário simulado na página principal e não possuía integração real com a API.

## 1. Análise comparativa com Produtos

### Produtos — padrão usado como referência

- página principal voltada à consulta e apresentação de uma coleção;
- cabeçalho interno com título e resumo quantitativo;
- busca em destaque;
- contador e ordenação antes da lista;
- cards com hierarquia visual clara e menu de três pontos;
- toque no card para editar;
- exclusão por swipe com confirmação e alternativa pelo menu;
- FAB para cadastrar um novo item;
- formulário aberto em uma rota separada.

### Entregadores — problemas da versão anterior

- um segundo `AppBar` laranja era renderizado abaixo do `AppBar` da `Home`;
- a página inteira era um formulário, apesar de o item do menu estar no plural;
- não existia listagem, busca, ordenação, edição por item ou estado vazio;
- o card de “Resumo” repetia os campos sem ajudar no fluxo operacional;
- o salvamento era apenas um `Future.delayed`, sem persistência;
- o DTO de resposta era reutilizado como se também fosse payload de criação;
- o arquivo e a classe do DTO não seguiam a convenção Dart;
- não existia service para o endpoint `/entregadores`.

### Resultado da refatoração

A página principal passou a seguir a mesma hierarquia de Produtos:

1. quantidade de entregadores ativos em destaque, sem repetir o título do `AppBar` global;
2. busca por nome ou telefone;
3. contador e alternância de ordenação A–Z/Z–A;
4. cards com nome, telefone formatado, status e menu de ações;
5. pull-to-refresh e estados de carregamento, erro, vazio e busca sem resultado;
6. FAB para abrir o cadastro;
7. formulário separado para criação e edição.

O `AppBar` interno antigo foi removido. A navegação global continua sendo responsabilidade da `Home`.

## 2. Estrutura introduzida

```text
lib/modules/entregador/
├── dto/
│   ├── entregador_create_request.dart
│   ├── entregador_response.dart
│   └── entregador_update_request.dart
├── page/
│   ├── entregador_form_page.dart
│   └── entregador_page.dart
├── service/
│   └── entregador_service.dart
└── widgets/
    ├── entregador_card.dart
    ├── entregador_empty_state.dart
    ├── entregador_active_count.dart
    ├── entregador_results_header.dart
    ├── entregador_search_field.dart
    └── entregadores_palette.dart
```

A página coordena estado e operações. Os widgets cuidam somente da apresentação. O service concentra HTTP e conversão de erros. Cada DTO representa um contrato específico.

## 3. Contrato da API validado

Fonte consultada: `https://gulapay-backend.renannardi.com/v3/api-docs` em 2026-08-04.

### Listagem

```http
GET /entregadores?apenasAtivos=true
```

A tela operacional solicita apenas entregadores ativos. A resposta esperada é uma lista de `EntregadorResponse`.

### Criação

```http
POST /entregadores
Content-Type: application/json
```

Payload enviado:

```json
{
  "nome": "Carlos Silva",
  "telefone": "(11) 98765-4321"
}
```

`EntregadorCreateRequest` não envia `id` nem `ativo`. Segundo o contrato, novos entregadores são criados ativos pelo backend.

### Atualização

```http
PUT /entregadores/{id}
Content-Type: application/json
```

Payload enviado:

```json
{
  "nome": "Carlos Silva",
  "telefone": "11987654321",
  "ativo": true
}
```

O `id` é enviado no path, não no corpo. `EntregadorUpdateRequest` inclui `ativo`, obrigatório no `PUT`.

### Exclusão

```http
DELETE /entregadores/{id}
```

O backend executa soft delete: o entregador é inativado. A interface informa isso na confirmação e remove o card da listagem operacional de ativos somente depois do sucesso da API.

### Resposta

```json
{
  "id": 12,
  "nome": "Carlos Silva",
  "telefone": "11987654321",
  "ativo": true
}
```

`EntregadorResponse` é somente leitura e tolera `id`/`ativo` serializados como texto para evitar falha de parsing em respostas inconsistentes.

## 4. Validações do formulário

As regras foram alinhadas ao OpenAPI:

- nome obrigatório, entre 2 e 120 caracteres;
- telefone obrigatório, entre 8 e 20 caracteres;
- telefone aceita números, espaços, `+`, parênteses e hífen;
- criação envia somente nome e telefone;
- edição envia nome, telefone e status;
- o botão fica bloqueado durante o envio;
- erros HTTP são convertidos em `ApiError` e apresentados ao usuário.

## 5. Exclusão compartilhada

Foi criado `lib/core/widgets/app_cartao_deslizavel.dart` para concentrar o swipe de exclusão:

```dart
AppCartaoDeslizavel(
  chave: 'entregador_${entregador.id}',
  aoConfirmarExclusao: onConfirmDelete,
  child: card,
)
```

O mesmo componente passou a envolver os cards de Produtos. Assim, cor, direção do gesto, rótulo e ícone não divergem entre módulos. O menu acessível continua usando `AppMenuAcoes`, e swipe/menu chamam a mesma função de confirmação e exclusão.

## 6. Estados de interface

- carregando: indicador central e lista ainda rolável;
- sucesso: cards ordenados, busca local e refresh;
- API indisponível: card com mensagem e ação “Tentar novamente”;
- lista vazia: CTA “Cadastrar entregador”;
- busca sem resultado: CTA “Limpar busca”;
- exclusão: diálogo de confirmação, chamada remota e feedback por `SnackBar`.

## 7. Verificações executadas

- análise estática isolada do módulo: sem problemas;
- testes de DTO: criação, atualização e desserialização;
- testes de service: GET, POST, PUT, DELETE e conversão de erro HTTP;
- teste de widget: renderização, formatação de telefone e busca;
- revisão visual real em 800 × 700;
- revisão responsiva real em 360 × 800;
- formulário e listagem sem overflow nas duas larguras.

## 8. Decisões de escopo

- a listagem mostra apenas ativos, como a tela de Produtos; por isso não foi criado um filtro de inativos nesta etapa;
- a reativação é suportada pelo backend via atualização/patch, mas precisa de uma futura visão administrativa de inativos para ser útil na interface;
- alterações locais anteriores em arquivos gerados de plugins e em `pubspec.lock` foram preservadas e não fazem parte desta refatoração.

## 9. Correção de estado no Flutter Web

Durante a validação com um processo antigo de `flutter run -d chrome`, o hot reload preservou a instância anterior de `_EntregadorPageState`. Como a refatoração adicionou novos campos de estado, o JavaScript gerado tentou consultar `.isEmpty` em uma propriedade ainda `undefined`.

A página passou a:

- resolver controller, service, lista, busca e flags com valores seguros;
- reinicializar os campos no `reassemble` de desenvolvimento;
- recarregar a listagem após o reassemble;
- possuir teste de regressão para esse ciclo.

Um hot restart continua sendo recomendado depois de alterações estruturais em classes `State`, mas a tela não depende mais dele para evitar essa exceção.

A máscara de telefone deixou de ser implementada dentro do card e passou a usar a utilidade global documentada em [`utils_telefone_formatter.md`](utils_telefone_formatter.md).

## 9. Simplificação do formulário de edição

A dica técnica sobre o payload enviado à API foi removida do modo de edição.
O formulário agora apresenta diretamente os campos, o controle de status e as
ações, sem expor detalhes internos do contrato ao usuário. A dica funcional de
que novos entregadores são criados ativos permanece apenas no cadastro novo.

## 10. Ajuste final do cabeçalho

O título interno “Entregadores” foi removido porque repetia o título do `AppBar` global da `Home`. A área interna agora mostra somente `N entregador(es) ativo(s)`, com peso tipográfico maior, seguida diretamente pela busca.
