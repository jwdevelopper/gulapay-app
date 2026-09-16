import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/comanda/dto/item_comanda_response.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';

/// Participante reduzido ao que o chip precisa mostrar.
typedef RateioParticipanteChip = ({int id, String nome});

/// Uma linha da estratégia POR_ITEM: o item da comanda e os chips de quem
/// consumiu. Um item pode ter vários consumidores (a pizza dividida entre
/// 3) — nesse caso o subtotal é rateado igualmente entre os marcados, e o
/// tile já mostra quanto fica pra cada um.
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

  /// Ids de comanda INDIVIDUAL marcados neste item.
  final Set<int> consumidores;
  final bool habilitado;
  final void Function(int comandaIndividualId) aoAlternar;
  final VoidCallback aoMarcarTodos;

  bool get _semConsumidor => consumidores.isEmpty;

  String _money(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Quantidade vem como double da API (0,5 kg), então corta o `.0` dos
  /// itens unitários pra não mostrar "2.0x Coca".
  String get _quantidade => item.quantidade == item.quantidade.roundToDouble()
      ? item.quantidade.toStringAsFixed(0)
      : item.quantidade.toString().replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: _semConsumidor
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
                      Text('${_quantidade}x ${item.produtoNome}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: EstoquePalette.text)),
                      const SizedBox(height: 2),
                      Text(
                        consumidores.length > 1
                            ? '${_money(item.subtotal)} · ${_money(item.subtotal / consumidores.length)} por pessoa'
                            : _money(item.subtotal),
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
                  child: Text(
                      consumidores.length == participantes.length
                          ? 'Limpar'
                          : 'Todos'),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 2,
              children: participantes
                  .map((p) => FilterChip(
                        label: Text(p.nome,
                            style: const TextStyle(fontSize: 12)),
                        selected: consumidores.contains(p.id),
                        onSelected:
                            habilitado ? (_) => aoAlternar(p.id) : null,
                        showCheckmark: false,
                        backgroundColor: EstoquePalette.inputFill,
                        selectedColor: EstoquePalette.primarySoft,
                        side: BorderSide(
                            color: consumidores.contains(p.id)
                                ? EstoquePalette.primary
                                : EstoquePalette.border),
                        labelStyle: TextStyle(
                            color: EstoquePalette.text,
                            fontWeight: consumidores.contains(p.id)
                                ? FontWeight.w700
                                : FontWeight.w400),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
