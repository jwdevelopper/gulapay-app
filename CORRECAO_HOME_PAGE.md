# Correção da compilação da Home

## Alteração realizada

Foi removida uma declaração incompleta de `_AbaPrincipal` em `lib/modules/home/page/home_page.dart`, posicionada antes da aba `Pedidos`.

## Código removido

```dart
_AbaPrincipal(
  tituloAppBar: 'Comandas',
  rotuloInferior: 'Comandas',
```

Esse trecho não tinha os parâmetros obrigatórios `icone` e `pagina`, nem o fechamento `)`. Como consequência, a declaração seguinte era interpretada como argumentos posicionais e impedia a compilação.

## Resultado esperado

A aba `Pedidos`, que utiliza `ComandasPage()`, continua presente e a lista de abas volta a ter sintaxe válida.
