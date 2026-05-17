class InsumoPatch {
  String? nome;
  int? unidadePadraoId;
  int? estoqueMinimo;
  bool? ativo;

  InsumoPatch({
    this.nome, 
    this.unidadePadraoId, 
    this.estoqueMinimo, 
    this.ativo  
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['unidadePadrao'] = this.unidadePadraoId;
    data['estoqueMinimo'] = this.estoqueMinimo;
    data['ativo'] = this.ativo;
    return data;
  }
}
