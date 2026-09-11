import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/widgets/resumo_pedido_mesa.dart';
import 'package:my_app_teste/modules/mesa/widgets/table_status_badge.dart';

/// Pedido de uma mesa do salão.
///
/// **Fluxo provisório.** O editor de salão ainda trabalha com dados locais:
/// os itens aqui são simulados e não passam pela API de Comanda, que o
/// backend já entrega. Enquanto a integração não acontece, esta tela serve
/// para manter a interação de mesas de pé sem duplicar o conceito de
/// pedido.
class MesaOrderPage extends StatelessWidget {
  const MesaOrderPage({
    super.key,
    required this.controller,
    required this.tableId,
  });

  final FloorPlanController controller;
  final String tableId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final mesa = controller.findTableById(tableId);
      if (mesa == null) return _mesaNaoEncontrada();

      return Scaffold(
        backgroundColor: AppTema.fundo,
        appBar: AppBar(
          backgroundColor: AppTema.fundo,
          foregroundColor: AppTema.texto,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTema.primariaEscura),
          title: Text(
            'Pedido · ${mesa.code}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTema.texto,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ResumoPedidoMesa(
              codigo: mesa.code,
              area: controller.areaById(mesa.areaId)?.name,
              etiquetaStatus: TableStatusBadge(
                status: controller.resolveStatus(mesa),
              ),
              comanda: controller.activeOrderIdForScope(tableId),
              mesasDoGrupo: controller
                  .tablesForScope(tableId)
                  .map((m) => m.code)
                  .toList(),
              itens: controller.groupItemsCount(tableId),
              parcial: formatarMoedaBr(controller.groupPartialTotal(tableId)),
            ),
            const SizedBox(height: 18),
            const AppCartaoAviso.dica(
              'Fluxo provisório: os itens desta tela são simulados e ainda '
              'não passam pela API de comandas.',
            ),
            const SizedBox(height: 18),
            _botaoAdicionarItem(context),
            const SizedBox(height: 12),
            _botaoLiberarMesa(context),
          ],
        ),
      );
    },
  );

  Widget _mesaNaoEncontrada() => Scaffold(
    backgroundColor: AppTema.fundo,
    appBar: AppBar(
      backgroundColor: AppTema.fundo,
      foregroundColor: AppTema.texto,
      elevation: 0,
      title: const Text('Pedido da mesa'),
    ),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: AppEstadoVazio(
          icone: Icons.table_restaurant_outlined,
          titulo: 'Mesa não encontrada',
          mensagem: 'Ela pode ter sido removida do salão.',
        ),
      ),
    ),
  );

  Widget _botaoAdicionarItem(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () async {
        await controller.addSimulatedItem(tableId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item simulado adicionado à comanda.')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.add_shopping_cart_outlined),
      label: const Text('Adicionar item simulado'),
    ),
  );

  Widget _botaoLiberarMesa(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () async {
        await controller.markTableAsFree(tableId);
        if (context.mounted) Navigator.pop(context);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTema.primariaEscura,
        side: const BorderSide(color: AppTema.borda),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.cleaning_services_outlined),
      label: const Text('Liberar mesa'),
    ),
  );
}
