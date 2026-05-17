class InsumoEmbutidoRequest {
  String? nome;
  int? unidadePadraoId;
  int? estoqueMinimo;

  InsumoEmbutidoRequest({
    this.nome, 
    this.unidadePadraoId, 
    this.estoqueMinimo
    });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['unidadePadrao'] = this.unidadePadraoId;
    data['estoqueMinimo'] = this.estoqueMinimo;
    return data;
  }
}
