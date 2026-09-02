import 'package:flutter/material.dart';

import 'entregadores_palette.dart';

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
            color: EntregadoresPalette.text,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
