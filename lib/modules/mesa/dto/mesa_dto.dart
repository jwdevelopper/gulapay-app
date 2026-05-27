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
    final data = <String, dynamic>{};
    data['id'] = id;
    data['numero'] = numero;
    data['descricao'] = descricao;
    data['capacidade'] = capacidade;
    data['status'] = status;
    data['ativo'] = ativo;
    data['message'] = message;
    return data;
  }
}
