import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';

/// Acompanhamento de pedidos.
///
/// Ainda não implementada. O backend já expõe Comanda e ItemComanda; esta
/// tela será a visão operacional deles — o que está em preparo e o que
/// saiu — e por ora diz isso em vez de fingir conteúdo.
class PedidosPagina extends StatelessWidget {
  const PedidosPagina({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppTema.fundo,
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: AppEstadoVazio(
          icone: Icons.list_alt_outlined,
          titulo: 'Pedidos em breve',
          mensagem:
              'Aqui você vai acompanhar o que está em preparo e o que já '
              'saiu. Por enquanto, use a tela de Comandas.',
        ),
      ),
    ),
  );
}
