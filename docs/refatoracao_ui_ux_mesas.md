# Refatoração UI/UX — Mesas

## Objetivo

Transformar o mapa de mesas na superfície principal de operação, preservando a paleta GulaPay e reduzindo os elementos permanentes que tiravam espaço do salão.

## Alterações implementadas

- O cabeçalho grande, a legenda fixa e o editor expandido foram removidos da tela principal.
- Os ambientes continuam acessíveis por abas horizontais compactas.
- Totais da área ativa (`mesas`, `em uso` e `alertas`) agora ficam em um cartão pequeno sobre o mapa.
- A legenda e a restauração da base inicial foram movidas para o menu de opções do mapa.
- O botão flutuante **Modo layout** bloqueia ou libera o reposicionamento no mesmo mapa. Com o layout ativo, também é exibido o atalho para criar uma mesa.
- No modo operacional, tocar uma mesa abre um popover próximo dela. Ele mostra status, tempo, itens, total, acesso à comanda e atalho para os detalhes completos.
- O toque duplo continua abrindo a comanda diretamente, preservando o atalho já existente.
- A leitura visual dos estados foi alinhada à operação: livre em verde, mesa em uso/pedido em amarelo com relógio e alertas em vermelho.

## Código introduzido

### `lib/modules/mesa/page/mesa_page.dart`

- Novo layout focado no canvas, com seletor de ambiente compacto e `MapSummary` flutuante.
- Novo menu secundário para legenda e restauração do mapa.
- Remoção do fluxo de navegação para um editor de mapa separado.

### `lib/modules/mesa/widget/floor_plan_canvas.dart`

- `TableQuickPopover`: resumo contextual da mesa selecionada, posicionado em relação à mesa dentro da área visível.
- `LayoutModeButton`: alterna o bloqueio do layout e oferece criação de mesa no estado de edição.
- Os controles de zoom foram mantidos como controles secundários; o controle de layout foi separado e tornado explícito.

### `lib/modules/mesa/widget/table_node.dart`

- O status das mesas com pedido ou alerta agora apresenta o tempo decorrido no próprio nó quando houver histórico de pedido.

### `lib/core/theme/gula_theme.dart` e `table_status_badge.dart`

- Cores e ícones de status foram ajustados para reforçar livre/uso/alerta sem alterar a identidade visual consolidada.

### `test/modules/mesa/floor_plan_controller_test.dart`

- O teste mobile passou a validar o popover operacional e o acionamento do modo Layout no mesmo mapa.

## Comportamento de uso

1. Selecione o ambiente pelas abas superiores.
2. Toque uma mesa para consultar o resumo e abrir/ver a comanda.
3. Toque em `Modo layout` apenas quando precisar movimentar ou editar a planta.
4. Arraste as mesas no próprio mapa e use a sugestão de união quando ela aparecer.
5. Toque novamente em `Layout ativo` para bloquear a planta e retornar à operação.
