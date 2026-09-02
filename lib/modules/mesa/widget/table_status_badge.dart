import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

Color corSituacaoMesa(SituacaoMesa situacao) {
  switch (situacao) {
    case SituacaoMesa.livre:
      return GulaColors.free;
    case SituacaoMesa.ocupada:
      return GulaColors.occupied;
    case SituacaoMesa.semPedidoHa30Min:
      return GulaColors.warning;
    case SituacaoMesa.aguardandoLiberacaoHa1H:
      return GulaColors.critical;
    case SituacaoMesa.comPedido:
      return GulaColors.occupied;
    case SituacaoMesa.atencao:
      return GulaColors.critical;
  }
}

String rotuloSituacaoMesa(SituacaoMesa situacao) {
  switch (situacao) {
    case SituacaoMesa.livre:
      return 'Livre';
    case SituacaoMesa.ocupada:
      return 'Ocupada';
    case SituacaoMesa.semPedidoHa30Min:
      return 'Sem pedido 30m';
    case SituacaoMesa.aguardandoLiberacaoHa1H:
      return 'Liberar 1h';
    case SituacaoMesa.comPedido:
      return 'Com pedido';
    case SituacaoMesa.atencao:
      return 'Em atencao';
  }
}

IconData iconeSituacaoMesa(SituacaoMesa situacao) {
  switch (situacao) {
    case SituacaoMesa.livre:
      return Icons.check_circle_outline_rounded;
    case SituacaoMesa.ocupada:
      return Icons.schedule_outlined;
    case SituacaoMesa.semPedidoHa30Min:
      return Icons.schedule_outlined;
    case SituacaoMesa.aguardandoLiberacaoHa1H:
      return Icons.priority_high_rounded;
    case SituacaoMesa.comPedido:
      return Icons.schedule_rounded;
    case SituacaoMesa.atencao:
      return Icons.priority_high_rounded;
  }
}

class IndicadorSituacaoMesa extends StatelessWidget {
  const IndicadorSituacaoMesa({
    super.key,
    required this.situacao,
    this.compacto = false,
  });

  final SituacaoMesa situacao;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final color = corSituacaoMesa(situacao);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 8 : 10,
        vertical: compacto ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GulaColors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconeSituacaoMesa(situacao),
            size: compacto ? 12 : 14,
            color: GulaColors.text,
          ),
          const SizedBox(width: 6),
          Text(
            rotuloSituacaoMesa(situacao),
            style: TextStyle(
              color: GulaColors.text,
              fontSize: compacto ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
