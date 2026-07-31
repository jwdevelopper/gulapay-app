class Produto {
  int? id;
  String nome;
  String? descricao;
  double? preco;
  String? tipoProduto;
  String? setorProducao;
  int? categoriaId;
  bool? ativo;

  Produto({
    this.id,
    required this.nome,
    this.descricao,
    this.preco,
    this.tipoProduto,
    this.setorProducao,
    this.categoriaId,
    this.ativo,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    double? precoLocal;
    final precoRaw = json['preco'];
    if (precoRaw != null) {
      if (precoRaw is num) {
        precoLocal = precoRaw.toDouble();
      } else {
        precoLocal = double.tryParse(precoRaw.toString());
      }
    }

    return Produto(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: precoLocal,
      tipoProduto: json['tipoProduto'],
      setorProducao: json['setorProducao'],
      categoriaId: json['categoriaId'] is int
          ? json['categoriaId'] as int
          : (json['categoriaId'] != null ? int.tryParse(json['categoriaId'].toString()) : null),
      ativo: json['ativo'] is bool ? json['ativo'] as bool : (json['ativo'] != null ? (json['ativo'].toString() == 'true') : null),
    );
  }

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final map = <String, dynamic>{
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipoProduto': tipoProduto,
      'setorProducao': setorProducao,
      'categoriaId': categoriaId,
    };
    if (forUpdate) map['ativo'] = ativo ?? true;
    return map;
  }
}
