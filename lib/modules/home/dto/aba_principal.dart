import 'package:flutter/material.dart';

/// Uma aba do menu principal do app.
///
/// A [Home] mantém a lista completa de abas e deriva dela três coisas: os
/// itens do drawer, os itens da barra inferior e a página exibida no
/// `IndexedStack`.
///
/// [rotuloInferior] existe separado de [tituloAppBar] porque a barra
/// inferior tem pouco espaço — "Entregas" cabe onde "Entregadores" não
/// caberia. [apenasAdmin] esconde a aba de quem não tem perfil
/// `ADMINISTRADOR`.
class AbaPrincipal {
  /// Texto exibido na AppBar e no item do drawer.
  final String tituloAppBar;

  /// Texto curto da barra inferior; também é a chave usada para decidir
  /// quais abas são fixas na barra.
  final String rotuloInferior;

  final IconData icone;

  /// Conteúdo da aba. Fica montado o tempo todo dentro do `IndexedStack`,
  /// preservando estado ao alternar entre abas.
  final Widget pagina;

  /// Quando `true`, só aparece para o perfil `ADMINISTRADOR`.
  final bool apenasAdmin;

  /// Quando `true`, a aba ganha um lugar fixo na barra inferior.
  ///
  /// A barra comporta poucos itens; as demais abas ficam só no drawer,
  /// atrás do botão "Mais". Antes esta escolha era feita comparando
  /// [rotuloInferior] com uma lista de textos — renomear um rótulo tirava a
  /// aba da barra sem aviso.
  final bool fixaNaBarra;

  const AbaPrincipal({
    required this.tituloAppBar,
    required this.rotuloInferior,
    required this.icone,
    required this.pagina,
    this.apenasAdmin = false,
    this.fixaNaBarra = false,
  });
}
