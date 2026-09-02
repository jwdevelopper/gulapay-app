# Mapa de mesas do restaurante

Este documento explica o refinamento feito na tela de mesas e como as regras principais ficaram distribuidas no codigo.

## Objetivo da tela

A tela de mesas agora trabalha mais como uma planta operacional do restaurante:

- o usuario escolhe o ambiente em filtros compactos;
- o mapa mostra piso, grade, paredes e elementos genericos do restaurante;
- as mesas podem ser arrastadas no modo de edicao;
- existe um editor expandido para trabalhar a planta com mais espaco;
- no editor expandido, o canvas ocupa a tela inteira e os controles ficam flutuantes;
- toque simples abre o painel da mesa;
- toque duplo abre ou reaproveita a comanda;
- a legenda fica separada do mapa para evitar poluir os nos pequenos.

## Arquivos principais

- `lib/modules/mesa/page/mesa_page.dart`
  - monta a tela, cabecalho, filtros de area, modo operar/editar, mapa e legenda.
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

## Modo operar e modo editar

O mapa tem dois comportamentos:

- Operar: o usuario consulta mesa e abre pedido/comanda.
- Editar: o usuario reposiciona mesas arrastando no mapa e toca na mesa para editar seus dados.

O canvas possui um botao para abrir o editor expandido. Nesse editor, os comandos sao de planta:

- selecionar ambiente;
- criar mesa;
- arrastar mesa;
- unir mesas proximas;
- editar mesa ao tocar nela.

Comandos de operacao, como abrir pedido, ficam fora do fluxo de edicao para evitar acao acidental.

Visualmente, o editor expandido usa:

- canvas em tela cheia;
- barra superior flutuante com titulo, ambiente e nova mesa;
- painel flutuante com ambientes, estatisticas e acoes;
- painel de mesa com pre-visualizacao do formato, chips de formato e presets de tamanho.

## Uniao direta no mapa

Quando uma mesa e arrastada para perto de outra mesa valida, o controller guarda a origem e o alvo sugeridos. O banner do canvas e o painel do editor habilitam a acao `Unir`.

A uniao continua respeitando as regras:

- precisa ser na mesma area;
- nenhuma das mesas pode estar em outro grupo;
- se ambas tiverem comanda ativa, a comanda precisa ser a mesma;
- ao unir, a mesa alvo e encaixada ao lado ou abaixo da mesa origem conforme a direcao mais natural.

## Como evitar overflow

O visual da mesa foi reduzido para caber em nos pequenos:

- o status dentro da mesa usa icone ou texto curto;
- detalhes completos ficam no painel inferior;
- os filtros de area usam altura fixa e barra de ocupacao;
- no mobile, mapa e legenda ficam em uma lista rolavel;
- o editor expandido tambem e rolavel no mobile;
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
- abertura do editor expandido mobile sem comandos de comanda.

Comando usado:

```powershell
& 'C:\Users\Guilherme Hojak\flutter\bin\flutter.bat' test test\modules\mesa\floor_plan_controller_test.dart
```
