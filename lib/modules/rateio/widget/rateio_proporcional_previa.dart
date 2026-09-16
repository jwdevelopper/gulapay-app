import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';
import 'rateio_linha_valor.dart';

class RateioProporcionalPrevia extends StatelessWidget {
  const RateioProporcionalPrevia({super.key, required this.controller});

  final RateioController controller;

  @override
  Widget build(BuildContext context) {
    final participantes = controller.selecionados;
    final pesoTotal =
        participantes.fold<double>(0, (soma, p) => soma + p.valorProprio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDica(
          'Quem consumiu mais por fora da comanda compartilhada paga uma '
          'fatia maior. O cálculo é feito pelo servidor — aqui embaixo é '
          'só a prévia dos pesos.',
        ),
        const SizedBox(height: 12),
        ...participantes.map((p) {
          final fatia = pesoTotal == 0 ? 0.0 : p.valorProprio / pesoTotal;
          return RateioLinhaValor(
            nome: controller.nomeDe(p),
            detalhe:
                '${moeda(p.valorProprio)} · ${(fatia * 100).toStringAsFixed(0)}%',
            valor: '≈ ${moeda(controller.totalLiquido * fatia)}',
          );
        }),
      ],
    );
  }
}
