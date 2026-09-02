class MesaSalvarRequisicao {
  final String numero;
  final String? descricao;
  final int capacidade;
  final String? situacao;
  final bool? ativo;

  MesaSalvarRequisicao({
    required this.numero,
    this.descricao,
    required this.capacidade,
    this.situacao,
    this.ativo,
  });

  Map<String, dynamic> paraJson() {
    return {
      'numero': numero,
      if (descricao != null) 'descricao': descricao,
      'capacidade': capacidade,
      if (situacao != null) 'status': situacao,
      if (ativo != null) 'ativo': ativo,
    };
  }
}

class MesaResposta {
  final int? id;
  final String? numero;
  final String? descricao;
  final int? capacidade;
  final String? situacao;
  final bool? ativo;
  final String? mensagem;

  MesaResposta({
    this.id,
    this.numero,
    this.descricao,
    this.capacidade,
    this.situacao,
    this.ativo,
    this.mensagem,
  });

  factory MesaResposta.deJson(Map<String, dynamic> json) {
    return MesaResposta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      numero: json['numero']?.toString(),
      descricao: json['descricao']?.toString(),
      capacidade: json['capacidade'] is int
          ? json['capacidade'] as int
          : int.tryParse('${json['capacidade']}'),
      situacao: json['status']?.toString(),
      ativo: json['ativo'] as bool?,
      mensagem: json['message']?.toString(),
    );
  }
}

// Compatibilidade com os consumidores atuais fora do modulo de mesas.
typedef MesaDto = MesaResposta;
