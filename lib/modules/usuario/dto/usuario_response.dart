class UsuarioResposta {
  final int? id;
  final String? login;
  final String? nome;
  final String? perfil;
  final double? percentualComissao;
  final bool? ativo;
  final String? criadoEm;

  UsuarioResposta({
    this.id,
    this.login,
    this.nome,
    this.perfil,
    this.percentualComissao,
    this.ativo,
    this.criadoEm,
  });

  factory UsuarioResposta.deJson(Map<String, dynamic> json) {
    return UsuarioResposta(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      login: json['login'] as String?,
      nome: json['nome'] as String?,
      perfil: json['perfil'] as String?,
      percentualComissao: json['percentualComissao'] == null
          ? null
          : double.tryParse('${json['percentualComissao']}'),
      ativo: json['ativo'] as bool?,
      criadoEm: json['criadoEm']?.toString(),
    );
  }
}
