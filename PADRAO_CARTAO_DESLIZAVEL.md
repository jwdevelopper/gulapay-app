# Padrão de cartão deslizável

## O que foi feito

O efeito de deslize refinado que existia em Entregadores foi extraído de `core/widgets` para `lib/core/utils/cartao_deslizavel/` e convertido em um componente reutilizável. Produtos e Entregadores continuam usando a configuração padrão de exclusão; Categorias usa o mesmo efeito com as ações de inativação e reativação.

O utilitário foi separado em três arquivos:

| Arquivo | Responsabilidade |
| --- | --- |
| `app_cartao_deslizavel.dart` | Gesto, limiar, confirmação e ciclo de saída do item. |
| `app_cartao_deslizavel_acao.dart` | Configuração pública e fácil de customizar. |
| `app_cartao_deslizavel_painel.dart` | Gradiente, revelação progressiva do conteúdo e sombra. |

## Código introduzido

### Configuração simples da ação

```dart
AppCartaoDeslizavelAcao(
  rotulo: 'Reativar',
  icone: Icons.restart_alt,
  cor: const Color(0xFF2E8B57),
  corProfunda: const Color(0xFF17663C),
)
```

### Uso padrão para exclusão

```dart
AppCartaoDeslizavel(
  chave: 'entregador_$id',
  aoConfirmarAcao: confirmarExclusao,
  child: card,
)
```

### Uso em Categorias

```dart
AppCartaoDeslizavel(
  chave: 'categoria_$id',
  raioBorda: 12,
  acao: acaoDeStatus,
  aoConfirmarAcao: aoAlternarStatus,
  aoConcluir: aoStatusAlterado,
  child: card,
)
```

O limiar padrão é 50% da largura do cartão. A ação só é concluída após o usuário soltar o item além desse ponto e o callback retornar `true`. Quando o rótulo for maior que a área revelada, ele é reduzido dentro do próprio painel para evitar overflow em telas estreitas.

Para ícones fora do conjunto Material, a configuração também aceita `iconePersonalizado`; a ação padrão de exclusão preserva a lixeira do Font Awesome que já era usada em Entregadores.

## Validação

Os testes do componente verificam a revelação gradual de ícone/rótulo, a manutenção do painel durante o arraste e o cancelamento seguro da ação. O teste de Categorias verifica a configuração do TextArea e a reativação após o limiar de 50%.
