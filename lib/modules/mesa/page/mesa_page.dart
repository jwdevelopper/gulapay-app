import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_order_page.dart';
import 'package:my_app_teste/modules/mesa/widget/floor_plan_canvas.dart';
import 'package:my_app_teste/modules/mesa/widget/restaurant_area_tab.dart';
import 'package:my_app_teste/modules/mesa/widget/table_editor_sheet.dart';
import 'package:my_app_teste/modules/mesa/widget/table_info_sheet.dart';
import 'package:my_app_teste/modules/mesa/widget/table_legend.dart';

class MesaPage extends StatefulWidget {
  const MesaPage({super.key});

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> {
  late final FloorPlanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloorPlanController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final area = _controller.selectedArea;

        if (_controller.isLoading || area == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isWide = MediaQuery.of(context).size.width >= 980;

        return Scaffold(
          backgroundColor: GulaColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context, area),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final item = _controller.areas[index];
                        return RestaurantAreaTab(
                          area: item,
                          isSelected: item.id == area.id,
                          onTap: () => _controller.selectArea(item.id),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: _controller.areas.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCanvas(area),
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(
                                width: 320,
                                child: TableLegend(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(child: _buildCanvas(area)),
                              const SizedBox(height: 14),
                              const TableLegend(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, RestaurantArea area) {
    final totalMesas = _controller.areas.fold<int>(
      0,
      (count, item) => count + item.totalTables,
    );
    final totalOcupadas = _controller.areas.fold<int>(
      0,
      (count, item) => count + item.occupancyCount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GulaColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 14,
        spacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mapa de mesas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${area.name} ativa - $totalOcupadas/$totalMesas mesas em uso',
                style: const TextStyle(
                  color: GulaColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showTableEditor(),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Nova mesa'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await _controller.resetSeed();
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mapa restaurado para a base inicial.'),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_outlined),
                label: Text(_controller.isSaving ? 'Salvando...' : 'Recarregar base'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(RestaurantArea area) {
    return FloorPlanCanvas(
      area: area,
      controller: _controller,
      onOpenTable: _showTableInfo,
      onOpenOrder: (table) => _openOrder(table.id),
    );
  }

  Future<void> _showTableEditor({RestaurantTable? table}) async {
    final areaId = table?.areaId ?? (_controller.selectedArea?.id ?? '');
    final draft = await showModalBottomSheet<TableDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TableEditorSheet(
          areas: _controller.areas,
          initialAreaId: areaId,
          table: table,
        );
      },
    );

    if (draft == null) {
      return;
    }

    await _controller.saveTable(draft);
    _showControllerErrorIfNeeded();
  }

  Future<void> _showTableInfo(RestaurantTable table) async {
    final refreshedTable = _controller.findTableById(table.id);
    if (refreshedTable == null) {
      return;
    }

    final area = _controller.areaById(refreshedTable.areaId);
    if (area == null) {
      return;
    }

    final scopeTables = _controller.tablesForScope(refreshedTable.id);
    final status = _controller.resolveStatus(refreshedTable);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return TableInfoSheet(
          areaName: area.name,
          table: refreshedTable,
          status: status,
          scopeTables: scopeTables,
          totalChairs: _controller.groupChairsCount(refreshedTable.id),
          seatedPeople: _controller.groupSeatedCount(refreshedTable.id),
          itemsCount: _controller.groupItemsCount(refreshedTable.id),
          partialTotal: _controller.groupPartialTotal(refreshedTable.id),
          lastOrderAt: _controller.lastOrderAtForScope(refreshedTable.id),
          customerName: _controller.groupCustomerName(refreshedTable.id),
          joinableTables: _controller.joinableTablesFor(refreshedTable.id),
          onOpenOrder: () {
            Navigator.pop(sheetContext);
            _openOrder(refreshedTable.id);
          },
          onEdit: () {
            Navigator.pop(sheetContext);
            _showTableEditor(table: refreshedTable);
          },
          onMarkFree: () {
            Navigator.pop(sheetContext);
            _confirmAndRelease(refreshedTable.id);
          },
          onJoinWith: (targetTableId) async {
            Navigator.pop(sheetContext);
            final error = await _controller.joinTables(
              sourceTableId: refreshedTable.id,
              targetTableId: targetTableId,
            );
            if (!mounted) {
              return;
            }
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mesas unidas com sucesso.'),
              ),
            );
          },
          onSeparateGroup: refreshedTable.joinGroupId == null
              ? null
              : () {
                  Navigator.pop(sheetContext);
                  _confirmAndSeparate(refreshedTable.joinGroupId!);
                },
        );
      },
    );
  }

  Future<void> _openOrder(String tableId) async {
    final result = await _controller.openOrderForTable(tableId);
    if (!mounted || result == null) {
      return;
    }

    if (!result.reusedExistingOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nova comanda aberta para a mesa.'),
        ),
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MesaOrderPage(
          controller: _controller,
          tableId: result.tableIds.first,
        ),
      ),
    );
  }

  Future<void> _confirmAndRelease(String tableId) async {
    final confirmed = await _confirmAction(
      title: 'Liberar mesa',
      body: 'Essa acao encerra o estado atual da mesa e limpa a comanda em aberto.',
    );
    if (confirmed != true) {
      return;
    }

    await _controller.markTableAsFree(tableId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mesa liberada com sucesso.')),
    );
  }

  Future<void> _confirmAndSeparate(String groupId) async {
    final confirmed = await _confirmAction(
      title: 'Separar grupo',
      body: 'As mesas voltarao a operar individualmente. A comanda do grupo sera preservada.',
    );
    if (confirmed != true) {
      return;
    }

    final error = await _controller.separateGroup(groupId);
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grupo separado com sucesso.')),
    );
  }

  Future<bool?> _confirmAction({
    required String title,
    required String body,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GulaColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GulaColors.border),
          ),
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showControllerErrorIfNeeded() {
    final error = _controller.lastActionError;
    if (error == null || error.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}
