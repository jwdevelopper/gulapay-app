import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class LegendaMesas extends StatelessWidget {
  const LegendaMesas({super.key, this.compacto = false});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final padding = compacto ? 12.0 : 16.0;
    final spacing = compacto ? 6.0 : 8.0;
    final runSpacing = compacto ? 6.0 : 8.0;
    final titleSize = compacto ? 13.0 : 14.0;
    final bodySize = compacto ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: compacto ? 16 : 18,
                color: GulaColors.textMuted,
              ),
              SizedBox(width: compacto ? 6 : 8),
              Text(
                'Legenda operacional',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
          SizedBox(height: compacto ? 10 : 12),
          Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: [
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.livre,
                compacto: compacto,
              ),
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.ocupada,
                compacto: compacto,
              ),
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.semPedidoHa30Min,
                compacto: compacto,
              ),
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.aguardandoLiberacaoHa1H,
                compacto: compacto,
              ),
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.comPedido,
                compacto: compacto,
              ),
              IndicadorSituacaoMesa(
                situacao: SituacaoMesa.atencao,
                compacto: compacto,
              ),
            ],
          ),
          SizedBox(height: compacto ? 10 : 14),
          Text(
            'No modo editar, arraste mesas e aproxime itens da mesma area para sugerir uniao. A comanda e sempre reaproveitada dentro do mesmo grupo.',
            style: TextStyle(
              color: GulaColors.textMuted,
              height: 1.35,
              fontSize: bodySize,
            ),
          ),
        ],
      ),
    );
  }
}
