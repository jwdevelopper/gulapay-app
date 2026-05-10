 class ClienteEndereco {
 String? logradouro;
  String? numero;
  String? complemento;
  String? bairro;
  String? cidade;
  String? uf;
  String? cep;

  ClienteEndereco({
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
    this.cep,
  });

  ClienteEndereco.fromJson(Map<String, dynamic> json) {
    logradouro = json['logradouro'];
    numero = json['numero'];
    complemento = json['complemento'];
    bairro = json['bairro'];
    cidade = json['cidade'];
    uf = json['uf'];
    cep = json['cep'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logradouro'] = this.logradouro;
    data['numero'] = this.numero;
    data['complemento'] = this.complemento;
    data['bairro'] = this.bairro;
    data['cidade'] = this.cidade;
    data['uf'] = this.uf;
    data['cep'] = this.cep;
    return data;
  }
}