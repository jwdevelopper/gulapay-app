import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';

/// Botão quadrado de ícone usado nos cabeçalhos de tela e formulário.
///
/// Unifica as três cópias privadas que existiam antes
/// (`_FormHeaderIconButton` no formulário de movimentação e
/// `_HeaderIconButton` em `estoque_page` e `produto_form_page`).
///
/// [mostrarSelo] desenha o ponto de destaque no canto superior direito —
/// usado pelo botão de filtros quando há filtro ativo.
class AppBotaoIcone extends StatelessWidget {
  /// Identifica o ponto de destaque nos testes de widget.
  static const chaveSelo = ValueKey('app_botao_icone_selo');

  final IconData icone;
  final VoidCallback? aoTocar;
  final bool mostrarSelo;
  final String? dicaAcessibilidade;

  const AppBotaoIcone({
    super.key,
    required this.icone,
    this.aoTocar,
    this.mostrarSelo = false,
    this.dicaAcessibilidade,
  });

  @override
  Widget build(BuildContext context) {
    final botao = Material(
      color: PaletaApp.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: PaletaApp.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PaletaApp.border),
          ),
          child: mostrarSelo
              ? Stack(
                  children: [
                    Center(child: Icon(icone, color: PaletaApp.text, size: 22)),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        key: chaveSelo,
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: PaletaApp.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(icone, color: PaletaApp.text, size: 22),
        ),
      ),
    );

    if (dicaAcessibilidade == null) return botao;
    return Tooltip(message: dicaAcessibilidade!, child: botao);
  }
}
