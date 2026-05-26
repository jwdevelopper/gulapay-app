import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class TableLegend extends StatelessWidget {
  const TableLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legenda operacional',
            style: TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              TableStatusBadge(status: TableStatus.free),
              TableStatusBadge(status: TableStatus.occupied),
              TableStatusBadge(status: TableStatus.noOrder30Min),
              TableStatusBadge(status: TableStatus.awaitingRelease1H),
              TableStatusBadge(status: TableStatus.withOrder),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Aproxime mesas da mesma area para sugerir uniao. Toque simples abre o painel e toque duplo entra no pedido sem duplicar comanda.',
            style: TextStyle(
              color: GulaColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
