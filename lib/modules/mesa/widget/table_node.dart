import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class TableNode extends StatelessWidget {
  const TableNode({
    super.key,
    required this.table,
    required this.status,
    required this.isMoving,
    required this.isSuggestedJoin,
    required this.onTap,
    required this.onDoubleTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final RestaurantTable table;
  final TableStatus status;
  final bool isMoving;
  final bool isSuggestedJoin;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();
    final chairOffsets = _chairOffsets(
      Size(table.width, table.height),
      table.shape,
      table.chairsCount,
    );

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onPanStart: (_) => onPanStart(),
      onPanUpdate: (details) => onPanUpdate(details.delta),
      onPanEnd: (_) => onPanEnd(),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: isMoving ? 1.02 : 1,
        child: SizedBox(
          width: table.width,
          height: table.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ...chairOffsets.map(
                (offset) => Positioned(
                  left: offset.dx - 5,
                  top: offset.dy - 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: GulaColors.surfaceAlt,
                      shape: BoxShape.circle,
                      border: Border.all(color: GulaColors.border),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: decoration,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
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
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (table.isJoined)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: GulaColors.surfaceAlt.withOpacity(0.86),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Grupo',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: GulaColors.text,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      TableStatusBadge(status: status, compact: true),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.chair_alt_outlined,
                            size: 13,
                            color: GulaColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${table.chairsCount} cadeiras',
                            style: const TextStyle(
                              color: GulaColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isSuggestedJoin)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: _borderRadiusForShape(table.shape),
                        border: Border.all(
                          color: GulaColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final color = tableStatusColor(status);
    final borderRadius = _borderRadiusForShape(table.shape);

    if (table.shape == TableShape.round) {
      return BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSuggestedJoin ? GulaColors.primary : GulaColors.border,
          width: isSuggestedJoin ? 2.2 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: Border.all(
        color: isSuggestedJoin ? GulaColors.primary : GulaColors.border,
        width: isSuggestedJoin ? 2.2 : 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  BorderRadius _borderRadiusForShape(TableShape shape) {
    switch (shape) {
      case TableShape.round:
        return BorderRadius.circular(999);
      case TableShape.square:
        return BorderRadius.circular(24);
      case TableShape.rectangular:
        return BorderRadius.circular(22);
      case TableShape.oval:
        return BorderRadius.circular(999);
    }
  }

  List<Offset> _chairOffsets(Size size, TableShape shape, int chairsCount) {
    final seats = chairsCount.clamp(1, 12) as int;
    if (shape == TableShape.round || shape == TableShape.oval) {
      return List<Offset>.generate(seats, (index) {
        final angle = (2 * pi * index) / seats;
        final radiusX = (size.width / 2) + 8;
        final radiusY = (size.height / 2) + 8;
        return Offset(
          (size.width / 2) + (radiusX * cos(angle)),
          (size.height / 2) + (radiusY * sin(angle)),
        );
      });
    }

    final topCount = (seats / 4).ceil();
    final bottomCount = topCount;
    final sideCount = ((seats - topCount - bottomCount) / 2).ceil();
    final positions = <Offset>[];

    for (var i = 0; i < topCount; i++) {
      final dx = ((i + 1) * size.width) / (topCount + 1);
      positions.add(Offset(dx, -6));
    }
    for (var i = 0; i < bottomCount; i++) {
      final dx = ((i + 1) * size.width) / (bottomCount + 1);
      positions.add(Offset(dx, size.height + 6));
    }
    for (var i = 0; i < sideCount; i++) {
      final dy = ((i + 1) * size.height) / (sideCount + 1);
      positions.add(Offset(-6, dy));
    }
    while (positions.length < seats) {
      final index = positions.length - (topCount + bottomCount + sideCount) + 1;
      final dy = (index * size.height) / (max(1, seats - positions.length) + 1);
      positions.add(Offset(size.width + 6, dy));
    }
    return positions.take(seats).toList();
  }
}
