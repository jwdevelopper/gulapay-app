class UsuarioCriarRequisicao {
  final String login;
  final String nome;
  final String senha;
  final String perfil;
  final double? percentualComissao;

  UsuarioCriarRequisicao({
    required this.login,
    required this.nome,
    required this.senha,
    required this.perfil,
    this.percentualComissao,
  });

  Map<String, dynamic> paraJson() {
    final dados = <String, dynamic>{
      'login': login,
      'nome': nome,
      'senha': senha,
      'perfil': perfil,
    };
    if (percentualComissao != null) {
      dados['percentualComissao'] = percentualComissao;
    }
    return dados;
  }
}
