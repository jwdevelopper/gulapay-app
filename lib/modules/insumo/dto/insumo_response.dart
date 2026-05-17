class InsumoResponse {
  int? id;
  String? nome;
  int? unidadePadraoId;
  String? unidadePadraoSimbolo;
  String? unidadePadraoNome;
  String? unidadePadrao;
  int? estoqueMinimo;
  int? estoqueAtual;
  bool? abaixoDoMinimo;
  bool? ativo;

  InsumoResponse({
    this.id, 
    this.nome,
    this.unidadePadraoId,
    this.unidadePadraoSimbolo,
    this.unidadePadraoNome,
    this.unidadePadrao,
    this.estoqueMinimo,
    this.estoqueAtual,
    this.ativo
  });

  InsumoResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    unidadePadraoId = json['unidadePadraoId'];
    unidadePadraoSimbolo = json['unidadePadraoSimbolo'];
    unidadePadraoNome = json['unidadePadraoNome'];
    unidadePadrao = json['unidadePadrao'];
    estoqueMinimo = json['estoqueMinimo'];
    estoqueAtual = json['estoqueAtual'];
    abaixoDoMinimo = json['abaixoDoMinimo'];
    ativo = json['ativo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['unidadePadraoId'] = this.unidadePadraoId;
    data['unidadePadraoSimbolo'] = this.unidadePadraoSimbolo;
    data['unidadePadraoNome'] = this.unidadePadraoNome;
    data['unidadePadrao'] = this.unidadePadrao;
    data['estoqueMinimo'] = this.estoqueMinimo;
    data['estoqueAtual'] = this.estoqueAtual;
    data['abaixoDoMinimo'] = this.abaixoDoMinimo;
    data['ativo'] = this.ativo;
    return data;
  }
}
