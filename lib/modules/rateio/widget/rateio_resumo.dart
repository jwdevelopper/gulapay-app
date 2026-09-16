import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';

class RateioResumo extends StatelessWidget {
  const RateioResumo({
    super.key,
    required this.controller,
    required this.aoRecalcular,
  });

  final RateioController controller;
  final VoidCallback aoRecalcular;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...controller.participantesDoRateio.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: EstoquePalette.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: EstoquePalette.borderSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.nomeDe(p),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: EstoquePalette.text)),
                          const SizedBox(height: 2),
                          Text(
                            '${p.codigo} · próprios ${moeda(p.valorProprio)} · '
                            'rateio ${moeda(p.valorRateio)}',
                            style: const TextStyle(
                                color: EstoquePalette.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(moeda(p.valorTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: EstoquePalette.primary)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: controller.executando ? null : aoRecalcular,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Recalcular (aplicar outra estratégia)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: EstoquePalette.text,
            side: const BorderSide(color: EstoquePalette.border),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
