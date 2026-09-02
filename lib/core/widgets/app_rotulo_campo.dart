import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';

/// Rótulo de campo de formulário.
///
/// Quando [obrigatorio] é `true`, acrescenta o asterisco em destaque —
/// esta é a **fonte única** do "*" nos formulários, para que a marcação
/// visual e a regra de validação não se separem (antes o asterisco era
/// digitado à mão dentro de cada string de rótulo).
///
/// [acessorio] preenche a ponta direita da linha (ex.: contador de
/// caracteres, "Ordenado por validade (FEFO)").
class AppRotuloCampo extends StatelessWidget {
  final String texto;
  final bool obrigatorio;
  final Widget? acessorio;

  const AppRotuloCampo(
    this.texto, {
    super.key,
    this.obrigatorio = false,
    this.acessorio,
  });

  @override
  Widget build(BuildContext context) {
    final rotulo = Text.rich(
      TextSpan(
        text: texto,
        style: const TextStyle(
          color: PaletaApp.text,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (obrigatorio)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: PaletaApp.error,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );

    if (acessorio == null) return rotulo;
    return Row(children: [rotulo, const Spacer(), acessorio!]);
  }
}

/// Mensagem curta de erro exibida logo abaixo de um campo inválido.
class AppMensagemErroCampo extends StatelessWidget {
  final String texto;
  final bool visivel;

  const AppMensagemErroCampo(this.texto, {super.key, required this.visivel});

  @override
  Widget build(BuildContext context) {
    if (!visivel) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        texto,
        style: const TextStyle(
          color: PaletaApp.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
