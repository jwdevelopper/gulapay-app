import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppDica extends StatelessWidget {
  final String texto;
  final String emoji;

  const AppDica(this.texto, {super.key, this.emoji = '💡'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTema.fundoDica,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style:
                  const TextStyle(color: AppTema.textoSecundario, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
