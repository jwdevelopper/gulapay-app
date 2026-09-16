import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';

class RateioStatusBox extends StatelessWidget {
  const RateioStatusBox({
    super.key,
    required this.ok,
    required this.titulo,
    required this.detalhe,
    this.rodape,
  });

  final bool ok;
  final String titulo;
  final String detalhe;

  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    final cor = ok ? EstoquePalette.success : EstoquePalette.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
                  color: cor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: EstoquePalette.text)),
                    const SizedBox(height: 2),
                    Text(detalhe,
                        style: TextStyle(
                            color: cor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          if (rodape != null) ...[
            const Divider(height: 18, color: EstoquePalette.borderSoft),
            rodape!,
          ],
        ],
      ),
    );
  }
}
