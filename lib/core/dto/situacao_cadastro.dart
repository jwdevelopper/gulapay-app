/// Recorte por situação de um cadastro com soft delete.
///
/// Todo cadastro de primeira classe do app usa `ativo` em vez de excluir de
/// verdade (RNF08), e toda listagem desses cadastros oferece o mesmo trio de
/// chips. Este enum é a fonte única dele — antes cada tela repetia as
/// strings `'TODOS' / 'ATIVOS' / 'INATIVOS'` e a comparação correspondente.
enum SituacaoCadastro {
  todos('Todos'),
  ativos('Ativos'),
  inativos('Inativos');

  const SituacaoCadastro(this.rotulo);

  /// Texto do chip.
  final String rotulo;

  /// O registro passa por este recorte?
  ///
  /// [ativo] nulo conta como ativo — é o padrão do backend para registros
  /// anteriores à coluna.
  bool aceita(bool? ativo) => switch (this) {
    SituacaoCadastro.todos => true,
    SituacaoCadastro.ativos => ativo ?? true,
    SituacaoCadastro.inativos => !(ativo ?? true),
  };
}
