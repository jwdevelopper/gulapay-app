import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Barra de abas da tela de estoque: Histórico e Saldos.
///
/// A aba "Saldos" ganha um selo com a contagem de insumos abaixo do mínimo
/// (RF43) — o alerta fica visível mesmo quando o usuário está no histórico.
///
/// Extraída de `estoque_page.dart`.
class AbasEstoque extends StatelessWidget implements PreferredSizeWidget {
  final TabController controlador;

  /// Quantidade de insumos abaixo do estoque mínimo. Zero esconde o selo.
  final int abaixoDoMinimo;

  const AbasEstoque({
    super.key,
    required this.controlador,
    required this.abaixoDoMinimo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTema.bordaSuave, width: 1.5),
        ),
      ),
      child: TabBar(
        controller: controlador,
        labelColor: AppTema.primaria,
        unselectedLabelColor: AppTema.textoSecundario,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppTema.primaria,
        indicatorWeight: 2.5,
        tabs: [
          const Tab(text: 'Histórico'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Saldos'),
                if (abaixoDoMinimo > 0) ...[
                  const SizedBox(width: 6),
                  _Selo(quantidade: abaixoDoMinimo),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final int quantidade;

  const _Selo({required this.quantidade});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppTema.primaria,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '$quantidade',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
