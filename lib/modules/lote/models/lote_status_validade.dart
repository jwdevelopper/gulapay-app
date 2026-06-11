import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';

/// Situação visual de um lote calculada localmente a partir da validade.
/// O backend não devolve esse status — ele é derivado da diferença entre a
/// data de validade e a data de hoje.
enum LoteStatusValidade {
  vencido,
  ate7Dias,
  ate30Dias,
  ok;

  /// Calcula o status a partir da data ISO (`yyyy-MM-dd`) de validade.
  static LoteStatusValidade calcular(String? validadeIso, {DateTime? hoje}) {
    final validade = LoteFormatadores.parseData(validadeIso);
    if (validade == null) return LoteStatusValidade.ok;

    final agora = hoje ?? DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final inicioValidade =
        DateTime(validade.year, validade.month, validade.day);
    final dias = inicioValidade.difference(inicioHoje).inDays;

    if (dias < 0) return LoteStatusValidade.vencido;
    if (dias <= 7) return LoteStatusValidade.ate7Dias;
    if (dias <= 30) return LoteStatusValidade.ate30Dias;
    return LoteStatusValidade.ok;
  }

  bool get exigeAtencao =>
      this == LoteStatusValidade.vencido || this == LoteStatusValidade.ate7Dias;

  /// Rótulo curto exibido na tag do card.
  String get rotulo {
    switch (this) {
      case LoteStatusValidade.vencido:
        return 'vencido';
      case LoteStatusValidade.ate7Dias:
        return '≤7 dias';
      case LoteStatusValidade.ate30Dias:
        return '≤30 dias';
      case LoteStatusValidade.ok:
        return 'ok';
    }
  }

  Color get cor {
    switch (this) {
      case LoteStatusValidade.vencido:
        return const Color(0xFFC0392B);
      case LoteStatusValidade.ate7Dias:
        return const Color(0xFFE67E22);
      case LoteStatusValidade.ate30Dias:
        return const Color(0xFFB8825A);
      case LoteStatusValidade.ok:
        return const Color(0xFF2E8B57);
    }
  }

  Color get fundo {
    switch (this) {
      case LoteStatusValidade.vencido:
        return const Color(0xFFF9E3DF);
      case LoteStatusValidade.ate7Dias:
        return const Color(0xFFFBEFD9);
      case LoteStatusValidade.ate30Dias:
        return const Color(0xFFFBF1D6);
      case LoteStatusValidade.ok:
        return const Color(0xFFE3F1E8);
    }
  }

  /// Texto humano sobre o vencimento (`Venceu há 2 dias`, `Vence em 5 dias`).
  static String descricaoVencimento(String? validadeIso, {DateTime? hoje}) {
    final validade = LoteFormatadores.parseData(validadeIso);
    if (validade == null) return 'Sem validade';

    final agora = hoje ?? DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final inicioValidade =
        DateTime(validade.year, validade.month, validade.day);
    final dias = inicioValidade.difference(inicioHoje).inDays;

    if (dias < 0) {
      final passados = -dias;
      return passados == 1 ? 'Venceu há 1 dia' : 'Venceu há $passados dias';
    }
    if (dias == 0) return 'Vence hoje';
    if (dias == 1) return 'Vence amanhã';
    return 'Vence em $dias dias';
  }
}
