import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class TableLegend extends StatelessWidget {
  const TableLegend({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 12.0 : 16.0;
    final spacing = compact ? 6.0 : 8.0;
    final runSpacing = compact ? 6.0 : 8.0;
    final titleSize = compact ? 13.0 : 14.0;
    final bodySize = compact ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: compact ? 16 : 18,
                color: GulaColors.textMuted,
              ),
              SizedBox(width: compact ? 6 : 8),
              Text(
                'Legenda operacional',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: [
              TableStatusBadge(status: TableStatus.free, compact: compact),
              TableStatusBadge(status: TableStatus.occupied, compact: compact),
              TableStatusBadge(
                status: TableStatus.noOrder30Min,
                compact: compact,
              ),
              TableStatusBadge(
                status: TableStatus.awaitingRelease1H,
                compact: compact,
              ),
              TableStatusBadge(status: TableStatus.withOrder, compact: compact),
              TableStatusBadge(status: TableStatus.attention, compact: compact),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            'No modo editar, arraste mesas e aproxime itens da mesma area para sugerir uniao. A comanda e sempre reaproveitada dentro do mesmo grupo.',
            style: TextStyle(
              color: GulaColors.textMuted,
              height: 1.35,
              fontSize: bodySize,
            ),
          ),
        ],
      ),
    );
  }
}
