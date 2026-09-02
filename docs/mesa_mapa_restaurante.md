# Mapa de mesas do restaurante

Este documento explica o refinamento feito na tela de mesas e como as regras principais ficaram distribuidas no codigo.

## Objetivo da tela

A tela de mesas agora trabalha mais como uma planta operacional do restaurante:

- o usuario escolhe o ambiente em filtros compactos;
- o mapa mostra piso, grade, paredes e elementos genericos do restaurante;
- o mapa ocupa a maior parte da tela;
- as mesas podem ser arrastadas no modo Layout, no mesmo mapa;
- toque simples abre um popover proximo a mesa, com pedido e acoes rapidas;
- toque duplo abre ou reaproveita a comanda;
- a legenda e os comandos secundarios ficam no menu de opcoes para nao poluir os nos pequenos.

## Arquivos principais

- `lib/modules/mesa/page/mesa_page.dart`
  - monta a tela focada no canvas, nos filtros de area e no resumo flutuante.
- `lib/modules/mesa/controller/floor_plan_controller.dart`
  - concentra regras de negocio: status, edicao, movimentacao, uniao, separacao e abertura de comanda.
- `lib/modules/mesa/widget/floor_plan_canvas.dart`
  - renderiza a planta visual com pan/zoom, textura, paredes e controles do mapa.
- `lib/modules/mesa/widget/table_node.dart`
  - desenha cada mesa no mapa com formato, cadeiras, cor de status e suporte a acessibilidade.
- `lib/modules/mesa/widget/restaurant_area_tab.dart`
  - renderiza os filtros compactos de ambientes.
- `lib/modules/mesa/widget/table_editor_sheet.dart`
  - cria/edita mesa, mostra pre-visualizacao, presets de tamanho e valida entradas antes de enviar ao controller.
- `test/modules/mesa/floor_plan_controller_test.dart`
  - cobre regras importantes e renderizacao mobile sem overflow.

## Regras reforcadas

O controller segue sendo a fonte de verdade para as regras:

- mesa precisa ter codigo, capacidade entre 1 e 12 e dimensoes legiveis;
- pessoas sentadas nao podem ultrapassar a capacidade da mesa;
- nao pode existir codigo duplicado dentro da mesma area;
- mesa so pode ser unida com outra mesa da mesma area;
- mesas com comandas ativas diferentes nao podem ser unidas;
- mesa agrupada reaproveita a mesma comanda do grupo;
- mesa com comanda ativa nao pode ser movida para outra area pela edicao;
- mesa com comanda ativa precisa manter ao menos uma pessoa sentada;
- mesa agrupada precisa ser separada antes de trocar de area;
- liberar mesa limpa comanda, cliente, pessoas sentadas, itens e total parcial;
- arraste respeita margem do canvas para nao cortar cadeiras e bordas visuais.
- durante o arraste a mesa se move de forma continua; o encaixe na grade acontece apenas ao soltar.

## Status operacional

O status visual e derivado por `resolveStatus`:

- `withOrder`: existe comanda ativa;
- `awaitingRelease1H`: ha pessoas sentadas e ultimo movimento passou de 1 hora;
- `noOrder30Min`: ha pessoas sentadas e ultimo movimento passou de 30 minutos;
- `occupied`: ha pessoas sentadas sem comanda ativa recente;
- `free`: mesa sem pessoas e sem comanda;
- `attention`: estado manual de atencao quando nao ha ocupacao ativa.

## Modo operar e modo Layout

O mapa tem dois comportamentos:

- Operar: o usuario consulta mesa e abre pedido/comanda.
- Layout: o usuario reposiciona mesas arrastando no mapa e toca na mesa para editar seus dados.

O controle flutuante `Modo layout` bloqueia ou libera os comandos de planta. Quando o layout esta ativo, o usuario pode:

- criar mesa;
- arrastar mesa;
- unir mesas proximas;
- editar mesa ao tocar nela.

Com o layout bloqueado, o toque abre o popover operacional da mesa. O popover mostra status, tempo, itens, parcial, acesso a comanda e um atalho para os detalhes completos.

## Uniao direta no mapa

Quando uma mesa e arrastada para perto de outra mesa valida, o controller guarda a origem e o alvo sugeridos. O banner flutuante do canvas habilita a acao `Unir`.

A uniao continua respeitando as regras:

- precisa ser na mesma area;
- nenhuma das mesas pode estar em outro grupo;
- se ambas tiverem comanda ativa, a comanda precisa ser a mesma;
- ao unir, a mesa alvo e encaixada ao lado ou abaixo da mesa origem conforme a direcao mais natural.

## Como evitar overflow

O visual da mesa foi reduzido para caber em nos pequenos:

- o status dentro da mesa usa icone ou texto curto;
- o resumo operacional fica em um popover contextual e os detalhes completos ficam no painel inferior sob demanda;
- os filtros de area usam altura fixa e barra de ocupacao;
- no mobile, o mapa recebe o espaco restante da tela e a legenda abre pelo menu;
- o teste de widget renderiza uma largura de 393 px para capturar regressao de overflow.

## Testes adicionados

Os testes cobrem:

- bloqueio de codigo duplicado e pessoas acima da capacidade;
- sugestao de uniao ao aproximar mesas;
- movimento suave com delta pequeno antes do snap;
- uniao direta das mesas sugeridas no mapa;
- bloqueio de uniao quando existem comandas diferentes;
- bloqueio de troca de area e remocao de pessoas quando ha comanda ativa;
- renderizacao mobile da pagina de mesas sem overflow.
- abertura do popover operacional e ativacao do modo Layout no mesmo mapa.

Comando usado:

```powershell
& 'C:\Users\Guilherme Hojak\flutter\bin\flutter.bat' test test\modules\mesa\floor_plan_controller_test.dart
```
