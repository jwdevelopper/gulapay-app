class LoteUpdate {
  String? codigo;
  String? validade;
  bool? ativo;

  LoteUpdate({
    this.codigo,
    this.validade,
    this.ativo
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codigo'] = this.codigo;
    data['validade'] = this.validade;
    data['ativo'] = this.ativo;
    return data;
  }
}
