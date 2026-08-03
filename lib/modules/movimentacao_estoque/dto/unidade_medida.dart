class UnidadeMedida {
  int? id;
  String nome;
  String? simbolo;
  String? tipoMedida;
  double? fatorParaBase;
  bool? ehBase;
  bool? ativo;

  UnidadeMedida({
    this.id,
    required this.nome,
    this.simbolo,
    this.tipoMedida,
    this.fatorParaBase,
    this.ehBase,
    this.ativo,
  });

  factory UnidadeMedida.fromJson(Map<String, dynamic> json) {
    return UnidadeMedida(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] ?? '',
      simbolo: json['simbolo'] as String?,
      tipoMedida: json['tipoMedida'] as String?,
      fatorParaBase: _parseDouble(json['fatorParaBase']),
      ehBase: json['ehBase'] is bool ? json['ehBase'] as bool : null,
      ativo: json['ativo'] is bool ? json['ativo'] as bool : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
