import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class MesaOrderPage extends StatelessWidget {
  const MesaOrderPage({
    super.key,
    required this.controller,
    required this.tableId,
  });

  final FloorPlanController controller;
  final String tableId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final table = controller.findTableById(tableId);
        if (table == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pedido da mesa')),
            body: const Center(child: Text('Mesa nao encontrada.')),
          );
        }

        final scopeTables = controller.tablesForScope(tableId);
        final status = controller.resolveStatus(table);
        final area = controller.areaById(table.areaId);

        return Scaffold(
          appBar: AppBar(
            title: Text('Pedido - ${table.code}'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GulaColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: GulaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              table.code,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          TableStatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        area?.name ?? 'Area nao identificada',
                        style: const TextStyle(
                          color: GulaColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _OrderStat(
                            label: 'Comanda',
                            value: controller.activeOrderIdForScope(tableId) ?? '--',
                          ),
                          _OrderStat(
                            label: 'Mesas',
                            value: scopeTables.map((item) => item.code).join(', '),
                          ),
                          _OrderStat(
                            label: 'Itens',
                            value: controller.groupItemsCount(tableId).toString(),
                          ),
                          _OrderStat(
                            label: 'Parcial',
                            value: 'R\$ ${controller.groupPartialTotal(tableId).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Fluxo provisiorio de comanda para manter a interacao de mesas sem duplicar pedido.',
                  style: TextStyle(color: GulaColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controller.addSimulatedItem(tableId);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item simulado adicionado a comanda.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('Adicionar item simulado'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await controller.markTableAsFree(tableId);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Liberar mesa'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderStat extends StatelessWidget {
  const _OrderStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt,
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
  }
}
