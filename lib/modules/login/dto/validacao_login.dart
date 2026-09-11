/// Regras de preenchimento da tela de login.
///
/// Sem Flutter, para poder ser testado sem renderizar nada. O tamanho
/// mínimo da senha espelha o do cadastro de usuário — errar aqui evita uma
/// ida ao servidor para receber 401.
class ValidadorLogin {
  const ValidadorLogin._();

  static const senhaTamanhoMinimo = 6;

  /// O backend autentica por **login** (nome de usuário), não por e-mail:
  /// `POST /auth/login` recebe `{login, senha}`.
  static String? validarLogin(String? valor) =>
      (valor?.trim() ?? '').isEmpty ? 'Informe o login.' : null;

  /// A senha não é aparada: espaço no começo ou no fim é caractere válido.
  static String? validarSenha(String? valor) {
    final senha = valor ?? '';
    if (senha.isEmpty) return 'Informe a senha.';
    if (senha.length < senhaTamanhoMinimo) {
      return 'A senha deve ter no mínimo $senhaTamanhoMinimo caracteres.';
    }
    return null;
  }

  /// Primeiro problema encontrado, ou `null` quando dá para entrar.
  static String? validar({required String login, required String senha}) =>
      validarLogin(login) ?? validarSenha(senha);
}
