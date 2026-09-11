import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/widgets/app_expandable_fab.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';

/// Painel inicial do app.
///
/// Ainda sem métricas: o conteúdo é um lembrete honesto de que os números
/// (vendas do dia, comandas abertas, estoque baixo) ainda não existem.
/// O que já funciona são os atalhos do botão em leque.
///
/// Os atalhos pedem a troca de aba **pelo título**, não por um índice —
/// navegar por posição fazia um atalho apontar para a tela errada assim que
/// uma aba entrava no meio do menu.
class DashboardPage extends StatefulWidget {
  /// Abre outra aba do app pelo título. Ver [TitulosAba].
  final ValueChanged<String>? aoAbrirAba;

  const DashboardPage({super.key, this.aoAbrirAba});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _chaveFab = GlobalKey<AppExpandableFabState>();

  /// Fecha o leque e troca de aba — sem fechar, o FAB continuaria aberto
  /// por cima da tela de destino.
  void _abrir(String titulo) {
    _chaveFab.currentState?.fechar();
    widget.aoAbrirAba?.call(titulo);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: AppEstadoVazio(
          icone: Icons.insights_outlined,
          titulo: 'Painel em construção',
          mensagem:
              'Em breve: vendas do dia, comandas abertas e alertas de '
              'estoque. Use o botão ao lado para ir direto às telas mais '
              'usadas.',
        ),
      ),
    ),
    floatingActionButton: AppExpandableFab(
      key: _chaveFab,
      distance: 112,
      children: [
        AppActionButton(
          onPressed: () => _abrir(TitulosAba.produtos),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
        AppActionButton(
          onPressed: () => _abrir(TitulosAba.categorias),
          icon: const Icon(Icons.category_outlined),
        ),
        AppActionButton(
          onPressed: () => _abrir(TitulosAba.estoque),
          icon: const Icon(Icons.inventory_2_outlined),
        ),
      ],
    ),
  );
}
