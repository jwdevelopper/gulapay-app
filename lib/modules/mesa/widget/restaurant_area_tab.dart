import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class RestaurantAreaTab extends StatelessWidget {
  const RestaurantAreaTab({
    super.key,
    required this.area,
    required this.isSelected,
    required this.onTap,
  });

  final RestaurantArea area;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final occupancyRate = area.totalTables == 0
        ? 0.0
        : (area.occupancyCount / area.totalTables).clamp(0.0, 1.0).toDouble();

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${area.name}, ${area.occupancyCount} de ${area.totalTables} em uso',
      child: SizedBox(
        width: 168,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.18)
                          : GulaColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _areaIcon(area.type),
                      size: 18,
                      color: isSelected ? Colors.white : GulaColors.text,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            value: occupancyRate,
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.24)
                                : GulaColors.borderSoft,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected ? Colors.white : GulaColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${area.occupancyCount}/${area.totalTables} em uso',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : GulaColors.textMuted,
                            fontSize: 11,
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
