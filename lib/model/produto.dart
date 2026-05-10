class Produto {
  int? id;
  String nome;
  String? descricao;
  double preco;
  String tipoProduto;
  String setorProducao;
  int categoriaId;
  bool ativo;

  Produto({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.tipoProduto,
    required this.setorProducao,
    required this.categoriaId,
    this.ativo = true,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: (json['preco'] is num) ? (json['preco'] as num).toDouble() : double.tryParse(json['preco']?.toString() ?? '0') ?? 0,
      tipoProduto: json['tipoProduto'] ?? '',
      setorProducao: json['setorProducao'] ?? '',
      categoriaId: json['categoriaId'] is int ? json['categoriaId'] : int.tryParse(json['categoriaId']?.toString() ?? '0') ?? 0,
      ativo: json['ativo'] == null ? true : (json['ativo'] == true || json['ativo'].toString() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipoProduto': tipoProduto,
      'setorProducao': setorProducao,
      'categoriaId': categoriaId,
      'ativo': ativo,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
