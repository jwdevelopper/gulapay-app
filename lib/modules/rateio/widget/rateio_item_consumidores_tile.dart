import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/comanda/dto/item_comanda_response.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';

class RateioItemConsumidoresTile extends StatelessWidget {
  const RateioItemConsumidoresTile({
    super.key,
    required this.item,
    required this.participantes,
    required this.consumidores,
    required this.habilitado,
    required this.aoAlternar,
    required this.aoMarcarTodos,
  });

  final ItemComandaResponse item;
  final List<RateioParticipanteChip> participantes;
  final Set<int> consumidores;
  final bool habilitado;
  final void Function(int comandaIndividualId) aoAlternar;
  final VoidCallback aoMarcarTodos;

  @override
  Widget build(BuildContext context) {
    final semConsumidor = consumidores.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: semConsumidor
                ? EstoquePalette.error.withValues(alpha: 0.5)
                : EstoquePalette.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${quantidadeItem(item.quantidade)}x ${item.produtoNome}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: EstoquePalette.text)),
                      const SizedBox(height: 2),
                      Text(
                        consumidores.length > 1
                            ? '${moeda(item.subtotal)} · ${moeda(item.subtotal / consumidores.length)} por pessoa'
                            : moeda(item.subtotal),
                        style: const TextStyle(
                            color: EstoquePalette.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: habilitado ? aoMarcarTodos : null,
                  style: TextButton.styleFrom(
                      foregroundColor: EstoquePalette.primary,
                      visualDensity: VisualDensity.compact),
                  child: Text(consumidores.length == participantes.length
                      ? 'Limpar'
                      : 'Todos'),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 2,
              children: participantes.map(_chip).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(RateioParticipanteChip p) {
    final marcado = consumidores.contains(p.id);
    return FilterChip(
      label: Text(p.nome, style: const TextStyle(fontSize: 12)),
      selected: marcado,
      onSelected: habilitado ? (_) => aoAlternar(p.id) : null,
      showCheckmark: false,
      backgroundColor: EstoquePalette.inputFill,
      selectedColor: EstoquePalette.primarySoft,
      side: BorderSide(
          color: marcado ? EstoquePalette.primary : EstoquePalette.border),
      labelStyle: TextStyle(
          color: EstoquePalette.text,
          fontWeight: marcado ? FontWeight.w700 : FontWeight.w400),
    );
  }
}
