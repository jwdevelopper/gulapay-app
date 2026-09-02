import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


/// Resumo quantitativo exibido abaixo do AppBar global da Home.
class EntregadorActiveCount extends StatelessWidget {
  final String label;

  const EntregadorActiveCount({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: PaletaApp.text,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
