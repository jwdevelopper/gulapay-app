# Correções do módulo de Categorias

## Escopo entregue

- A descrição de uma categoria agora usa uma área de texto com três linhas visíveis e expansão até quatro linhas.
- Cada cartão da listagem possui o menu de opções com `Editar` e a ação contextual `Inativar` ou `Reativar`, seguindo o comportamento existente em Unidades de Medida.
- O gesto horizontal para a esquerda passou a usar o fundo secundário correto e um limiar explícito de 50% da largura do item. Depois de soltar o cartão além desse ponto, a confirmação da ação atual é aberta, inclusive para uma categoria inativa.
- A tela foi dividida em widgets de filtros, cartão, conteúdo visual, menu, gesto, diálogo de status e campos do formulário.

## Componentes introduzidos

| Arquivo | Responsabilidade |
| --- | --- |
| `lib/modules/categoria/widgets/categoria_filtros.dart` | Busca e filtros de status. |
| `lib/modules/categoria/widgets/categoria_card.dart` | Coordena as ações do item. |
| `lib/modules/categoria/widgets/categoria_card_conteudo.dart` | Estrutura visual do cartão. |
| `lib/modules/categoria/widgets/categoria_menu_acoes.dart` | Menu de editar/inativar/reativar. |
| `lib/modules/categoria/widgets/categoria_gesto_status.dart` | Gesto de deslizar e seu limiar. |
| `lib/modules/categoria/widgets/categoria_dialogo_status.dart` | Confirmação de alteração de status. |
| `lib/modules/categoria/widgets/categoria_form_campos.dart` | Campos e dica do formulário. |

## Código introduzido

### TextArea reutilizável

`AppCampoTexto` recebeu suporte opcional a múltiplas linhas, preservando uma linha como padrão para os demais formulários:

```dart
final int maxLinhas;
final int? minLinhas;

TextFormField(
  maxLines: maxLinhas,
  minLines: minLinhas,
)
```

No formulário de Categoria, a descrição usa essa configuração:

```dart
AppCampoTexto(
  controle: controleDescricao,
  dica: 'Detalhes, ingredientes, acompanhamentos...',
  tamanhoMax: limiteDescricao,
  maxLinhas: 4,
  minLinhas: 3,
  tipoTeclado: TextInputType.multiline,
)
```

### Ação por movimento

O gesto foi isolado para manter o mesmo fluxo para inativar e reativar:

```dart
Dismissible(
  direction: DismissDirection.endToStart,
  background: const SizedBox.expand(),
  secondaryBackground: acaoDeStatus,
  dismissThresholds: const {
    DismissDirection.endToStart: 0.5,
  },
  confirmDismiss: (_) => aoConfirmar(),
  onDismissed: (_) => aoConcluir(),
  child: child,
)
```

### Menu contextual por categoria

```dart
CategoriaMenuAcoes(
  ativa: ativa,
  aoSelecionar: (acao) => _executarAcao(acao),
)
```

O menu mostra `Editar` para todas as categorias e alterna a segunda opção entre `Inativar` e `Reativar` de acordo com o status do item.

## Validação

Foi executado `flutter analyze lib/core/widgets/app_campo_texto.dart lib/modules/categoria` após a refatoração. Não há erros ou avisos nas alterações do módulo.

Também foi incluído `test/modules/categoria/widgets/categoria_widgets_test.dart`, que valida a configuração do TextArea e o disparo da confirmação de reativação ao soltar o cartão depois de 50% do seu deslocamento.
