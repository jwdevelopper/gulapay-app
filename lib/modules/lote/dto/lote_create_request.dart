
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
    data['insumoId'] = insumoId;
    data['codigo'] = codigo;
    data['validade'] = validade;
    data['quantidadeInicial'] = quantidadeInicial;
    data['unidadeId'] = unidadeId;
    data['custoUnitario'] = custoUnitario;
    return data;
  }
}
