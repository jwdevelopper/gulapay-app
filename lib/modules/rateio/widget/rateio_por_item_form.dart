import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';
import 'rateio_item_consumidores_tile.dart';
import 'rateio_linha_valor.dart';
import 'rateio_status_box.dart';

class RateioPorItemForm extends StatelessWidget {
  const RateioPorItemForm({super.key, required this.controller});

  final RateioController controller;

  @override
  Widget build(BuildContext context) {
    final chips = controller.chips;
    if (chips.isEmpty) {
      return const Text(
        'Marque ao menos 1 participante acima para atribuir os itens.',
        style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12),
      );
    }

    final itens = controller.itensAtivos;
    final faltando = controller.itensSemConsumidor.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDica(
          'Marque quem consumiu cada item. Um item dividido entre várias '
          'pessoas tem o valor partido igualmente entre elas.',
        ),
        const SizedBox(height: 12),
        ...itens.map((item) => RateioItemConsumidoresTile(
              item: item,
              participantes: chips,
              consumidores: controller.consumidoresDe(item.id!),
              habilitado: !controller.executando,
              aoAlternar: (idPessoa) =>
                  controller.alternarConsumidor(item.id!, idPessoa),
              aoMarcarTodos: () =>
                  controller.alternarTodosConsumidores(item.id!),
            )),
        const SizedBox(height: 4),
        RateioStatusBox(
          ok: faltando == 0,
          titulo: '${itens.length - faltando} de ${itens.length} '
              'itens atribuídos',
          detalhe: switch (faltando) {
            0 => 'Todo item tem pelo menos um consumidor.',
            1 => 'Falta marcar quem consumiu 1 item.',
            _ => 'Faltam marcar quem consumiu $faltando itens.',
          },
          rodape: faltando == 0 ? _previa() : null,
        ),
      ],
    );
  }

  Widget _previa() {
    final previa = controller.previaPorItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: controller.selecionados
          .map((p) => RateioLinhaValor(
                nome: controller.nomeDe(p),
                valor: moedaCentavos(previa[p.comandaIndividualId] ?? 0),
              ))
          .toList(),
    );
  }
}
