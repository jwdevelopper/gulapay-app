class Lote {
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

  Lote({
    this.id,
    this.insumoId,
    this.insumoNome,
    this.unidadePadraoSimbolo,
    this.codigo,
    this.validade,
    this.quantidadeInicial,
    this.quantidadeRestante,
    this.custoUnitario,
    this.ativo,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      insumoId: json['insumoId'] is int
          ? json['insumoId'] as int
          : (json['insumoId'] != null
              ? int.tryParse(json['insumoId'].toString())
              : null),
      insumoNome: json['insumoNome'] as String?,
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'] as String?,
      codigo: json['codigo'] as String?,
      validade: json['validade'] as String?,
      quantidadeInicial: _parseDouble(json['quantidadeInicial']),
      quantidadeRestante: _parseDouble(json['quantidadeRestante']),
      custoUnitario: _parseDouble(json['custoUnitario']),
      ativo: json['ativo'] is bool ? json['ativo'] as bool : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Returns days until expiration. Negative means expired.
  int? get diasAteValidade {
    if (validade == null) return null;
    try {
      final dt = DateTime.parse(validade!);
      return dt.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  bool get isVencido {
    final dias = diasAteValidade;
    return dias != null && dias < 0;
  }
}
