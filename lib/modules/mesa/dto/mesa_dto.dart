class MesaDto {
  int? id;
  String? numero;
  String? descricao;
  int? capacidade;
  String? status;
  bool? ativo;
  String? message;

  MesaDto({
    this.id,
    this.numero,
    this.descricao,
    this.capacidade,
    this.status,
    this.ativo,
    this.message,
  });

  MesaDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    descricao = json['descricao'];
    capacidade = json['capacidade'];
    status = json['status'];
    ativo = json['ativo'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['descricao'] = this.descricao;
    data['capacidade'] = this.capacidade;
    data['status'] = this.status;
    data['ativo'] = this.ativo;
    data['message'] = this.message;
    return data;
  }
}