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

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  factory InsumoResponse.fromJson(Map<String, dynamic> json) {
    return InsumoResponse(
      id: json['id'],
      nome: json['nome'],
      unidadePadraoId: json['unidadePadraoId'],
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'],
      unidadePadraoNome: json['unidadePadraoNome'],
      unidadePadrao: json['unidadePadrao'],
      estoqueMinimo: _parseDouble(json['estoqueMinimo']),
      estoqueAtual: _parseDouble(json['estoqueAtual']),
      abaixoDoMinimo: json['abaixoDoMinimo'],
      ativo: json['ativo'],
    );
  }

}
