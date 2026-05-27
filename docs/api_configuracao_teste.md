# API de teste da branch

Este documento explica como a branch decide qual API usar, quais valores entram por padrao e quais pontos precisam ser alterados quando voce quiser alternar entre o backend local e o backend remoto de testes.

## Objetivo

Nesta branch, a aplicacao foi configurada para subir usando a API de teste por padrao, sem depender do backend local.

Isso ajuda em dois cenarios:

- rodar o app em emulador ou dispositivo sem precisar subir o backend da maquina;
- manter uma saida clara para testes locais quando for necessario voltar ao backend local.

## Como a escolha funciona

A escolha da API ficou centralizada em [lib/core/constants_api.dart](lib/core/constants_api.dart).

Valores principais:

- `API_ENV`
  - define o modo da aplicacao.
  - valor padrao: `test`
- `API_TEST_BASE_URL`
  - URL base usada quando `API_ENV=test`.
  - valor padrao: `https://gulapay-backend.renannardi.com`
- `API_TEST_PORT`
  - porta usada no modo de teste.
  - valor padrao: vazio
- `API_LOCAL_BASE_URL`
  - URL base usada quando `API_ENV=local`.
  - valor padrao: `http://localhost`
- `API_LOCAL_PORT`
  - porta usada no modo local.
  - valor padrao: `:8080`

## URL final

O `Dio` monta a base final usando:

```dart
ConstantsApi.urlBaseCompleta
```

Na pratica:

- modo de teste: `https://gulapay-backend.renannardi.com`
- modo local: `http://localhost:8080`

## Regras do interceptor

O cliente HTTP esta em [lib/core/api_client.dart](lib/core/api_client.dart).

Ele aplica o token automaticamente para quase todas as chamadas, mas deixa rotas publicas fora disso:

- `/auth/login`
- `/auth/register`

Essas rotas nao recebem `Authorization: Bearer ...`.

Nas outras rotas, o app:

1. busca o token salvo no `SharedPreferences`;
2. verifica se ele existe;
3. injeta no header `Authorization`.

## Login

Arquivo: [lib/modules/login/service/login_service.dart](lib/modules/login/service/login_service.dart)

O login faz:

- `POST /auth/login`
- corpo:

```json
{
  "login": "email_do_usuario",
  "senha": "senha_do_usuario"
}
```

O retorno aceito pelo DTO esta em [lib/modules/login/dto/login_response.dart](lib/modules/login/dto/login_response.dart).

Campos aceitos:

- `token`
- `accessToken`
- `tokenType`
- `expiresIn`
- `expiresInMinutes`
- `message`
- `error`
- `statusCode`
- `detail`

## Cadastro de usuario

Arquivo: [lib/modules/registrar_usuario/service/registrar_usuario_service.dart](lib/modules/registrar_usuario/service/registrar_usuario_service.dart)

O cadastro usa:

- `POST /auth/register`
- corpo:

```json
{
  "name": "Nome",
  "email": "email@teste.com",
  "password": "123456"
}
```

O retorno esperado esta em [lib/modules/registrar_usuario/dto/registrar_usuario_response.dart](lib/modules/registrar_usuario/dto/registrar_usuario_response.dart).

## Mesas

Arquivo: [lib/modules/mesa/service/mesa_service.dart](lib/modules/mesa/service/mesa_service.dart)

Rotas usadas:

- `GET /mesas`
- `GET /mesas/{id}`
- `POST /mesas`
- `PUT /mesas/{id}`
- `DELETE /mesas/{id}`

O DTO de mesa esta em [lib/modules/mesa/dto/mesa_dto.dart](lib/modules/mesa/dto/mesa_dto.dart).

## Como trocar para local

Se voce quiser testar com backend local, rode o app com:

```bash
flutter run --dart-define=API_ENV=local
```

Se o backend local estiver em outra porta ou host:

```bash
flutter run ^
  --dart-define=API_ENV=local ^
  --dart-define=API_LOCAL_BASE_URL=http://10.0.2.2 ^
  --dart-define=API_LOCAL_PORT=:8080
```

## Como manter a branch de teste previsivel

Se a mudanca for apenas de ambiente:

- ajuste somente `API_ENV` e, se necessario, as variaveis de base/porta.

Se a mudanca for de contrato da API:

- revise os services e os DTOs antes de testar.

## Arquivos principais

- [lib/core/constants_api.dart](lib/core/constants_api.dart)
- [lib/core/api_client.dart](lib/core/api_client.dart)
- [lib/modules/login/dto/login_response.dart](lib/modules/login/dto/login_response.dart)
- [lib/modules/login/service/login_service.dart](lib/modules/login/service/login_service.dart)
- [lib/modules/registrar_usuario/service/registrar_usuario_service.dart](lib/modules/registrar_usuario/service/registrar_usuario_service.dart)
- [lib/modules/mesa/service/mesa_service.dart](lib/modules/mesa/service/mesa_service.dart)

