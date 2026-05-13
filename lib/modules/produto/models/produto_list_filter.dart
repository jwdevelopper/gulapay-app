class ProdutoListFilter {
  final int? categoriaId;
  final double? precoMin;
  final double? precoMax;
  final String descricao;
  final String? tipoProduto;
  final String? setorProducao;

  const ProdutoListFilter({
    this.categoriaId,
    this.precoMin,
    this.precoMax,
    this.descricao = '',
    this.tipoProduto,
    this.setorProducao,
  });

  bool get hasActiveFilter {
    if (categoriaId != null) return true;
    if (precoMin != null) return true;
    if (precoMax != null) return true;
    if (descricao.trim().isNotEmpty) return true;
    if (tipoProduto != null && tipoProduto!.isNotEmpty) return true;
    if (setorProducao != null && setorProducao!.isNotEmpty) return true;
    return false;
  }

  ProdutoListFilter copyWith({
    int? categoriaId,
    bool clearCategoriaId = false,
    double? precoMin,
    bool clearPrecoMin = false,
    double? precoMax,
    bool clearPrecoMax = false,
    String? descricao,
    String? tipoProduto,
    bool clearTipoProduto = false,
    String? setorProducao,
    bool clearSetorProducao = false,
  }) {
    return ProdutoListFilter(
      categoriaId: clearCategoriaId ? null : (categoriaId ?? this.categoriaId),
      precoMin: clearPrecoMin ? null : (precoMin ?? this.precoMin),
      precoMax: clearPrecoMax ? null : (precoMax ?? this.precoMax),
      descricao: descricao ?? this.descricao,
      tipoProduto: clearTipoProduto ? null : (tipoProduto ?? this.tipoProduto),
      setorProducao: clearSetorProducao
          ? null
          : (setorProducao ?? this.setorProducao),
    );
  }

  ProdutoListFilter clearCategory() {
    return copyWith(clearCategoriaId: true);
  }
}
