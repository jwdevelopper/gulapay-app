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
  bool _isEditMode = false;

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

        final compact = MediaQuery.sizeOf(context).width < 520;

        return Scaffold(
          backgroundColor: GulaColors.background,
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 12 : 16,
                10,
                compact ? 12 : 16,
                12,
              ),
              child: Column(
                children: [
                  _buildAreaSelector(area, compact: compact),
                  const SizedBox(height: 10),
                  Expanded(child: _buildOperationalMap(area)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAreaSelector(
    RestaurantArea selectedArea, {
    required bool compact,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: compact ? 64 : 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _controller.areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _controller.areas[index];
                return RestaurantAreaTab(
                  area: item,
                  isSelected: item.id == selectedArea.id,
                  compact: true,
                  onTap: () => _controller.selectArea(item.id),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        _MapMenuButton(onShowLegend: _showMapLegend, onReset: _resetMap),
      ],
    );
  }

  Widget _buildOperationalMap(RestaurantArea area) {
    final occupied = area.occupancyCount;
    final alerts = area.tables.where((table) {
      final status = _controller.resolveStatus(table);
      return status == TableStatus.noOrder30Min ||
          status == TableStatus.awaitingRelease1H ||
          status == TableStatus.attention;
    }).length;

    return Stack(
      children: [
        Positioned.fill(
          child: FloorPlanCanvas(
            area: area,
            controller: _controller,
            isEditMode: _isEditMode,
            onToggleEditMode: () {
              setState(() => _isEditMode = !_isEditMode);
            },
            onAddTable: () => _showTableEditor(),
            onJoinSuggested: _joinSuggestedTables,
            onEditTable: (table) => _showTableEditor(table: table),
            onOpenTable: _showTableInfo,
            onOpenOrder: (table) => _openOrder(table.id),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: IgnorePointer(
            child: _MapSummary(
              areaName: area.name,
              total: area.totalTables,
              occupied: occupied,
              alerts: alerts,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMapLegend() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TableLegend(compact: true),
        ),
      ),
    );
  }

  Future<void> _resetMap() async {
    await _controller.resetSeed();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mapa restaurado para a base inicial.')),
    );
  }

  Future<void> _joinSuggestedTables() async {
    final error = await _controller.joinSuggestedTables();
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mesas unidas com sucesso.')));
  }

  Future<void> _showTableEditor({RestaurantTable? table}) async {
    final areaId = table?.areaId ?? (_controller.selectedArea?.id ?? '');
    final draft = await showModalBottomSheet<TableDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TableEditorSheet(
        areas: _controller.areas,
        initialAreaId: areaId,
        table: table,
      ),
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
      builder: (sheetContext) => TableInfoSheet(
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mesas unidas com sucesso.')),
          );
        },
        onSeparateGroup: refreshedTable.joinGroupId == null
            ? null
            : () {
                Navigator.pop(sheetContext);
                _confirmAndSeparate(refreshedTable.joinGroupId!);
              },
      ),
    );
  }

  Future<void> _openOrder(String tableId) async {
    final result = await _controller.openOrderForTable(tableId);
    if (!mounted || result == null) {
      return;
    }

    if (!result.reusedExistingOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nova comanda aberta para a mesa.')),
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
      body:
          'Essa ação encerra o estado atual da mesa e limpa a comanda em aberto.',
    );
    if (confirmed != true) {
      return;
    }

    await _controller.markTableAsFree(tableId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mesa liberada com sucesso.')));
  }

  Future<void> _confirmAndSeparate(String groupId) async {
    final confirmed = await _confirmAction(
      title: 'Separar grupo',
      body:
          'As mesas voltarão a operar individualmente. A comanda do grupo será preservada.',
    );
    if (confirmed != true) {
      return;
    }

    final error = await _controller.separateGroup(groupId);
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grupo separado com sucesso.')),
    );
  }

  Future<bool?> _confirmAction({required String title, required String body}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _showControllerErrorIfNeeded() {
    final error = _controller.lastActionError;
    if (error == null || error.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

class _MapSummary extends StatelessWidget {
  const _MapSummary({
    required this.areaName,
    required this.total,
    required this.occupied,
    required this.alerts,
  });

  final String areaName;
  final int total;
  final int occupied;
  final int alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            areaName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _MapSummaryValue(
                icon: Icons.table_restaurant_outlined,
                value: '$total mesas',
              ),
              _MapSummaryValue(
                icon: Icons.people_outline_rounded,
                value: '$occupied em uso',
              ),
              if (alerts > 0)
                _MapSummaryValue(
                  icon: Icons.priority_high_rounded,
                  value: '$alerts alerta${alerts == 1 ? '' : 's'}',
                  color: GulaColors.critical,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapSummaryValue extends StatelessWidget {
  const _MapSummaryValue({required this.icon, required this.value, this.color});

  final IconData icon;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? GulaColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: foreground),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MapMenuButton extends StatelessWidget {
  const _MapMenuButton({required this.onShowLegend, required this.onReset});

  final VoidCallback onShowLegend;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MapMenuAction>(
      tooltip: 'Opções do mapa',
      onSelected: (action) {
        switch (action) {
          case _MapMenuAction.legend:
            onShowLegend();
          case _MapMenuAction.reset:
            onReset();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _MapMenuAction.legend,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Legenda operacional'),
          ),
        ),
        PopupMenuItem(
          value: _MapMenuAction.reset,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.restart_alt_rounded),
            title: Text('Restaurar mapa inicial'),
          ),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: GulaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GulaColors.border),
        ),
        child: const Icon(Icons.more_horiz_rounded, color: GulaColors.text),
      ),
    );
  }
}

enum _MapMenuAction { legend, reset }
