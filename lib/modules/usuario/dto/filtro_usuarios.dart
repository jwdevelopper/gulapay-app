import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';

/// Estado dos filtros da listagem de usuários.
///
/// Objeto de valor puro (sem Flutter). O recorte é em memória: `GET
/// /usuarios` aceita `?perfil=`, mas a tela carrega todos de uma vez para
/// alternar entre os perfis sem ida ao servidor.
class FiltroUsuarios {
  /// Termo digitado. Confere nome e login.
  final String texto;

  /// Perfil escolhido, ou `null` para todos.
  final String? perfil;

  const FiltroUsuarios({this.texto = '', this.perfil});

  /// Nenhum recorte ativo.
  bool get vazio => texto.trim().isEmpty && perfil == null;

  FiltroUsuarios copiarCom({
    String? texto,
    String? perfil,
    bool limparPerfil = false,
  }) => FiltroUsuarios(
    texto: texto ?? this.texto,
    perfil: limparPerfil ? null : (perfil ?? this.perfil),
  );

  /// Alterna o perfil: tocar no que já está escolhido volta para "todos".
  FiltroUsuarios alternarPerfil(String valor) => perfil == valor
      ? copiarCom(limparPerfil: true)
      : copiarCom(perfil: valor);

  List<UsuarioResposta> aplicar(List<UsuarioResposta> usuarios) => usuarios
      .where((u) => _combinaTexto(u) && (perfil == null || u.perfil == perfil))
      .toList();

  bool _combinaTexto(UsuarioResposta u) {
    if (texto.trim().isEmpty) return true;
    return contemTextoBr(u.nome, texto) || contemTextoBr(u.login, texto);
  }
}
