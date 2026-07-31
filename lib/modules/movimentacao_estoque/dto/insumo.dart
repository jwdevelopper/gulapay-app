class Insumo {
  int? id;
  String nome;
  int? unidadePadraoId;
  String? unidadePadraoSimbolo;
  String? unidadePadraoNome;
  double? estoqueMinimo;
  double? estoqueAtual;
  bool? abaixoDoMinimo;
  bool? ativo;

  Insumo({
    this.id,
    required this.nome,
    this.unidadePadraoId,
    this.unidadePadraoSimbolo,
    this.unidadePadraoNome,
    this.estoqueMinimo,
    this.estoqueAtual,
    this.abaixoDoMinimo,
    this.ativo,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] ?? '',
      unidadePadraoId: json['unidadePadraoId'] is int
          ? json['unidadePadraoId'] as int
          : (json['unidadePadraoId'] != null
              ? int.tryParse(json['unidadePadraoId'].toString())
              : null),
      unidadePadraoSimbolo: json['unidadePadraoSimbolo'] as String?,
      unidadePadraoNome: json['unidadePadraoNome'] as String?,
      estoqueMinimo: _parseDouble(json['estoqueMinimo']),
      estoqueAtual: _parseDouble(json['estoqueAtual']),
      abaixoDoMinimo: json['abaixoDoMinimo'] is bool
          ? json['abaixoDoMinimo'] as bool
          : null,
      ativo: json['ativo'] is bool ? json['ativo'] as bool : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Percentage below minimum stock. Returns null if not below.
  double? get percentAbaixo {
    final min = estoqueMinimo ?? 0;
    final atual = estoqueAtual ?? 0;
    if (min <= 0 || atual >= min) return null;
    return ((min - atual) / min * 100);
  }
}
