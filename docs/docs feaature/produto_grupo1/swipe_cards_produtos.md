# Swipe dos cards de produtos

Este documento explica a nova interacao mobile aplicada nos cards da tela de produtos.

## O que foi implementado

Agora cada card de produto pode ser arrastado levemente para a esquerda.

Quando isso acontece:

- o card desliza de forma suave;
- aparece uma faixa de acoes por tras;
- o usuario pode tocar em `Editar` ou `Excluir`.

Essa abordagem segue um comportamento bem comum em apps mobile e complementa o menu de tres pontos que ja existia.

## Onde ficou a logica

### Card principal

- `lib/modules/produto/widgets/produto_card.dart`

Esse arquivo continua montando o layout visual do card, mas agora tambem informa quais acoes de swipe devem aparecer:

- `Editar`
- `Excluir`

### Container com swipe

- `lib/modules/produto/widgets/produto_card_container.dart`

Aqui ficou a parte principal da interacao.

Esse widget agora:

- controla a animacao horizontal;
- detecta o gesto de arrastar;
- decide se o card deve abrir ou fechar;
- renderiza os botoes atras do card;
- fecha o card antes de executar a acao escolhida.

## Como a interacao funciona

O fluxo interno ficou assim:

1. O usuario arrasta horizontalmente para a esquerda.
2. O `AnimationController` atualiza a abertura do card.
3. Se o gesto passar do limite configurado, o card permanece aberto.
4. Se o gesto for pequeno, o card volta para a posicao original.
5. Ao tocar em uma acao, o card fecha e a callback correspondente eh executada.

## Por que essa estrutura ficou boa

- A logica do gesto nao polui a pagina de produtos.
- O componente visual do card continua separado da interacao.
- As acoes podem ser alteradas depois sem reescrever toda a animacao.
- O comportamento fica mais natural para uso em celular.

## Observacao importante

O menu de tres pontos foi mantido como fallback.

Isso eh bom porque:

- preserva acessibilidade;
- continua funcionando bem em desktop;
- evita depender apenas do gesto de swipe.
