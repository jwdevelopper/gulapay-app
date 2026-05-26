import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_node.dart';

class FloorPlanCanvas extends StatelessWidget {
  const FloorPlanCanvas({
    super.key,
    required this.area,
    required this.controller,
    required this.onOpenTable,
    required this.onOpenOrder,
  });

  final RestaurantArea area;
  final FloorPlanController controller;
  final ValueChanged<RestaurantTable> onOpenTable;
  final ValueChanged<RestaurantTable> onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = max(760.0, constraints.maxWidth);
        final canvasHeight = max(540.0, constraints.maxHeight);
        final canvasSize = Size(canvasWidth, canvasHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              color: GulaColors.canvas,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: GulaColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: canvasSize,
                        painter: _GridPainter(),
                      ),
                      Positioned(
                        left: 18,
                        top: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: GulaColors.surfaceAlt.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: GulaColors.border),
                          ),
                          child: Text(
                            '${area.name} - ${area.totalTables} mesas',
                            style: const TextStyle(
                              color: GulaColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      ...area.tables.map(
                        (table) => Positioned(
                          left: table.x,
                          top: table.y,
                          child: TableNode(
                            table: table,
                            status: controller.resolveStatus(table),
                            isMoving: controller.movingTableId == table.id,
                            isSuggestedJoin:
                                controller.suggestedJoinTargetId == table.id ||
                                controller.movingTableId == table.id,
                            onTap: () => onOpenTable(table),
                            onDoubleTap: () => onOpenOrder(table),
                            onPanStart: () => controller.beginMove(table.id),
                            onPanUpdate: (delta) => controller.moveTable(
                              table.id,
                              delta,
                              canvasSize,
                            ),
                            onPanEnd: controller.finishMove,
                          ),
                        ),
                      ),
                      if (controller.suggestedJoinTargetId != null &&
                          controller.movingTableId != null)
                        Positioned(
                          left: 18,
                          bottom: 18,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: GulaColors.surfaceAlt.withOpacity(0.94),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: GulaColors.primary),
                            ),
                            child: const Text(
                              'Mesa proxima detectada. Solte e una pelo painel da mesa.',
                              style: TextStyle(
                                color: GulaColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fineLine = Paint()
      ..color = GulaColors.borderSoft.withOpacity(0.55)
      ..strokeWidth = 1;

    const gap = 24.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fineLine);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fineLine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
