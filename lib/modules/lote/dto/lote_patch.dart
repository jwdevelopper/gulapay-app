class LotePatch {
  String? codigo;
  String? validade;
  bool? ativo;

  LotePatch({
    this.codigo,
    this.validade,
    this.ativo
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codigo'] = codigo;
    data['validade'] = validade;
    data['ativo'] = ativo;
    return data;
  }
}
