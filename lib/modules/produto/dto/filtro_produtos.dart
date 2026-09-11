import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

/// Como a vitrine de produtos é ordenada.
enum OrdenacaoProduto {
  destaque('Mais vendidos'),
  precoCrescente('Preço crescente'),
  precoDecrescente('Preço decrescente'),
  nomeCrescente('Nome A-Z'),
  nomeDecrescente('Nome Z-A');

  const OrdenacaoProduto(this.rotulo);

  /// Texto exibido no cabeçalho de resultados.
  final String rotulo;
}

/// Estado de busca, filtros e ordenação da vitrine de produtos.
///
/// Objeto de valor puro (sem Flutter). O backend só filtra por categoria
/// (`GET /produtos?categoriaId=X`); os demais recortes — preço, descrição,
/// tipo, setor — e a ordenação acontecem em memória, sobre a lista já
/// carregada. Por isso [aplicar] existe e é o único lugar que decide o que
/// aparece na tela.
class FiltroProdutos {
  /// Termo da busca livre. Confere nome, descrição e nome da categoria.
  final String busca;

  /// Categoria escolhida nos chips. Também vai como query param.
  final int? categoriaId;

  /// Faixa de preço.
  final double? precoMin;
  final double? precoMax;

  /// Trecho da descrição, do filtro avançado.
  final String descricao;

  /// `UNITARIO`, `COMPOSTO` ou `COMBO`.
  final String? tipoProduto;

  /// `COZINHA`, `BAR` ou `CAIXA`.
  final String? setorProducao;

  final OrdenacaoProduto ordenacao;

  const FiltroProdutos({
    this.busca = '',
    this.categoriaId,
    this.precoMin,
    this.precoMax,
    this.descricao = '',
    this.tipoProduto,
    this.setorProducao,
    this.ordenacao = OrdenacaoProduto.destaque,
  });

  /// Há algum recorte além da busca e da ordenação?
  ///
  /// É o que decide se o cabeçalho mostra "Filtros" ou "Limpar".
  bool get temFiltroAvancado =>
      categoriaId != null ||
      precoMin != null ||
      precoMax != null ||
      descricao.trim().isNotEmpty ||
      (tipoProduto ?? '').isNotEmpty ||
      (setorProducao ?? '').isNotEmpty;

  /// Nada escolhido em lugar nenhum.
  bool get vazio => busca.trim().isEmpty && !temFiltroAvancado;

  FiltroProdutos copiarCom({
    String? busca,
    int? categoriaId,
    bool limparCategoria = false,
    double? precoMin,
    double? precoMax,
    String? descricao,
    String? tipoProduto,
    String? setorProducao,
    OrdenacaoProduto? ordenacao,
  }) => FiltroProdutos(
    busca: busca ?? this.busca,
    categoriaId: limparCategoria ? null : (categoriaId ?? this.categoriaId),
    precoMin: precoMin ?? this.precoMin,
    precoMax: precoMax ?? this.precoMax,
    descricao: descricao ?? this.descricao,
    tipoProduto: tipoProduto ?? this.tipoProduto,
    setorProducao: setorProducao ?? this.setorProducao,
    ordenacao: ordenacao ?? this.ordenacao,
  );

  /// Substitui **apenas** os critérios do filtro avançado, preservando
  /// busca e ordenação.
  ///
  /// É o que a folha de filtros devolve: ela não conhece o campo de busca
  /// nem a ordenação escolhida, e sem isso apagaria os dois ao aplicar.
  FiltroProdutos comAvancados({
    int? categoriaId,
    double? precoMin,
    double? precoMax,
    String descricao = '',
    String? tipoProduto,
    String? setorProducao,
  }) => FiltroProdutos(
    busca: busca,
    ordenacao: ordenacao,
    categoriaId: categoriaId,
    precoMin: precoMin,
    precoMax: precoMax,
    descricao: descricao,
    tipoProduto: tipoProduto,
    setorProducao: setorProducao,
  );

  /// Peneira e ordena a lista.
  ///
  /// [nomeCategoria] resolve o nome da categoria de um produto — a busca
  /// livre também procura por ele, e o `Produto` só guarda o id.
  List<Produto> aplicar(
    List<Produto> produtos, {
    required String Function(int? categoriaId) nomeCategoria,
  }) {
    final lista = produtos
        .where((p) => _combinaCategoria(p))
        .where((p) => _combinaBusca(p, nomeCategoria))
        .where((p) => _combinaPreco(p))
        .where((p) => _combinaDescricao(p))
        .where((p) => _combinaTipo(p))
        .where((p) => _combinaSetor(p))
        .toList();

    _ordenar(lista);
    return lista;
  }

  bool _combinaCategoria(Produto p) =>
      categoriaId == null || p.categoriaId == categoriaId;

  bool _combinaBusca(
    Produto p,
    String Function(int? categoriaId) nomeCategoria,
  ) {
    if (busca.trim().isEmpty) return true;
    // Busca sem acento: procurar por 'acucar' encontra 'Açúcar'.
    return contemTextoBr(p.nome, busca) ||
        contemTextoBr(p.descricao, busca) ||
        contemTextoBr(nomeCategoria(p.categoriaId), busca);
  }

  /// Produto sem preço conta como zero — é como ele aparece na vitrine.
  bool _combinaPreco(Produto p) {
    final preco = p.preco ?? 0;
    if (precoMin != null && preco < precoMin!) return false;
    if (precoMax != null && preco > precoMax!) return false;
    return true;
  }

  bool _combinaDescricao(Produto p) {
    final termo = descricao.trim().toLowerCase();
    if (termo.isEmpty) return true;
    return (p.descricao ?? '').toLowerCase().contains(termo);
  }

  bool _combinaTipo(Produto p) {
    final termo = (tipoProduto ?? '').toUpperCase();
    if (termo.isEmpty) return true;
    return (p.tipoProduto ?? '').toUpperCase().contains(termo);
  }

  bool _combinaSetor(Produto p) {
    final termo = (setorProducao ?? '').toUpperCase();
    if (termo.isEmpty) return true;
    return (p.setorProducao ?? '').toUpperCase().contains(termo);
  }

  /// `destaque` preserva a ordem que veio do backend — é a "ordem padrão"
  /// da vitrine, não um critério calculado aqui.
  void _ordenar(List<Produto> lista) {
    switch (ordenacao) {
      case OrdenacaoProduto.destaque:
        break;
      case OrdenacaoProduto.precoCrescente:
        lista.sort((a, b) => (a.preco ?? 0).compareTo(b.preco ?? 0));
      case OrdenacaoProduto.precoDecrescente:
        lista.sort((a, b) => (b.preco ?? 0).compareTo(a.preco ?? 0));
      // compararTextoBr em vez de compareTo: sem tirar os acentos, 'Água'
      // cairia depois de 'Zebra' na ordem alfabética.
      case OrdenacaoProduto.nomeCrescente:
        lista.sort((a, b) => compararTextoBr(a.nome, b.nome));
      case OrdenacaoProduto.nomeDecrescente:
        lista.sort((a, b) => compararTextoBr(b.nome, a.nome));
    }
  }
}
