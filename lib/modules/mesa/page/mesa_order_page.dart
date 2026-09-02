import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class ComandaMesaPagina extends StatelessWidget {
  const ComandaMesaPagina({
    super.key,
    required this.controlador,
    required this.idMesa,
  });

  final ControladorMapaMesas controlador;
  final String idMesa;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final mesa = controlador.buscarMesaPorId(idMesa);
        if (mesa == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pedido da mesa')),
            body: const Center(child: Text('Mesa nao encontrada.')),
          );
        }

        final mesasDoContexto = controlador.mesasDoContexto(idMesa);
        final situacao = controlador.resolverSituacao(mesa);
        final area = controlador.buscarAreaPorId(mesa.idArea);

        return Scaffold(
          appBar: AppBar(title: Text('Pedido - ${mesa.codigo}')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GulaColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: GulaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mesa.codigo,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IndicadorSituacaoMesa(situacao: situacao),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        area?.nome ?? 'Area nao identificada',
                        style: const TextStyle(
                          color: GulaColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _EstatisticaComanda(
                            rotulo: 'Comanda',
                            valor:
                                controlador.idComandaAtivaDoContexto(idMesa) ??
                                '--',
                          ),
                          _EstatisticaComanda(
                            rotulo: 'Mesas',
                            valor: mesasDoContexto
                                .map((item) => item.codigo)
                                .join(', '),
                          ),
                          _EstatisticaComanda(
                            rotulo: 'Itens',
                            valor: controlador
                                .quantidadeItensGrupo(idMesa)
                                .toString(),
                          ),
                          _EstatisticaComanda(
                            rotulo: 'Parcial',
                            valor:
                                'R\$ ${controlador.totalParcialGrupo(idMesa).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Fluxo provisiorio de comanda para manter a interacao de mesas sem duplicar pedido.',
                  style: TextStyle(color: GulaColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await controlador.adicionarItemSimulado(idMesa);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item simulado adicionado a comanda.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('Adicionar item simulado'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await controlador.liberarMesa(idMesa);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Liberar mesa'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EstatisticaComanda extends StatelessWidget {
  const _EstatisticaComanda({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              color: GulaColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
