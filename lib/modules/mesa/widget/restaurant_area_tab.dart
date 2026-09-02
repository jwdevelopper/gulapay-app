import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class AbaAreaRestaurante extends StatelessWidget {
  const AbaAreaRestaurante({
    super.key,
    required this.area,
    required this.selecionada,
    required this.aoTocar,
    this.compacto = false,
  });

  final AreaRestaurante area;
  final bool selecionada;
  final VoidCallback aoTocar;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final occupancyRate = area.totalMesas == 0
        ? 0.0
        : (area.quantidadeOcupadas / area.totalMesas)
              .clamp(0.0, 1.0)
              .toDouble();

    final tabWidth = compacto ? 148.0 : 168.0;
    final iconSize = compacto ? 16.0 : 18.0;
    final iconBox = compacto ? 30.0 : 34.0;
    final nameSize = compacto ? 12.0 : 13.0;
    final infoSize = compacto ? 10.0 : 11.0;
    final progressHeight = compacto ? 4.0 : 5.0;
    final padding = EdgeInsets.symmetric(
      horizontal: compacto ? 10 : 12,
      vertical: compacto ? 8 : 10,
    );

    return Semantics(
      button: true,
      selected: selecionada,
      label:
          '${area.nome}, ${area.quantidadeOcupadas} de ${area.totalMesas} em uso',
      child: SizedBox(
        width: tabWidth,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: aoTocar,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: padding,
              decoration: BoxDecoration(
                color: selecionada ? GulaColors.primary : GulaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selecionada ? GulaColors.primary : GulaColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: selecionada ? 0.08 : 0.025,
                    ),
                    blurRadius: compacto ? 10 : 14,
                    offset: Offset(0, compacto ? 5 : 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: selecionada
                          ? Colors.white.withValues(alpha: 0.18)
                          : GulaColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconeArea(area.tipo),
                      size: iconSize,
                      color: selecionada ? Colors.white : GulaColors.text,
                    ),
                  ),
                  SizedBox(width: compacto ? 8 : 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selecionada ? Colors.white : GulaColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: nameSize,
                          ),
                        ),
                        SizedBox(height: compacto ? 4 : 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: progressHeight,
                            value: occupancyRate,
                            backgroundColor: selecionada
                                ? Colors.white.withValues(alpha: 0.24)
                                : GulaColors.borderSoft,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              selecionada ? Colors.white : GulaColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: compacto ? 4 : 5),
                        Text(
                          '${area.quantidadeOcupadas}/${area.totalMesas} em uso',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selecionada
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

  IconData _iconeArea(String tipo) {
    switch (tipo) {
      case 'externo':
        return Icons.deck_outlined;
      case 'premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }
}
