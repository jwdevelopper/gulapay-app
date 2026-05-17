class LoteCreateRequest {
  int? insumoId;
  String? codigo;
  String? validade;
  double? quantidadeInicial;
  double? unidadeId;
  double? custoUnitario;

  LoteCreateRequest({
    this.insumoId,
    this.codigo,
    this.validade,
    this.quantidadeInicial,
    this.unidadeId,
    this.custoUnitario,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['insumo'] = this.insumoId;
    data['codigo'] = this.codigo;
    data['validade'] = this.validade;
    data['quantidadeInicial'] = this.quantidadeInicial;
    data['unidadeId'] = this.unidadeId;
    data['custoUnitario'] = this.custoUnitario;
    return data;
  }
}
