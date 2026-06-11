class LoteResponse {
  int? id;
  int? insumoId;
  String? insumoNome;
  String? unidadePadraoSimbolo;
  String? codigo;
  String? validade;
  double? quantidadeInicial;
  double? quantidadeRestante;
  double? custoUnitario;
  bool? ativo;

  LoteResponse({
    this.id,
    this.insumoId,
    this.insumoNome,
    this.unidadePadraoSimbolo,
    this.codigo,
    this.validade,
    this.quantidadeInicial,
    this.quantidadeRestante,
    this.custoUnitario,
    this.ativo
  });

  factory LoteResponse.fromJson(Map<String, dynamic> json) {
    return LoteResponse(
      id: json['id'],
      insumoId: json['insumoId'],
      insumoNome: json['insumoNome'],
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'],
      codigo: json['codigo'],
      validade: json['validade'],
      quantidadeInicial: (json['quantidadeInicial'] as num?)?.toDouble(),
      quantidadeRestante: (json['quantidadeRestante'] as num?)?.toDouble(),
      custoUnitario: (json['custoUnitario'] as num?)?.toDouble(),
      ativo: json['ativo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['insumoId'] = this.insumoId;
    data['insumoNome'] = this.insumoNome;
    data['codigo'] = this.codigo;
    data['validade'] = this.validade;
    data['quantidadeInicial'] = this.quantidadeInicial;
    data['quantidadeRestante'] = this.quantidadeRestante;
    data['custoUnitario'] = this.custoUnitario;
    data['ativo'] = this.ativo;
    return data;
  }
}
