# Utilidade global de máscara de telefone

Data: 2026-08-04

## Objetivo

Centralizar a máscara visual de telefone em uma utilidade global, sem vincular a regra aos módulos de Cliente ou Entregador.

Arquivo criado:

```text
lib/core/utils/telefone_formatter.dart
```

A pasta `core/utils` deve receber utilidades puras e reutilizáveis que não renderizam interface, não acessam API e não pertencem a uma regra de negócio específica.

## Responsabilidade

`TelefoneFormatter` é responsável somente por:

- remover caracteres incompatíveis com a máscara;
- limitar a quantidade de dígitos;
- aplicar a máscara enquanto o usuário digita;
- formatar valores existentes para exibição;
- reposicionar o cursor de acordo com os dígitos digitados.

A classe não valida obrigatoriedade, não altera DTOs e não executa normalização específica de persistência. Essas responsabilidades continuam nos formulários, DTOs e services.

## Formatos suportados

```text
(11) 3333-4444
(11) 99999-9999
+55 (11) 99999-9999
```

O primeiro dígito do número local define a máscara: números iniciados em `9` usam cinco dígitos antes do hífen; os demais usam quatro.

## Uso em campos de texto

```dart
AppCampoTexto(
  controle: controleTelefone,
  tipoTeclado: TextInputType.phone,
  tamanhoMax: TelefoneFormatter.maxCaracteresFormatados,
  formatadores: const [TelefoneFormatter()],
)
```

## Uso em cards e detalhes

```dart
final telefoneFormatado = TelefoneFormatter.formatar(telefone);
```

## Pontos integrados

- formulário de Entregador;
- card de Entregador;
- formulário de Cliente;
- card de Cliente;
- detalhes de Cliente.

## Testes

Os testes estão em:

```text
test/core/utils/telefone_formatter_test.dart
```

Casos cobertos:

- telefone fixo;
- celular;
- código de país `+55`;
- máscara progressiva;
- remoção de caracteres inválidos;
- limite de dígitos;
- valores nulos/vazios;
- cursor no final e no meio do número.
