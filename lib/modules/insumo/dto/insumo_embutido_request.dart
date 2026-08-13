class InsumoEmbutidoRequest {
  String? nome;
  int? unidadePadraoId;
  double? estoqueMinimo;

  InsumoEmbutidoRequest({
    this.nome, 
    this.unidadePadraoId, 
    this.estoqueMinimo
    });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['unidadePadraoId'] = unidadePadraoId;
    data['estoqueMinimo'] = estoqueMinimo;
    return data;
  }
}
