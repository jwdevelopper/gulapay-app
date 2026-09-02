import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';

/// Tudo relacionado a data na aplicação, em um só lugar:
///
/// - [abrirSeletorData] — abre o calendário temático (API imperativa, para
///   quem não tem um campo na tela, como o filtro por período);
/// - [AppCampoData] — campo tocável que exibe a data e abre o calendário
///   (API declarativa, para formulários);
/// - [formatarDataBr] / [formatarDataIso] — conversões de exibição e de
///   contrato com a API.
///
/// As duas APIs coexistem de propósito: o campo cobre o caso comum de
/// formulário, e a função atende quem precisa do calendário isolado.

// ---------------------------------------------------------------------------
// Calendário
// ---------------------------------------------------------------------------

/// Abre o calendário do app já vestido com a paleta quente.
///
/// O `showDatePicker` do Flutter herda o `Theme` do contexto. Como o
/// `MaterialApp` do projeto usa `ColorScheme.fromSeed(seedColor:
/// Colors.blueAccent)`, chamá-lo direto abre um calendário **azul** num app
/// laranja. Esta função envolve a chamada num `Theme` derivado de
/// [PaletaApp], garantindo o mesmo visual em toda a aplicação.
///
/// Devolve `null` se o usuário cancelar.
Future<DateTime?> abrirSeletorData(
  BuildContext context, {
  DateTime? dataInicial,
  DateTime? dataMinima,
  DateTime? dataMaxima,
  String textoAjuda = 'Selecione a data',
  String textoConfirmar = 'Confirmar',
  String textoCancelar = 'Cancelar',
}) {
  final hoje = DateTime.now();
  final minima = dataMinima ?? DateTime(hoje.year - 5);
  final maxima = dataMaxima ?? DateTime(hoje.year + 10);

  return showDatePicker(
    context: context,
    initialDate: _entre(dataInicial ?? hoje, minima, maxima),
    firstDate: minima,
    lastDate: maxima,
    helpText: textoAjuda,
    confirmText: textoConfirmar,
    cancelText: textoCancelar,
    builder: (context, filho) => Theme(
      data: _temaCalendario(Theme.of(context)),
      child: filho ?? const SizedBox.shrink(),
    ),
  );
}

/// Garante que a data inicial caia dentro do intervalo permitido — fora
/// dele o `showDatePicker` lança asserção.
DateTime _entre(DateTime valor, DateTime minima, DateTime maxima) {
  if (valor.isBefore(minima)) return minima;
  if (valor.isAfter(maxima)) return maxima;
  return valor;
}

ThemeData _temaCalendario(ThemeData base) {
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: PaletaApp.primary,
      onPrimary: Colors.white,
      surface: PaletaApp.surface,
      onSurface: PaletaApp.text,
      secondary: PaletaApp.primarySoft,
      onSecondary: PaletaApp.text,
      error: PaletaApp.error,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: PaletaApp.surface,
      headerBackgroundColor: PaletaApp.primary,
      headerForegroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      dayForegroundColor: const WidgetStatePropertyAll(PaletaApp.text),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? PaletaApp.primary
            : Colors.transparent,
      ),
      todayForegroundColor: const WidgetStatePropertyAll(
        PaletaApp.primaryPressed,
      ),
      todayBorder: const BorderSide(color: PaletaApp.primaryPressed),
      yearForegroundColor: const WidgetStatePropertyAll(PaletaApp.text),
      weekdayStyle: const TextStyle(
        color: PaletaApp.textMuted,
        fontWeight: FontWeight.w600,
      ),
      dividerColor: PaletaApp.border,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: PaletaApp.primary),
    ),
  );
}

// ---------------------------------------------------------------------------
// Campo
// ---------------------------------------------------------------------------

/// Campo de data: mostra a data escolhida em `dd/mm/aaaa` e abre o
/// calendário temático ([abrirSeletorData]) ao toque.
///
/// Trabalha com [DateTime] em vez de texto livre — não há como digitar uma
/// data inválida, o que elimina o 400 do backend por formato incorreto.
class AppCampoData extends StatelessWidget {
  final DateTime? valor;
  final String dica;
  final bool erro;
  final DateTime? dataMinima;
  final DateTime? dataMaxima;
  final String textoAjuda;
  final ValueChanged<DateTime> aoSelecionar;

  const AppCampoData({
    super.key,
    required this.valor,
    required this.aoSelecionar,
    this.dica = 'dd/mm/aaaa',
    this.erro = false,
    this.dataMinima,
    this.dataMaxima,
    this.textoAjuda = 'Selecione a data',
  });

  Future<void> _abrir(BuildContext context) async {
    final escolhida = await abrirSeletorData(
      context,
      dataInicial: valor,
      dataMinima: dataMinima,
      dataMaxima: dataMaxima,
      textoAjuda: textoAjuda,
    );
    if (escolhida != null) aoSelecionar(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final preenchido = valor != null;
    return InkWell(
      onTap: () => _abrir(context),
      borderRadius: BorderRadius.circular(DecoracoesApp.raioCampo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: DecoracoesApp.campo(erro: erro),
        child: Row(
          children: [
            Expanded(
              child: Text(
                preenchido ? formatarDataBr(valor!) : dica,
                style: TextStyle(
                  color: preenchido ? PaletaApp.text : PaletaApp.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: PaletaApp.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formatação
// ---------------------------------------------------------------------------

/// Formata para exibição em pt-BR (`dd/mm/aaaa`).
String formatarDataBr(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

/// Formata no padrão trocado com a API (`aaaa-mm-dd`).
String formatarDataIso(DateTime data) {
  final mes = data.month.toString().padLeft(2, '0');
  final dia = data.day.toString().padLeft(2, '0');
  return '${data.year}-$mes-$dia';
}
