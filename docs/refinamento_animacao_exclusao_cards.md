# Refinamento da animação de exclusão dos cards

## Objetivo

Fazer o painel de exclusão ser percebido como um card completo posicionado
abaixo do item da lista, evitando o efeito de uma faixa vermelha que nasce na
borda direita durante o arraste.

## Diagnóstico

A implementação anterior calculava a largura do vermelho com base no progresso
do gesto. Embora existisse uma sobreposição adicional de 32 px, essa área
permanecia totalmente coberta e não comunicava profundidade. Além disso, o
`Dismissible` recorta seu `background` exatamente na área revelada, mantendo a
divisão vertical reta.

## Estrutura introduzida

O `AppCartaoDeslizavel` agora utiliza duas camadas reais:

```dart
Stack(
  children: [
    Positioned.fill(child: PainelVermelhoCompleto()),
    Dismissible(child: CardPrincipalMovel()),
  ],
);
```

O painel vermelho:

- existe com a largura e altura completas desde o primeiro frame;
- fica fora do `background` interno do `Dismissible`;
- não cresce nem muda de tamanho com o progresso;
- mantém o gradiente, bordas, rótulo e ícone já utilizados pelo sistema.

O card principal:

- continua sendo movimentado pelo `Dismissible`;
- mantém exatamente 100% da largura e altura durante todo o gesto;
- projeta uma sombra progressiva sobre a camada vermelha;
- não revela bordas vermelhas nas partes superior ou inferior.

O progresso controla apenas a sombra do card superior e a apresentação de
`Excluir` e da lixeira. A confirmação, o retorno booleano e a remoção do item
não foram alterados.

## Abrangência

Produtos e Entregadores reutilizam
`lib/core/widgets/app_cartao_deslizavel.dart`, portanto recebem o mesmo padrão
sem duplicação.

## Testes atualizados

`test/core/widgets/app_cartao_deslizavel_test.dart` verifica:

1. abertura curta somente com a lixeira;
2. entrada do rótulo apenas quando existe espaço;
3. painel vermelho mantendo 100% das dimensões antes e durante o gesto;
4. card principal mantendo as mesmas dimensões durante o arraste;
5. cancelamento preservando o item.
