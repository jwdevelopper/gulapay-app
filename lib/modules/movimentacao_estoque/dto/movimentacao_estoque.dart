class MovimentacaoEstoque {
  int? id;
  String? tipo;
  int? insumoId;
  String? insumoNome;
  int? loteId;
  int? unidadeId;
  String? unidadeSimbolo;
  double? quantidade;
  double? quantidadeUnidadePadrao;
  String? unidadePadraoSimbolo;
  double? custoUnitario;
  String? justificativa;
  String? dataHora;
  String? responsavel;

  MovimentacaoEstoque({
    this.id,
    this.tipo,
    this.insumoId,
    this.insumoNome,
    this.loteId,
    this.unidadeId,
    this.unidadeSimbolo,
    this.quantidade,
    this.quantidadeUnidadePadrao,
    this.unidadePadraoSimbolo,
    this.custoUnitario,
    this.justificativa,
    this.dataHora,
    this.responsavel,
  });

  factory MovimentacaoEstoque.fromJson(Map<String, dynamic> json) {
    return MovimentacaoEstoque(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      tipo: json['tipo'] as String?,
      insumoId: json['insumoId'] is int
          ? json['insumoId'] as int
          : (json['insumoId'] != null
              ? int.tryParse(json['insumoId'].toString())
              : null),
      insumoNome: json['insumoNome'] as String?,
      loteId: json['loteId'] is int
          ? json['loteId'] as int
          : (json['loteId'] != null
              ? int.tryParse(json['loteId'].toString())
              : null),
      unidadeId: json['unidadeId'] is int
          ? json['unidadeId'] as int
          : (json['unidadeId'] != null
              ? int.tryParse(json['unidadeId'].toString())
              : null),
      unidadeSimbolo: json['unidadeSimbolo'] as String?,
      quantidade: _parseDouble(json['quantidade']),
      quantidadeUnidadePadrao: _parseDouble(json['quantidadeUnidadePadrao']),
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'] as String?,
      custoUnitario: _parseDouble(json['custoUnitario']),
      justificativa: json['justificativa'] as String?,
      dataHora: json['dataHora'] as String?,
      responsavel: json['responsavel'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool get isEntrada =>
      tipo == 'ENTRADA_COMPRA' || tipo == 'ENTRADA_TROCA';

  bool get isSaida =>
      tipo == 'SAIDA_VENDA' ||
      tipo == 'SAIDA_PERDA_VALIDADE' ||
      tipo == 'SAIDA_PERDA_QUEBRA';

  bool get isAjuste => tipo == 'AJUSTE_INVENTARIO';
}
