class InsumoUpdate {
  String? nome;
  int? unidadePadraoId;
  double? estoqueMinimo;
  bool? ativo;

  InsumoUpdate({
    this.nome, 
    this.unidadePadraoId, 
    this.estoqueMinimo,
    this.ativo
    });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['unidadePadraoId'] = unidadePadraoId;
    data['estoqueMinimo'] = estoqueMinimo;
    data['ativo'] = ativo;
    return data;
  }
}
