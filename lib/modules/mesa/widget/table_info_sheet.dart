import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class TableInfoSheet extends StatelessWidget {
  const TableInfoSheet({
    super.key,
    required this.areaName,
    required this.table,
    required this.status,
    required this.scopeTables,
    required this.totalChairs,
    required this.seatedPeople,
    required this.itemsCount,
    required this.partialTotal,
    required this.lastOrderAt,
    required this.customerName,
    required this.joinableTables,
    required this.onOpenOrder,
    required this.onEdit,
    required this.onMarkFree,
    required this.onJoinWith,
    this.onSeparateGroup,
  });

  final String areaName;
  final RestaurantTable table;
  final TableStatus status;
  final List<RestaurantTable> scopeTables;
  final int totalChairs;
  final int seatedPeople;
  final int itemsCount;
  final double partialTotal;
  final DateTime? lastOrderAt;
  final String? customerName;
  final List<RestaurantTable> joinableTables;
  final VoidCallback onOpenOrder;
  final VoidCallback onEdit;
  final VoidCallback onMarkFree;
  final ValueChanged<String> onJoinWith;
  final VoidCallback? onSeparateGroup;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final hasActiveOrder = scopeTables.any((item) => item.activeOrderId != null);

    return Container(
      decoration: const BoxDecoration(
        color: GulaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 22 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: GulaColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.code,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        areaName,
                        style: const TextStyle(
                          color: GulaColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TableStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoCard(label: 'Capacidade', value: '$totalChairs lugares'),
                _InfoCard(label: 'Pessoas', value: '$seatedPeople sentadas'),
                _InfoCard(label: 'Itens', value: '$itemsCount em aberto'),
                _InfoCard(
                  label: 'Parcial',
                  value: 'R\$ ${partialTotal.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              label: 'Ultimo movimento',
              value: _formatLastEvent(lastOrderAt),
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              label: 'Cliente',
              value: customerName ?? 'Nao informado',
              fullWidth: true,
            ),
            if (scopeTables.length > 1) ...[
              const SizedBox(height: 12),
              _InfoCard(
                label: 'Mesas no grupo',
                value: scopeTables.map((item) => item.code).join(', '),
                fullWidth: true,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenOrder,
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(hasActiveOrder ? 'Ver comanda' : 'Abrir pedido'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMarkFree,
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Liberar'),
                  ),
                ),
              ],
            ),
            if (joinableTables.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Unir com outra mesa da area',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: joinableTables
                    .map(
                      (candidate) => ActionChip(
                        label: Text(candidate.code),
                        onPressed: () => onJoinWith(candidate.id),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (onSeparateGroup != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSeparateGroup,
                  icon: const Icon(Icons.call_split_outlined),
                  label: const Text('Desfazer mistura'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastEvent(DateTime? value) {
    if (value == null) {
      return 'Sem historico recente';
    }

    final elapsed = DateTime.now().difference(value);
    if (elapsed.inMinutes < 1) {
      return 'Agora mesmo';
    }
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} min atras';
    }
    return '${elapsed.inHours} h atras';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GulaColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }

    return SizedBox(width: 150, child: child);
  }
}
