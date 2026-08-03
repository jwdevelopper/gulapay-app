import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class RestaurantAreaTab extends StatelessWidget {
  const RestaurantAreaTab({
    super.key,
    required this.area,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final RestaurantArea area;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final occupancyRate = area.totalTables == 0
        ? 0.0
        : (area.occupancyCount / area.totalTables).clamp(0.0, 1.0).toDouble();

    final tabWidth = compact ? 148.0 : 168.0;
    final iconSize = compact ? 16.0 : 18.0;
    final iconBox = compact ? 30.0 : 34.0;
    final nameSize = compact ? 12.0 : 13.0;
    final infoSize = compact ? 10.0 : 11.0;
    final progressHeight = compact ? 4.0 : 5.0;
    final padding = EdgeInsets.symmetric(
      horizontal: compact ? 10 : 12,
      vertical: compact ? 8 : 10,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${area.name}, ${area.occupancyCount} de ${area.totalTables} em uso',
      child: SizedBox(
        width: tabWidth,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: padding,
              decoration: BoxDecoration(
                color: isSelected ? GulaColors.primary : GulaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? GulaColors.primary : GulaColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isSelected ? 0.08 : 0.025,
                    ),
                    blurRadius: compact ? 10 : 14,
                    offset: Offset(0, compact ? 5 : 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.18)
                          : GulaColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _areaIcon(area.type),
                      size: iconSize,
                      color: isSelected ? Colors.white : GulaColors.text,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.white : GulaColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: nameSize,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: progressHeight,
                            value: occupancyRate,
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.24)
                                : GulaColors.borderSoft,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected ? Colors.white : GulaColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 5),
                        Text(
                          '${area.occupancyCount}/${area.totalTables} em uso',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : GulaColors.textMuted,
                            fontSize: infoSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _areaIcon(String type) {
    switch (type) {
      case 'externo':
        return Icons.deck_outlined;
      case 'premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }
}
