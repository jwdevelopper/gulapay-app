import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppTag extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;

  const AppTag(
    this.texto, {
    super.key,
    this.fundo = AppTema.fundoDica,
    this.cor = AppTema.textoSecundario,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
