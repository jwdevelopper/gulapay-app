import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppEstadoVazio extends StatelessWidget {
  final IconData icone;
  final String mensagem;

  const AppEstadoVazio({
    super.key,
    required this.icone,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 36, color: AppTema.primariaEscura),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTema.textoSecundario),
          ),
        ],
      ),
    );
  }
}
