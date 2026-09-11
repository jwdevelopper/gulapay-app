import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/mesa/widgets/editor_mapa_widgets.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/dto/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_order_page.dart';
import 'package:my_app_teste/modules/mesa/widgets/floor_plan_canvas.dart';
import 'package:my_app_teste/modules/mesa/widgets/restaurant_area_tab.dart';
import 'package:my_app_teste/modules/mesa/widgets/table_editor_sheet.dart';
import 'package:my_app_teste/modules/mesa/widgets/table_info_sheet.dart';
import 'package:my_app_teste/modules/mesa/widgets/table_legend.dart';

class MesaPage extends StatefulWidget {
  const MesaPage({super.key});

  @override
  State<MesaPage> createState() => _MesaPageState();
}

class _MesaPageState extends State<MesaPage> {
  late final FloorPlanController _controller;
  bool _isEditMode = false;
  static const double _extraNarrowWidth = 360;
  static const double _narrowWidth = 420;
  static const double _wideWidth = 1024;

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

        final screenWidth = MediaQuery.of(context).size.width;
        final isExtraNarrow = screenWidth <= _extraNarrowWidth;
        final isNarrow = screenWidth <= _narrowWidth;
        final isWide = screenWidth >= _wideWidth;
        final canvasHeight = isExtraNarrow ? 360.0 : (isNarrow ? 400.0 : 420.0);

        return Scaffold(
          backgroundColor: AppTema.fundo,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context, area),
                  const SizedBox(height: 16),
                  _buildAreaSelector(area, compact: isNarrow),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildCanvas(area)),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: isWide ? 360 : 320,
                                child: TableLegend(compact: isNarrow),
                              ),
                            ],
                          )
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              SizedBox(
                                height: canvasHeight,
                                child: _buildCanvas(area),
                              ),
                              const SizedBox(height: 14),
                              TableLegend(compact: isNarrow),
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
    final totalLivres = totalMesas - totalOcupadas;
    final totalAlertas = _controller.areas.fold<int>(
      0,
      (count, item) =>
          count +
          item.tables
              .where(
                (table) =>
                    _controller.resolveStatus(table) ==
                        TableStatus.noOrder30Min ||
                    _controller.resolveStatus(table) ==
                        TableStatus.awaitingRelease1H,
              )
              .length,
    );

    final metrics = [
      _HeaderMetric(
        icon: Icons.table_restaurant_outlined,
        label: 'Mesas',
        value: '$totalMesas',
      ),
      _HeaderMetric(
        icon: Icons.event_available_outlined,
        label: 'Livres',
        value: '$totalLivres',
      ),
      _HeaderMetric(
        icon: Icons.warning_amber_rounded,
        label: 'Alertas',
        value: '$totalAlertas',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isExtraNarrow = constraints.maxWidth <= _extraNarrowWidth;
        final isNarrow = constraints.maxWidth <= _narrowWidth;
        final isWide = constraints.maxWidth >= _wideWidth;
        final verticalGap = isNarrow ? 8.0 : 12.0;
        final denseButtons = isExtraNarrow;
        final ButtonStyle? segmentedStyle = denseButtons
            ? ButtonStyle(
                visualDensity: VisualDensity.compact,
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null;
        final ButtonStyle? outlinedStyle = denseButtons
            ? OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null;

        final actions = [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            selected: {_isEditMode},
            style: segmentedStyle,
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.receipt_long_outlined),
                label: Text('Operar'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.edit_location_alt_outlined),
                label: Text('Editar'),
              ),
            ],
            onSelectionChanged: (selection) {
              setState(() {
                _isEditMode = selection.first;
              });
            },
          ),
          OutlinedButton.icon(
            onPressed: () => _showTableEditor(),
            style: outlinedStyle,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Nova mesa'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              await _controller.resetSeed();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mapa restaurado para a base inicial.'),
                ),
              );
            },
            style: outlinedStyle,
            icon: const Icon(Icons.refresh_outlined),
            label: Text(
              _controller.isSaving ? 'Salvando...' : 'Recarregar base',
            ),
          ),
        ];

        final metricsWidget = isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    metrics[0],
                    const SizedBox(width: 8),
                    metrics[1],
                    const SizedBox(width: 8),
                    metrics[2],
                  ],
                ),
              )
            : Wrap(spacing: 8, runSpacing: 8, children: metrics);

        final actionsWidget = isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    actions[0],
                    const SizedBox(width: 8),
                    actions[1],
                    const SizedBox(width: 8),
                    actions[2],
                  ],
                ),
              )
            : Wrap(spacing: 10, runSpacing: 10, children: actions);

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mesas do restaurante',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${area.name} ativa - $totalOcupadas/$totalMesas mesas em uso',
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: AppTema.superficie,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTema.borda),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    SizedBox(height: verticalGap),
                    metricsWidget,
                    SizedBox(height: verticalGap),
                    actionsWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleBlock,
                          SizedBox(height: verticalGap),
                          metricsWidget,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isWide ? 420 : 320),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: actionsWidget,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAreaSelector(
    RestaurantArea selectedArea, {
    bool compact = false,
  }) {
    return SizedBox(
      height: compact ? 64 : 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = _controller.areas[index];
          return RestaurantAreaTab(
            area: item,
            isSelected: item.id == selectedArea.id,
            compact: compact,
            onTap: () => _controller.selectArea(item.id),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _controller.areas.length,
      ),
    );
  }

  Widget _buildCanvas(RestaurantArea area) {
    return FloorPlanCanvas(
      area: area,
      controller: _controller,
      isEditMode: _isEditMode,
      onToggleEditMode: () {
        setState(() {
          _isEditMode = !_isEditMode;
        });
      },
      onExpand: _openExpandedEditor,
      onJoinSuggested: _joinSuggestedTables,
      onEditTable: (table) => _showTableEditor(table: table),
      onOpenTable: _showTableInfo,
      onOpenOrder: (table) => _openOrder(table.id),
    );
  }

  Future<void> _openExpandedEditor() async {
    setState(() {
      _isEditMode = true;
    });

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return MesaMapEditorPage(
            controller: _controller,
            onNewTable: () => _showTableEditor(),
            onEditTable: (table) => _showTableEditor(table: table),
            onJoinSuggested: _joinSuggestedTables,
          );
        },
      ),
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
          'Essa acao encerra o estado atual da mesa e limpa a comanda em aberto.',
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
          'As mesas voltarao a operar individualmente. A comanda do grupo sera preservada.',
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
    return AppDialogoConfirmacao.mostrar(
      context,
      titulo: title,
      mensagem: body,
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

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTema.superficieAlt.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTema.borda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTema.textoSecundario),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTema.texto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
