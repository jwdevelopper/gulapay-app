import 'package:flutter/material.dart';

/// Paleta única da aplicação (laranja-areia).
///
/// Fonte única de cor do GulaPay. Consolidou aqui tudo o que antes vivia
/// espalhado em cinco lugares: as três paletas de módulo (`ProdutosPalette`,
/// `EntregadoresPalette`, `EstoquePalette`), a `_WarmPalette` privada do
/// formulário de produto e a `PaletaApp` intermediária.
///
/// Onde os valores divergiam entre as paletas antigas, prevaleceram os
/// tons originais do `AppTema` — a identidade visual usada pela navegação
/// principal (AppBar, drawer, barra inferior).
///
/// Convenção de uso:
/// - [fundo] — fundo da tela (Scaffold);
/// - [superficie] / [superficieAlt] — cartões, folhas e campos sobre o fundo;
/// - [preenchimentoCampo] — preenchimento de ícones e caixas internas;
/// - [primaria] — ações e destaques; [primariaEscura] em ícones de chrome;
///   [primariaPressionada] no estado pressionado; [primariaSuave] em
///   estados desabilitados;
/// - [texto] / [textoSecundario] — texto principal e de apoio;
/// - [borda] / [bordaSuave] — contornos de cartão e divisores;
/// - [erro], [avisoFundo], [avisoBorda], [sucesso] — estados semânticos;
/// - [sombra] / [sombraCampo] — elevação de cartões e de campos.
class AppTema {
  const AppTema._();

  // ── Superfícies ──────────────────────────────────────────────────────
  static const fundo = Color(0xFFFFF8EC);
  static const superficie = Colors.white;
  static const superficieAlt = Color(0xFFFFFDF9);
  static const preenchimentoCampo = Color(0xFFFFF4E8);

  // ── Marca ────────────────────────────────────────────────────────────
  static const primaria = Color(0xFFEC8550);
  static const primariaEscura = Color(0xFFB8825A);
  static const primariaPressionada = Color(0xFFE85F1E);
  static const primariaSuave = Color(0xFFF8C39C);

  // ── Texto ────────────────────────────────────────────────────────────
  static const texto = Color(0xFF2A1F12);
  static const textoSecundario = Color(0xFF8A6A2C);

  // ── Contornos ────────────────────────────────────────────────────────
  static const borda = Color(0xFFE8DCC4);
  static const bordaSuave = Color(0xFFF0E3D0);

  // ── Estados semânticos ───────────────────────────────────────────────
  static const erro = Color(0xFFD96A4A);

  /// Fundo suave do vermelho de erro, para etiquetas e faixas negativas.
  /// Antes cada tela escolhia o seu (`Colors.red.shade100`, `#F9E3DF`).
  static const erroFundo = Color(0xFFF9E3DF);
  static const avisoFundo = Color(0xFFFBF1D6);
  static const avisoBorda = Color(0xFFE9C48D);

  /// Verde-mar. Vinha divergente entre as paletas antigas (`#2E8B57` em
  /// Entregadores, `#4CAF50` em Estoque); unificado no tom mais discreto,
  /// que combina melhor com a paleta quente.
  static const sucesso = Color(0xFF2E8B57);

  /// Azul informativo. Único tom frio da paleta, reservado a rótulos que
  /// precisam se distinguir dos estados (o tipo VOLUME das unidades de
  /// medida). Antes era o `#5B8FD4` solto na tela de unidades.
  static const info = Color(0xFF5B8FD4);

  /// Fundo suave do verde de sucesso, para ícones e faixas positivas.
  /// Antes divergia por tela (`#E8F5E9` no card de estoque, `#E3F1E8` no
  /// detalhe do lote).
  static const sucessoFundo = Color(0xFFE8F5E9);

  // ── Elevação ─────────────────────────────────────────────────────────
  /// Sombra padrão dos cartões.
  static const sombra = Color(0x1A9C5A1E);

  /// Sombra mais suave, usada na moldura dos campos de formulário.
  static const sombraCampo = Color(0x0F9C5A1E);

  // ── Mapa de mesas ────────────────────────────────────────────────────
  // Tokens do editor de salão. Vieram da antiga `GulaColors`, que era uma
  // sexta paleta paralela usada só pelo módulo de mesas. Ficam aqui, e não
  // no módulo, para que o app tenha uma única fonte de cor.

  /// Fundo da área de desenho do mapa (mais escuro que [fundo], para o
  /// salão se destacar da tela).
  static const canvasMapa = Color(0xFFEEE7D7);

  /// Mesa livre.
  static const mesaLivre = Color(0xFFEFE7D6);

  /// Mesa ocupada.
  static const mesaOcupada = Color(0xFFC8A27D);

  /// Mesa em atenção — sem pedido há mais de 30 min.
  static const mesaAtencao = Color(0xFFB7C7DA);

  /// Mesa crítica — aguardando liberação há mais de 1 h.
  static const mesaCritica = Color(0xFFD66A3A);

  // ── Tema global ──────────────────────────────────────────────────────

  /// `ThemeData` único da aplicação, aplicado no `MaterialApp`.
  ///
  /// Antes o app subia com `ColorScheme.fromSeed(seedColor:
  /// Colors.blueAccent)` — um azul que vazava em todo componente Material
  /// que não pintasse a própria cor (calendário, diálogos, `TextField`,
  /// `Chip`, indicadores de progresso). Agora o `ColorScheme` deriva de
  /// [primaria] e cada componente tem seu tema declarado abaixo.
  static ThemeData claro() {
    final esquema =
        ColorScheme.fromSeed(
          seedColor: primaria,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaria,
          onPrimary: Colors.white,
          surface: superficie,
          onSurface: texto,
          error: erro,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      dividerColor: bordaSuave,
      appBarTheme: const AppBarTheme(
        backgroundColor: fundo,
        foregroundColor: texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borda),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: superficie,
        selectedColor: primaria,
        secondarySelectedColor: primaria,
        labelStyle: const TextStyle(color: texto, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borda),
        ),
        side: const BorderSide(color: borda),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficieAlt,
        hintStyle: const TextStyle(color: textoSecundario),
        labelStyle: const TextStyle(color: texto),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaria, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: erro),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: erro, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaria,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primariaSuave.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: texto,
          backgroundColor: superficieAlt,
          side: const BorderSide(color: borda),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaria),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaria),
      dialogTheme: DialogThemeData(
        backgroundColor: superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: superficie,
        surfaceTintColor: Colors.transparent,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: superficie,
        headerBackgroundColor: primaria,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        todayForegroundColor: const WidgetStatePropertyAll(primariaPressionada),
        todayBorder: const BorderSide(color: primariaPressionada),
        weekdayStyle: const TextStyle(
          color: textoSecundario,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: borda,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: texto,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: texto, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: texto, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: texto, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: texto),
        bodyMedium: TextStyle(color: texto),
        bodySmall: TextStyle(color: textoSecundario),
      ),
    );
  }
}
