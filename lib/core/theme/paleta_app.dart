import 'package:flutter/material.dart';

/// Paleta quente única da aplicação (laranja-areia).
///
/// Substitui as três paletas de módulo que existiam antes
/// (`ProdutosPalette`, `EntregadoresPalette` e `EstoquePalette`), cujos
/// valores eram idênticos entre si — mantê-las separadas só criava
/// divergência silenciosa.
///
/// Convenção de uso:
/// - `background` — fundo da tela (Scaffold);
/// - `surface` / `surfaceAlt` — cartões e campos sobre o fundo;
/// - `primary` — ações e destaques; `primaryPressed` no estado pressionado;
///   `primarySoft` em estados desabilitados;
/// - `text` / `textMuted` — texto principal e de apoio;
/// - `border` / `borderSoft` — contornos de cartão e divisores;
/// - `error`, `warningBg`, `warningBorder`, `success` — estados semânticos.
class PaletaApp {
  const PaletaApp._();

  // Superfícies
  static const background = Color(0xFFFCF6EC);
  static const surface = Color(0xFFFFF9F1);
  static const surfaceAlt = Color(0xFFFFFDF9);
  static const inputFill = Color(0xFFFFF4E8);

  // Marca
  static const primary = Color(0xFFF07330);
  static const primaryPressed = Color(0xFFE85F1E);
  static const primarySoft = Color(0xFFF8C39C);

  // Texto
  static const text = Color(0xFF3D261A);
  static const textMuted = Color(0xFFA06E4E);

  // Contornos
  static const border = Color(0xFFE8D8C2);
  static const borderSoft = Color(0xFFF0E3D0);

  // Estados semânticos
  static const error = Color(0xFFD96A4A);
  static const warningBg = Color(0xFFFCEEDC);
  static const warningBorder = Color(0xFFE9C48D);

  /// Verde-mar. Vinha divergente entre as paletas antigas
  /// (`#2E8B57` em Entregadores, `#4CAF50` em Estoque); unificado no tom
  /// mais discreto, que combina melhor com a paleta quente.
  static const success = Color(0xFF2E8B57);

  // Sombra padrão dos cartões
  static const shadow = Color(0x1A9C5A1E);

  /// Sombra mais suave, usada na moldura dos campos de formulário.
  static const sombraCampo = Color(0x0F9C5A1E);
}
