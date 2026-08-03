
class LoteCreateRequest {
  int? insumoId;
  String? codigo;
  String? validade;
  double? quantidadeInicial;
  int? unidadeId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['insumoId'] = this.insumoId;
    data['codigo'] = this.codigo;
    data['validade'] = this.validade;
    data['quantidadeInicial'] = this.quantidadeInicial;
    data['unidadeId'] = this.unidadeId;
    data['custoUnitario'] = this.custoUnitario;
    return data;
  }
}
