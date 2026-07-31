class InsumoResponse {
  int? id;
  String? nome;
  int? unidadePadraoId;
  String? unidadePadraoSimbolo;
  String? unidadePadraoNome;
  String? unidadePadrao;
  double? estoqueMinimo;
  double? estoqueAtual;
  bool? abaixoDoMinimo;
  bool? ativo;

  InsumoResponse({
    this.id, 
    this.nome,
    this.unidadePadraoId,
    this.unidadePadraoSimbolo,
    this.unidadePadraoNome,
    this.unidadePadrao,
    this.estoqueMinimo,
    this.estoqueAtual,
    this.abaixoDoMinimo,
    this.ativo
  });

  factory InsumoResponse.fromJson(Map<String, dynamic> json) {
    return InsumoResponse(
      id: json['id'],
      nome: json['nome'],
      unidadePadraoId: json['unidadePadraoId'],
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'],
      unidadePadraoNome: json['unidadePadraoNome'],
      unidadePadrao: json['unidadePadrao'],
      estoqueMinimo: json['estoqueMinimo'],
      estoqueAtual: json['estoqueAtual'],
      abaixoDoMinimo: json['abaixoDoMinimo'],
      ativo: json['ativo'],
    );
  }

}
