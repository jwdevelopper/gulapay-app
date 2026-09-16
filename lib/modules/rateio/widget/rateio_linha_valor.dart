import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';

class RateioLinhaValor extends StatelessWidget {
  const RateioLinhaValor({
    super.key,
    required this.nome,
    required this.valor,
    this.detalhe,
    this.destaque = false,
  });

  final String nome;
  final String valor;
  final String? detalhe;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(nome,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: EstoquePalette.text, fontSize: 13)),
          ),
          if (detalhe != null) ...[
            Text(detalhe!,
                style: const TextStyle(
                    color: EstoquePalette.textMuted, fontSize: 12)),
            const SizedBox(width: 8),
          ],
          Text(valor,
              style: TextStyle(
                  color: destaque
                      ? EstoquePalette.primary
                      : EstoquePalette.text,
                  fontSize: destaque ? 15 : 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
