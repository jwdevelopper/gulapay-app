import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class TableLegend extends StatelessWidget {
  const TableLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: GulaColors.textMuted),
              SizedBox(width: 8),
              Text(
                'Legenda operacional',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
              TableStatusBadge(status: TableStatus.attention),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'No modo editar, arraste mesas e aproxime itens da mesma area para sugerir uniao. A comanda e sempre reaproveitada dentro do mesmo grupo.',
            style: TextStyle(color: GulaColors.textMuted, height: 1.35),
          ),
        ],
      ),
    );
  }
}
