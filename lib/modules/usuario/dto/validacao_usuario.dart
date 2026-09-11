import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/usuario/dto/rotulos_usuario.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_create_request.dart';

/// Retrato dos dados do formulário de usuário.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e o [ValidadorUsuario] decide se dá para salvar.
class DadosUsuario {
  final String nome;
  final String login;
  final String senha;

  /// `ADMINISTRADOR`, `CAIXA` ou `GARCOM`.
  final String perfil;

  /// Percentual de comissão, como digitado (pt-BR). Só tem efeito em
  /// `GARCOM` (seção 4.2).
  final String percentualComissao;

  const DadosUsuario({
    this.nome = '',
    this.login = '',
    this.senha = '',
    this.perfil = RotulosUsuario.caixa,
    this.percentualComissao = '',
  });

  DadosUsuario copiarCom({
    String? nome,
    String? login,
    String? senha,
    String? perfil,
    String? percentualComissao,
  }) => DadosUsuario(
    nome: nome ?? this.nome,
    login: login ?? this.login,
    senha: senha ?? this.senha,
    perfil: perfil ?? this.perfil,
    percentualComissao: percentualComissao ?? this.percentualComissao,
  );

  /// A comissão só existe para garçom.
  bool get exigeComissao => RotulosUsuario.exigeComissao(perfil);

  double? get comissaoNumero => parseNumeroBr(percentualComissao);

  /// Payload de `POST /usuarios`.
  ///
  /// A comissão vai como `null` fora do perfil garçom — mandar um número
  /// ali faria o backend recusar, e guardar comissão de caixa não teria
  /// significado.
  UsuarioCriarRequisicao paraCriacao() => UsuarioCriarRequisicao(
    login: login.trim(),
    nome: nome.trim(),
    senha: senha,
    perfil: perfil,
    percentualComissao: exigeComissao ? comissaoNumero : null,
  );
}

/// Regras de preenchimento do formulário de usuário.
class ValidadorUsuario {
  const ValidadorUsuario._();

  static const nomeTamanhoMinimo = 3;
  static const loginTamanhoMinimo = 3;
  static const senhaTamanhoMinimo = 6;

  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome.';
    if (nome.length < nomeTamanhoMinimo) {
      return 'O nome deve ter no mínimo $nomeTamanhoMinimo caracteres.';
    }
    return null;
  }

  static String? validarLogin(String? valor) {
    final login = valor?.trim() ?? '';
    if (login.isEmpty) return 'Informe o login.';
    if (login.length < loginTamanhoMinimo) {
      return 'O login deve ter no mínimo $loginTamanhoMinimo caracteres.';
    }
    return null;
  }

  /// A senha não é aparada: espaço no começo ou no fim é caractere válido,
  /// e cortá-lo faria o login falhar depois sem explicação.
  static String? validarSenha(String? valor) {
    final senha = valor ?? '';
    if (senha.isEmpty) return 'Informe a senha.';
    if (senha.length < senhaTamanhoMinimo) {
      return 'A senha deve ter no mínimo $senhaTamanhoMinimo caracteres.';
    }
    return null;
  }

  /// Comissão é opcional; quando informada, precisa ser um percentual.
  static String? validarComissao(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    final numero = parseNumeroBr(texto);
    if (numero == null) return 'Valor inválido.';
    if (numero < 0 || numero > 100) {
      return 'A comissão deve ficar entre 0 e 100.';
    }
    return null;
  }

  /// Primeiro problema encontrado, ou `null` quando dá para salvar.
  static String? validar(DadosUsuario d) {
    final basico =
        validarNome(d.nome) ?? validarLogin(d.login) ?? validarSenha(d.senha);
    if (basico != null) return basico;
    return d.exigeComissao ? validarComissao(d.percentualComissao) : null;
  }
}
