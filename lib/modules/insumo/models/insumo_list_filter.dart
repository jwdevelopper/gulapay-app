class InsumosFilters {
  final String nome;
  final int? unidadePadraoId;
  final double? estoqueAtual;
  final double? estoqueMinimo;
  final bool? abaixoDoMinimo;
  final bool? ativo;

  const InsumosFilters({
    this.nome = '',
    this.unidadePadraoId,
    this.estoqueAtual,
    this.estoqueMinimo,
    this.abaixoDoMinimo,
    this.ativo,
  });

  bool get hasActiveFilter {
    if (nome.trim().isNotEmpty) return true;
    if (unidadePadraoId != null) return true;
    if (estoqueAtual != null) return true;
    if (estoqueMinimo != null) return true;
    if (abaixoDoMinimo != null) return true;
    if (ativo != null) return true;
    return false;
  }

  InsumosFilters copyWith({
    String? nome,
    int? unidadePadraoId,
    bool clearUnidadePadraoId = false,
    double? estoqueAtual,
    bool clearEstoqueAtual = false,
    double? estoqueMinimo,
    bool clearEstoqueMinimo = false,
    bool? abaixoDoMinimo,
    bool? ativo,
  }) {
    return InsumosFilters(
      nome: nome ?? this.nome,
      unidadePadraoId: clearUnidadePadraoId ? null : (unidadePadraoId ?? this.unidadePadraoId),
      estoqueAtual: clearEstoqueAtual ? null : (estoqueAtual ?? this.estoqueAtual),
      estoqueMinimo: clearEstoqueMinimo ? null : (estoqueMinimo ?? this.estoqueMinimo),
      abaixoDoMinimo: abaixoDoMinimo ?? this.abaixoDoMinimo,
      ativo: ativo ?? this.ativo,
    );
  }

  InsumosFilters clearUnidade() {
    return copyWith(clearUnidadePadraoId: true);
  }

}