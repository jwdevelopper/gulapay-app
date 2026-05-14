import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppRotulo extends StatelessWidget {
  final String texto;
  final bool opcional;
  final String? contador;

  const AppRotulo(this.texto, {super.key, this.opcional = false, this.contador});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTema.textoEscuro,
          ),
        ),
        if (opcional) ...[
          const SizedBox(width: 6),
          const Text('opcional',
              style: TextStyle(color: AppTema.primaria, fontSize: 12)),
        ],
        const Spacer(),
        if (contador != null)
          Text(
            contador!,
            style: const TextStyle(color: AppTema.textoSecundario, fontSize: 12),
          ),
      ],
    );
  }
}
