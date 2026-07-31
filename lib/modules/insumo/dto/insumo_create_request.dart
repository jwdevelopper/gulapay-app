class InsumoCreateRequest {
  String? nome;
  int? unidadePadraoId;
  double? estoqueMinimo;

  InsumoCreateRequest({
    this.nome, 
    this.unidadePadraoId, 
    this.estoqueMinimo
    });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['unidadePadraoId'] = this.unidadePadraoId;
    data['estoqueMinimo'] = this.estoqueMinimo;
    return data;
  }
}
