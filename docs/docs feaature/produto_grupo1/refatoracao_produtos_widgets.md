# Refatoracao da tela de produtos

Este documento explica de forma didatica como a parte de produtos foi reorganizada para ficar mais facil de manter, reutilizar e evoluir.

## Objetivo da mudanca

- Reduzir o tamanho do arquivo principal da pagina de produtos.
- Separar widgets visuais em arquivos proprios.
- Corrigir a abertura da sidebar quando a area de produtos estiver ativa.
- Extrair o `BottomBar` para uma pasta reutilizavel fora de `produtos`.

## Como ficou a estrutura

### Pagina principal

- `lib/modules/produto/page/produtos_page.dart`

Esse arquivo agora ficou responsavel por:

- carregar categorias e produtos;
- guardar os estados de busca, ordenacao e filtros;
- abrir tela de cadastro/edicao;
- montar a tela usando widgets menores.

Ou seja: ele coordena a tela, mas nao carrega mais toda a parte visual sozinho.

### Modelos auxiliares

- `lib/modules/produto/models/produto_list_filter.dart`
- `lib/modules/produto/models/produto_sort_option.dart`

Esses arquivos concentram dados da listagem:

- `ProdutoListFilter` guarda os filtros aplicados;
- `ProdutoSortOption` define as opcoes de ordenacao exibidas no bottom sheet.

Isso evita espalhar varias variaveis soltas pela tela.

### Widgets de produtos

Os widgets foram separados em `lib/modules/produto/widgets/`.

Principais arquivos:

- `produto_page_header.dart`: cabecalho da tela com menu, voltar e filtros.
- `produto_search_field.dart`: campo de busca.
- `produto_category_chips.dart`: faixa horizontal com chips de categoria.
- `produto_results_header.dart`: linha com quantidade de resultados e ordenacao.
- `produto_card.dart`: card visual de cada produto.
- `empty_state_card.dart`: estado vazio para lista sem itens ou sem resultados.
- `produto_sort_sheet.dart`: bottom sheet de ordenacao.
- `produto_filter_sheet.dart`: bottom sheet de filtros.
- `produtos_palette.dart`: cores usadas pelos widgets da tela.

Com isso, cada parte da interface ficou isolada e mais facil de localizar.

## BottomBar reutilizavel

O `BottomBar` saiu de `produtos` e agora esta em:

- `lib/shared/bottom_bar/bottom_bar.dart`

Ele foi transformado em um componente reutilizavel com:

- lista de itens;
- indice selecionado;
- callback de clique;
- cores configuraveis.

Assim o professor pode reaproveitar a base visual em outros modulos sem depender da tela de produtos.

## Correcao da sidebar

O problema da sidebar acontecia porque a `Home` escondia o shell quando `Produtos` era selecionado.

Arquivos envolvidos:

- `lib/modules/home/page/home_page.dart`
- `lib/modules/produto/page/produto_page.dart`

Agora o fluxo esta assim:

1. A `Home` continua tendo o `Drawer`.
2. A `Home` passa uma funcao para `ProdutoPage`.
3. A `ProdutoPage` repassa essa funcao para `ProdutosPage`.
4. O botao de menu no header chama essa funcao e abre o drawer pai.

Resultado: a sidebar volta a ficar utilizavel mesmo dentro da tela de produtos.

## Vantagem pratica da nova organizacao

- Fica mais rapido encontrar cada trecho visual.
- Fica mais seguro mexer em um widget sem quebrar a tela inteira.
- O `BottomBar` agora pode ser copiado/reutilizado com mais facilidade.
- A pagina principal ficou mais legivel para quem for dar manutencao depois.

## Regra mental para manutencao futura

Se a mudanca for de layout ou componente visual:

- tente colocar em `widgets/`.

Se a mudanca for dado de filtro, ordenacao ou configuracao da lista:

- tente colocar em `models/`.

Se a mudanca for apenas orquestracao da tela:

- deixe em `produtos_page.dart`.

Essa divisao ajuda a manter a pagina crescendo sem voltar a ficar monolitica.
