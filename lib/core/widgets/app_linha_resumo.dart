import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';

/// Linha "rótulo à esquerda, valor à direita" dos cartões de resumo.
///
/// Unifica as duas cópias privadas `_SummaryRow` que existiam em
/// `movimentacao_form_page` e `produto_form_page`.
class AppLinhaResumo extends StatelessWidget {
  final String rotulo;
  final String valor;

  const AppLinhaResumo({super.key, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            color: PaletaApp.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: PaletaApp.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
