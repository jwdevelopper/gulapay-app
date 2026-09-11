import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';

/// Campo de texto dos formulários de estoque, com estado de erro embutido.
///
/// Compartilha a moldura com o campo de data e os seletores via
/// [DecoracoesApp.campo], para que os três não possam divergir.
class AppCampoFormulario extends StatelessWidget {
  final TextEditingController controlador;
  final String dica;
  final ValueChanged<String>? aoAlterar;
  final int maxLinhas;
  final TextInputType tipoTeclado;
  final bool erro;

  /// Prefixa `R$ ` e amplia a fonte — usado no custo unitário.
  final bool preco;

  /// Amplia a fonte sem prefixo — usado na quantidade.
  final bool textoGrande;

  final String? sufixo;

  const AppCampoFormulario({
    super.key,
    required this.controlador,
    required this.dica,
    this.aoAlterar,
    this.maxLinhas = 1,
    this.tipoTeclado = TextInputType.text,
    this.erro = false,
    this.preco = false,
    this.textoGrande = false,
    this.sufixo,
  });

  @override
  Widget build(BuildContext context) {
    final destaque = preco || textoGrande;
    return Container(
      decoration: DecoracoesApp.campo(erro: erro),
      child: TextField(
        controller: controlador,
        onChanged: aoAlterar,
        maxLines: maxLinhas,
        keyboardType: tipoTeclado,
        style: TextStyle(
          color: AppTema.texto,
          fontSize: destaque ? 28 : 15,
          fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: dica,
          hintStyle: const TextStyle(color: AppTema.textoSecundario),
          // O símbolo vai como `prefixIcon`, não como `prefixText`: o
          // Flutter só desenha o prefixText quando o campo tem foco ou
          // conteúdo, então o `R$` sumia justamente no estado vazio, que é
          // quando ele mais ajuda a entender o que se espera ali.
          prefixIcon: preco ? const _SimboloReal() : null,
          prefixIconConstraints: preco
              ? const BoxConstraints(minWidth: 0, minHeight: 0)
              : null,
          suffixText: sufixo,
          suffixStyle: const TextStyle(
            color: AppTema.textoSecundario,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: destaque ? 20 : 16,
          ),
        ),
      ),
    );
  }
}

/// O `R$` que precede um campo de valor.
///
/// Fica sempre visível, inclusive com o campo vazio e sem foco.
class _SimboloReal extends StatelessWidget {
  const _SimboloReal();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 16, right: 4),
    child: Align(
      widthFactor: 1,
      child: Text(
        r'R$',
        style: TextStyle(
          color: AppTema.textoSecundario,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
