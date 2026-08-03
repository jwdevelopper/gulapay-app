import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Lista de pedidos (API / UI) — placeholder até módulo existir.
class PedidosPagina extends StatelessWidget {
  const PedidosPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTema.fundo,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pedidos\nEm breve você acompanhará pedidos aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
