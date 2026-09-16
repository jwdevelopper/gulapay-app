import 'package:flutter/foundation.dart';

/// Registro global das ações de criação usadas pelo "+" da NavBar dinâmica
/// da Home.
///
/// Cada página de cadastro registra, no seu `initState`, a ação que abre o
/// formulário de criação. A chave é o `tituloAppBar` da aba correspondente
/// na Home. Como as páginas vivem em um `IndexedStack` (todas montadas de
/// uma vez), o registro acontece uma única vez na inicialização.
class AcoesCriacao {
  AcoesCriacao._();

  static final Map<String, VoidCallback> _acoes = {};

  static void registrar(String tituloAba, VoidCallback acao) =>
      _acoes[tituloAba] = acao;

  static VoidCallback? de(String tituloAba) => _acoes[tituloAba];
}
