# Gulapay App

## Visão Geral

Gulapay é uma aplicação Flutter desenvolvida para gerenciamento de produtos e categorias. A aplicação permite aos usuários fazer login, registrar-se, visualizar dashboards, gerenciar categorias de produtos e produtos. É projetada para ser uma solução simples e intuitiva para controle de inventário ou e-commerce básico.

## Funcionalidades

- **Login e Registro de Usuários**: Autenticação segura com email e senha.
- **Dashboard**: Visão geral dos dados principais da aplicação.
- **Gerenciamento de Categorias**: Adicionar, visualizar e gerenciar categorias de produtos.
- **Gerenciamento de Produtos**: Adicionar, visualizar e gerenciar produtos associados às categorias.
- **Interface Intuitiva**: Navegação fácil com drawer e abas.

## Instalação

### Pré-requisitos

- Flutter SDK instalado (versão ^3.9.2)
- Dart SDK
- Um emulador ou dispositivo físico para Android/iOS

### Passos para Instalação

1. Clone o repositório:
   ```
   git clone <url-do-repositorio>
   cd gulapay-app
   ```

2. Instale as dependências:
   ```
   flutter pub get
   ```

3. Execute a aplicação:
   ```
   flutter run
   ```

## Uso

1. Ao iniciar a aplicação, você será direcionado para a tela de login.
2. Faça login com suas credenciais ou registre-se como novo usuário.
3. Após o login, acesse o dashboard, categorias e produtos através do menu lateral.

## Dependências

- `flutter`: Framework principal.
- `cupertino_icons`: Ícones para iOS.
- `font_awesome_flutter`: Ícones Font Awesome.
- `dio`: Cliente HTTP para chamadas de API.
- `shared_preferences`: Armazenamento local de preferências.

## Estrutura do Projeto

```
lib/
├── main.dart
├── core/
│   ├── api_client.dart
│   ├── api_error.dart
│   └── constants_api.dart
└── modules/
    ├── categoria/
    ├── dashboard/
    ├── home/
    ├── login/
    ├── produto/
    └── registrar_usuario/
```

## Desenvolvimento

Para contribuir ou desenvolver:

1. Certifique-se de que o código segue as diretrizes do `analysis_options.yaml`.
2. Execute os testes: `flutter test`
3. Formate o código: `flutter format .`

## Suporte

Para dúvidas ou problemas, entre em contato com a equipe de desenvolvimento.

## Licença

Este projeto é privado e não está disponível para publicação no pub.dev.
