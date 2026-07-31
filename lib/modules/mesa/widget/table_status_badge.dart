import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

Color tableStatusColor(TableStatus status) {
  switch (status) {
    case TableStatus.free:
      return GulaColors.free;
    case TableStatus.occupied:
      return GulaColors.occupied;
    case TableStatus.noOrder30Min:
      return GulaColors.warning;
    case TableStatus.awaitingRelease1H:
      return GulaColors.critical;
    case TableStatus.withOrder:
      return GulaColors.success;
    case TableStatus.attention:
      return GulaColors.attention;
  }
}

String tableStatusLabel(TableStatus status) {
  switch (status) {
    case TableStatus.free:
      return 'Livre';
    case TableStatus.occupied:
      return 'Ocupada';
    case TableStatus.noOrder30Min:
      return 'Sem pedido 30m';
    case TableStatus.awaitingRelease1H:
      return 'Liberar 1h';
    case TableStatus.withOrder:
      return 'Com pedido';
    case TableStatus.attention:
      return 'Em atencao';
  }
}

IconData tableStatusIcon(TableStatus status) {
  switch (status) {
    case TableStatus.free:
      return Icons.deck_outlined;
    case TableStatus.occupied:
      return Icons.people_outline;
    case TableStatus.noOrder30Min:
      return Icons.schedule_outlined;
    case TableStatus.awaitingRelease1H:
      return Icons.notification_important_outlined;
    case TableStatus.withOrder:
      return Icons.receipt_long_outlined;
    case TableStatus.attention:
      return Icons.warning_amber_rounded;
  }
}

class TableStatusBadge extends StatelessWidget {
  const TableStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final TableStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = tableStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GulaColors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tableStatusIcon(status),
            size: compact ? 12 : 14,
            color: GulaColors.text,
          ),
          const SizedBox(width: 6),
          Text(
            tableStatusLabel(status),
            style: TextStyle(
              color: GulaColors.text,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
