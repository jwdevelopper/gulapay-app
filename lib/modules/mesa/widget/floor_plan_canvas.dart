import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_node.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class FloorPlanCanvas extends StatefulWidget {
  const FloorPlanCanvas({
    super.key,
    required this.area,
    required this.controller,
    required this.isEditMode,
    required this.onToggleEditMode,
    required this.onAddTable,
    required this.onJoinSuggested,
    required this.onEditTable,
    required this.onOpenTable,
    required this.onOpenOrder,
    this.borderRadius = 24,
  });

  final RestaurantArea area;
  final FloorPlanController controller;
  final bool isEditMode;
  final VoidCallback onToggleEditMode;
  final VoidCallback onAddTable;
  final VoidCallback onJoinSuggested;
  final ValueChanged<RestaurantTable> onEditTable;
  final ValueChanged<RestaurantTable> onOpenTable;
  final ValueChanged<RestaurantTable> onOpenOrder;
  final double borderRadius;

  @override
  State<FloorPlanCanvas> createState() => _FloorPlanCanvasState();
}

class _FloorPlanCanvasState extends State<FloorPlanCanvas> {
  late final TransformationController _transformationController;
  late final Listenable _rebuildListenable;
  double _scale = 1;
  String? _selectedGroupId;
  String? _selectedOperationalTableId;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_syncScaleFromMatrix);
    _rebuildListenable = Listenable.merge([
      widget.controller,
      widget.controller.moveListenable,
    ]);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_syncScaleFromMatrix);
    _transformationController.dispose();
    super.dispose();
  }

  void _syncScaleFromMatrix() {
    final nextScale = _transformationController.value.getMaxScaleOnAxis();
    if ((nextScale - _scale).abs() < 0.01) {
      if (_selectedOperationalTableId != null) {
        setState(() {});
      }
      return;
    }
    setState(() {
      _scale = nextScale;
    });
  }

  void _setScale(double value) {
    setState(() {
      _scale = value.clamp(0.62, 1.45).toDouble();
      _transformationController.value = Matrix4.diagonal3Values(
        _scale,
        _scale,
        1,
      );
    });
  }

  @override
  void didUpdateWidget(covariant FloorPlanCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEditMode && _selectedGroupId != null) {
      setState(() {
        _selectedGroupId = null;
      });
    } else if (oldWidget.area.id != widget.area.id &&
        _selectedGroupId != null) {
      setState(() {
        _selectedGroupId = null;
      });
    }

    if (widget.isEditMode || oldWidget.area.id != widget.area.id) {
      _selectedOperationalTableId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rebuildListenable,
      builder: (context, _) {
        final area = widget.controller.areaById(widget.area.id) ?? widget.area;
        final selectedGroupTables = _selectedGroupId == null
            ? const <RestaurantTable>[]
            : area.tables
                  .where((table) => table.joinGroupId == _selectedGroupId)
                  .toList();
        final showUnmixBar =
            widget.isEditMode && selectedGroupTables.length > 1;

        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = max(920.0, constraints.maxWidth);
            final canvasHeight = max(640.0, constraints.maxHeight);
            final canvasSize = Size(canvasWidth, canvasHeight);
            final overlayCompact = constraints.maxWidth < 520;
            final selectedOperationalTable = _selectedOperationalTableId == null
                ? null
                : area.tables.cast<RestaurantTable?>().firstWhere(
                    (table) => table!.id == _selectedOperationalTableId,
                    orElse: () => null,
                  );

            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: GulaColors.canvas,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.borderRadius == 0
                      ? null
                      : Border.all(color: GulaColors.border),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        alignment: Alignment.topLeft,
                        boundaryMargin: const EdgeInsets.all(180),
                        constrained: false,
                        panEnabled: widget.controller.movingTableId == null,
                        scaleEnabled: widget.controller.movingTableId == null,
                        minScale: 0.62,
                        maxScale: 1.45,
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: canvasSize,
                                painter: _RestaurantFloorPainter(
                                  areaType: area.type,
                                ),
                              ),
                              ..._buildTableNodes(area, canvasSize),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _CanvasControls(
                        onZoomOut: () => _setScale(_scale - 0.12),
                        onZoomIn: () => _setScale(_scale + 0.12),
                        onResetZoom: () => _setScale(1),
                        compact: overlayCompact,
                      ),
                    ),
                    if (widget.controller.suggestedJoinTargetId != null)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _JoinSuggestionBanner(
                          onJoin: widget.onJoinSuggested,
                        ),
                      ),
                    Positioned(
                      right: 12,
                      bottom: 76,
                      child: IgnorePointer(
                        ignoring: !showUnmixBar,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          opacity: showUnmixBar ? 1 : 0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            offset: showUnmixBar
                                ? Offset.zero
                                : const Offset(0, 0.3),
                            child: _UnmixFloatingBar(
                              tableCount: selectedGroupTables.length,
                              onUnmix: () =>
                                  _handleSeparateGroup(_selectedGroupId!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _LayoutModeButton(
                        isActive: widget.isEditMode,
                        onPressed: widget.onToggleEditMode,
                        onAddTable: widget.onAddTable,
                        compact: overlayCompact,
                      ),
                    ),
                    if (!widget.isEditMode && selectedOperationalTable != null)
                      _buildQuickPopover(
                        selectedOperationalTable,
                        constraints.biggest,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildTableNodes(RestaurantArea area, Size canvasSize) {
    final groupMap = <String, List<RestaurantTable>>{};
    final soloTables = <RestaurantTable>[];

    for (final table in area.tables) {
      if (table.isJoined && table.joinGroupId != null) {
        groupMap
            .putIfAbsent(table.joinGroupId!, () => <RestaurantTable>[])
            .add(table);
      } else {
        soloTables.add(table);
      }
    }

    for (final entry in groupMap.entries) {
      if (entry.value.length == 1) {
        soloTables.add(entry.value.first);
      }
    }

    final nodes = <Widget>[];

    for (final entry in groupMap.entries) {
      if (entry.value.length < 2) {
        continue;
      }
      final isSuggestedJoin = entry.value.any(
        (table) => widget.controller.suggestedJoinTargetId == table.id,
      );
      final isSelected = entry.key == _selectedGroupId;
      nodes.add(
        _buildMergedGroupNode(
          area: area,
          groupId: entry.key,
          tables: entry.value,
          canvasSize: canvasSize,
          isSuggestedJoin: isSuggestedJoin,
          isSelected: isSelected,
        ),
      );
    }

    nodes.addAll(
      soloTables.map((table) {
        return Positioned(
          left: table.x,
          top: table.y,
          child: TableNode(
            table: table,
            areaName: area.name,
            status: widget.controller.resolveStatus(table),
            isMoving: widget.controller.movingTableId == table.id,
            isSuggestedJoin:
                widget.controller.suggestedJoinTargetId == table.id ||
                widget.controller.movingTableId == table.id,
            canDrag: widget.isEditMode,
            lastEventAt: widget.controller.lastOrderAtForScope(table.id),
            onTap: () => widget.isEditMode
                ? _selectGroup(null, () => widget.onEditTable(table))
                : _selectOperationalTable(table),
            onDoubleTap: () {
              if (!widget.isEditMode) {
                widget.onOpenOrder(table);
              }
            },
            onPanStart: () => _selectGroup(null, () {
              widget.controller.beginMove(table.id);
            }),
            onPanUpdate: (delta) => widget.controller.moveTable(
              table.id,
              delta / _scale,
              canvasSize,
            ),
            onPanEnd: widget.controller.finishMove,
          ),
        );
      }),
    );

    return nodes;
  }

  Widget _buildMergedGroupNode({
    required RestaurantArea area,
    required String groupId,
    required List<RestaurantTable> tables,
    required Size canvasSize,
    required bool isSuggestedJoin,
    required bool isSelected,
  }) {
    final sorted = [...tables]..sort((a, b) => a.code.compareTo(b.code));
    final anchor = _anchorTable(sorted);
    final bounds = _groupBounds(sorted);
    final groupStatus = _resolveGroupStatus(sorted);
    final groupLabel = _groupLabel(sorted);
    final groupChairs = sorted.fold<int>(
      0,
      (sum, table) => sum + table.chairsCount,
    );
    final isMoving = sorted.any(
      (table) => widget.controller.movingTableId == table.id,
    );

    final mergedTable = RestaurantTable(
      id: groupId,
      code: groupLabel,
      areaId: area.id,
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      shape: TableShape.rectangular,
      chairsCount: groupChairs,
      status: groupStatus,
      isJoined: true,
      joinGroupId: groupId,
      activeOrderId: anchor.activeOrderId,
      lastOrderAt: anchor.lastOrderAt,
      seatedPeople: anchor.seatedPeople,
      customerName: anchor.customerName,
      orderItemsCount: anchor.orderItemsCount,
      partialTotal: anchor.partialTotal,
    );

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      child: TableNode(
        table: mergedTable,
        areaName: area.name,
        status: groupStatus,
        isMoving: isMoving,
        isSuggestedJoin: isSuggestedJoin || isSelected,
        canDrag: widget.isEditMode,
        lastEventAt: widget.controller.lastOrderAtForScope(anchor.id),
        onTap: () => widget.isEditMode
            ? _selectGroup(groupId, () => widget.onEditTable(anchor))
            : _selectOperationalTable(anchor),
        onDoubleTap: () {
          if (!widget.isEditMode) {
            widget.onOpenOrder(anchor);
          }
        },
        onPanStart: () => _selectGroup(groupId, () {
          widget.controller.beginMove(anchor.id);
        }),
        onPanUpdate: (delta) =>
            widget.controller.moveTable(anchor.id, delta / _scale, canvasSize),
        onPanEnd: widget.controller.finishMove,
      ),
    );
  }

  void _selectOperationalTable(RestaurantTable table) {
    setState(() {
      _selectedOperationalTableId = table.id;
    });
  }

  Widget _buildQuickPopover(RestaurantTable table, Size viewportSize) {
    const preferredWidth = 258.0;
    const preferredHeight = 172.0;
    const margin = 12.0;

    final scenePosition = MatrixUtils.transformPoint(
      _transformationController.value,
      Offset(table.x, table.y),
    );
    final availableWidth = max(0.0, viewportSize.width - (margin * 2));
    final popoverWidth = min(preferredWidth, availableWidth);
    final tableCenterX = scenePosition.dx + (table.width / 2);
    final prefersRight = tableCenterX < viewportSize.width / 2;
    final preferredLeft = prefersRight
        ? scenePosition.dx + table.width + margin
        : scenePosition.dx - popoverWidth - margin;
    final left = preferredLeft
        .clamp(margin, max(margin, viewportSize.width - popoverWidth - margin))
        .toDouble();
    final top = (scenePosition.dy + (table.height / 2) - (preferredHeight / 2))
        .clamp(
          margin,
          max(margin, viewportSize.height - preferredHeight - margin),
        )
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: popoverWidth,
      child: _TableQuickPopover(
        table: table,
        status: widget.controller.resolveStatus(table),
        itemsCount: widget.controller.groupItemsCount(table.id),
        partialTotal: widget.controller.groupPartialTotal(table.id),
        lastOrderAt: widget.controller.lastOrderAtForScope(table.id),
        hasActiveOrder:
            widget.controller.activeOrderIdForScope(table.id) != null,
        onOpenOrder: () => widget.onOpenOrder(table),
        onMoreDetails: () => widget.onOpenTable(table),
        onClose: () => setState(() => _selectedOperationalTableId = null),
      ),
    );
  }

  Rect _groupBounds(List<RestaurantTable> tables) {
    var minX = tables.first.x;
    var minY = tables.first.y;
    var maxX = tables.first.x + tables.first.width;
    var maxY = tables.first.y + tables.first.height;

    for (final table in tables.skip(1)) {
      minX = min(minX, table.x);
      minY = min(minY, table.y);
      maxX = max(maxX, table.x + table.width);
      maxY = max(maxY, table.y + table.height);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  RestaurantTable _anchorTable(List<RestaurantTable> tables) {
    for (final table in tables) {
      if (table.activeOrderId != null) {
        return table;
      }
    }
    for (final table in tables) {
      if ((table.seatedPeople ?? 0) > 0) {
        return table;
      }
    }
    return tables.first;
  }

  String _groupLabel(List<RestaurantTable> tables) {
    if (tables.length == 2) {
      return '${tables[0].code} + ${tables[1].code}';
    }
    final extra = tables.length - 1;
    return '${tables[0].code} + $extra mesas';
  }

  TableStatus _resolveGroupStatus(List<RestaurantTable> tables) {
    final statuses = tables
        .map((table) => widget.controller.resolveStatus(table))
        .toList();

    if (statuses.contains(TableStatus.withOrder)) {
      return TableStatus.withOrder;
    }
    if (statuses.contains(TableStatus.awaitingRelease1H)) {
      return TableStatus.awaitingRelease1H;
    }
    if (statuses.contains(TableStatus.noOrder30Min)) {
      return TableStatus.noOrder30Min;
    }
    if (statuses.contains(TableStatus.occupied)) {
      return TableStatus.occupied;
    }
    if (statuses.contains(TableStatus.attention)) {
      return TableStatus.attention;
    }
    return TableStatus.free;
  }

  Future<void> _handleSeparateGroup(String groupId) async {
    final error = await widget.controller.separateGroup(groupId);
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_selectedGroupId == groupId) {
      setState(() {
        _selectedGroupId = null;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mistura desfeita com sucesso.')),
    );
  }

  void _selectGroup(String? groupId, VoidCallback action) {
    if (widget.isEditMode && _selectedGroupId != groupId) {
      setState(() {
        _selectedGroupId = groupId;
      });
    } else if (!widget.isEditMode && _selectedGroupId != null) {
      setState(() {
        _selectedGroupId = null;
      });
    }
    action();
  }
}

class _UnmixFloatingBar extends StatelessWidget {
  const _UnmixFloatingBar({required this.tableCount, required this.onUnmix});

  final int tableCount;
  final VoidCallback onUnmix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.call_split_rounded,
            size: 18,
            color: GulaColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Desfazer ($tableCount)',
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: onUnmix,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Desfazer'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableQuickPopover extends StatelessWidget {
  const _TableQuickPopover({
    required this.table,
    required this.status,
    required this.itemsCount,
    required this.partialTotal,
    required this.lastOrderAt,
    required this.hasActiveOrder,
    required this.onOpenOrder,
    required this.onMoreDetails,
    required this.onClose,
  });

  final RestaurantTable table;
  final TableStatus status;
  final int itemsCount;
  final double partialTotal;
  final DateTime? lastOrderAt;
  final bool hasActiveOrder;
  final VoidCallback onOpenOrder;
  final VoidCallback onMoreDetails;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final orderLabel = hasActiveOrder
        ? 'Pedido ${table.activeOrderId?.replaceFirst('ORD-', '#') ?? ''}'
        : 'Mesa disponível';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: GulaColors.surfaceAlt.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tableStatusColor(status).withValues(alpha: 0.82),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    table.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GulaColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TableStatusBadge(status: status, compact: true),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: 'Fechar resumo',
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              orderLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GulaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _QuickData(
                  icon: Icons.schedule_outlined,
                  label: _formatElapsed(lastOrderAt),
                ),
                _QuickData(
                  icon: Icons.receipt_long_outlined,
                  label: '$itemsCount item${itemsCount == 1 ? '' : 's'}',
                ),
                Text(
                  'R\$ ${partialTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: GulaColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenOrder,
                    icon: Icon(
                      hasActiveOrder
                          ? Icons.receipt_long_outlined
                          : Icons.add_shopping_cart_outlined,
                      size: 16,
                    ),
                    label: Text(
                      hasActiveOrder ? 'Ver comanda' : 'Abrir pedido',
                    ),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Detalhes da mesa',
                  onPressed: onMoreDetails,
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(DateTime? value) {
    if (value == null) {
      return 'sem tempo';
    }
    final elapsed = DateTime.now().difference(value);
    if (elapsed.inMinutes < 1) {
      return 'agora';
    }
    if (elapsed.inMinutes < 60) {
      return '${elapsed.inMinutes} min';
    }
    return '${elapsed.inHours} h';
  }
}

class _QuickData extends StatelessWidget {
  const _QuickData({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: GulaColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: GulaColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LayoutModeButton extends StatelessWidget {
  const _LayoutModeButton({
    required this.isActive,
    required this.onPressed,
    required this.onAddTable,
    required this.compact,
  });

  final bool isActive;
  final VoidCallback onPressed;
  final VoidCallback onAddTable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? GulaColors.primary : GulaColors.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            IconButton(
              tooltip: 'Nova mesa',
              onPressed: onAddTable,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: GulaColors.primary,
                fixedSize: Size(compact ? 34 : 38, compact ? 34 : 38),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(
              isActive ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              size: compact ? 16 : 18,
            ),
            label: Text(isActive ? 'Layout ativo' : 'Modo layout'),
            style: FilledButton.styleFrom(
              backgroundColor: isActive
                  ? GulaColors.primary
                  : GulaColors.surface,
              foregroundColor: isActive ? Colors.white : GulaColors.text,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 9 : 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasControls extends StatelessWidget {
  const _CanvasControls({
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onResetZoom,
    this.compact = false,
  });

  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onResetZoom;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 3 : 4),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: compact ? 10 : 14,
            offset: Offset(0, compact ? 5 : 7),
          ),
        ],
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          _ControlButton(
            tooltip: 'Diminuir zoom',
            icon: Icons.remove_rounded,
            onPressed: onZoomOut,
            compact: compact,
          ),
          _ControlButton(
            tooltip: 'Restaurar zoom',
            icon: Icons.center_focus_strong_outlined,
            onPressed: onResetZoom,
            compact: compact,
          ),
          _ControlButton(
            tooltip: 'Aumentar zoom',
            icon: Icons.add_rounded,
            onPressed: onZoomIn,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GulaColors.text,
          fixedSize: Size(compact ? 32 : 38, compact ? 32 : 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 11 : 13),
          ),
        ),
        icon: Icon(icon, size: compact ? 17 : 19),
      ),
    );
  }
}

class _JoinSuggestionBanner extends StatelessWidget {
  const _JoinSuggestionBanner({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GulaColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 18, color: GulaColors.primary),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Mesa proxima detectada.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: onJoin,
              icon: const Icon(Icons.call_merge_rounded, size: 18),
              label: const Text('Unir'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantFloorPainter extends CustomPainter {
  const _RestaurantFloorPainter({required this.areaType});

  final String areaType;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = GulaColors.canvas;
    canvas.drawRect(Offset.zero & size, basePaint);

    _drawFloorTexture(canvas, size);
    _drawGrid(canvas, size);
    _drawWalls(canvas, size);
    _drawAreaFixtures(canvas, size);
  }

  void _drawFloorTexture(Canvas canvas, Size size) {
    final plankPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final linePaint = Paint()
      ..color = GulaColors.borderSoft.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    const plankHeight = 34.0;
    for (double y = 0; y < size.height; y += plankHeight) {
      final shift = ((y / plankHeight).round().isEven) ? 0.0 : 42.0;
      for (double x = -shift; x < size.width; x += 132) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 132, plankHeight),
            const Radius.circular(2),
          ),
          plankPaint,
        );
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final fineLine = Paint()
      ..color = GulaColors.borderSoft.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const gap = 24.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fineLine);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fineLine);
    }
  }

  void _drawWalls(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = GulaColors.text.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final wallRect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(24)),
      wallPaint,
    );

    final doorPaint = Paint()
      ..color = GulaColors.canvas
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.44, size.height - 12),
      Offset(size.width * 0.58, size.height - 12),
      doorPaint,
    );
    _drawLabel(canvas, 'Entrada', Offset(size.width * 0.46, size.height - 46));
  }

  void _drawAreaFixtures(Canvas canvas, Size size) {
    final counterColor = GulaColors.textMuted.withValues(alpha: 0.18);
    final greenColor = const Color(0xFF8DAA91).withValues(alpha: 0.22);
    final glassColor = const Color(0xFF87A7B2).withValues(alpha: 0.2);

    switch (areaType) {
      case 'externo':
        _drawFixture(
          canvas,
          Rect.fromLTWH(54, 42, size.width - 108, 38),
          'Cobertura',
          glassColor,
        );
        _drawFixture(
          canvas,
          Rect.fromLTWH(size.width - 136, 110, 64, 360),
          'Jardim',
          greenColor,
          verticalLabel: true,
        );
        break;
      case 'premium':
        _drawFixture(
          canvas,
          Rect.fromLTWH(62, 56, 180, 58),
          'Recepcao VIP',
          counterColor,
        );
        _drawFixture(
          canvas,
          Rect.fromLTWH(size.width - 178, 72, 76, 420),
          'Adega',
          const Color(0xFF7E6B8E).withValues(alpha: 0.2),
          verticalLabel: true,
        );
        break;
      default:
        _drawFixture(
          canvas,
          Rect.fromLTWH(size.width - 210, 64, 146, 78),
          'Caixa',
          counterColor,
        );
        _drawFixture(
          canvas,
          Rect.fromLTWH(size.width - 192, 184, 112, 270),
          'Copa',
          counterColor,
          verticalLabel: true,
        );
    }
  }

  void _drawFixture(
    Canvas canvas,
    Rect rect,
    String label,
    Color color, {
    bool verticalLabel = false,
  }) {
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = GulaColors.border.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
    _drawLabel(
      canvas,
      label,
      verticalLabel
          ? Offset(rect.center.dx - 20, rect.center.dy)
          : Offset(rect.left + 14, rect.top + 18),
      rotate: verticalLabel,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String label,
    Offset offset, {
    bool rotate = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: GulaColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (rotate) {
      canvas.rotate(-pi / 2);
    }
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RestaurantFloorPainter oldDelegate) {
    return oldDelegate.areaType != areaType;
  }
}
