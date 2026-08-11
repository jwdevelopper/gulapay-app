import 'package:flutter/material.dart';

import 'package:my_app_teste/core/widgets/app_botao_componente.dart';
import 'package:my_app_teste/core/widgets/app_expandable_fab.dart';

class DashboardPage extends StatefulWidget {
  final void Function(int index)? onNavegarParaAba;

  const DashboardPage({
    super.key,
    this.onNavegarParaAba,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _indiceSelecionado = 0;

  final _fabKey = GlobalKey<AppExpandableFabState>();

  void funcaoExecutadaPeloBotao() {
    print("Função executada pelo botão presente em dashboard");
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> minhasTelas = [
      Center(
        child: AppBotaoComponente(
          altura: 70,
          largura: 340,
          textoBotao: "Botão presente em dashboard",
          funcaoExecutada: funcaoExecutadaPeloBotao,
          icone: const Icon(Icons.dashboard),
          alinharIconeADireita: true,
          corFundoBotao: Colors.deepOrange,
          foregroundColor: Colors.black,
        ),
      ),
    ];

    return Scaffold(
      body: minhasTelas[_indiceSelecionado],
      floatingActionButton: AppExpandableFab(
        key: _fabKey,
        distance: 112.0,
        children: [
          AppActionButton(
            onPressed: () {
              _fabKey.currentState?.fechar();
              widget.onNavegarParaAba?.call(2); 
            },
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          AppActionButton(
            onPressed: () {
              _fabKey.currentState?.fechar();
              widget.onNavegarParaAba?.call(5); 
            },
            icon: const Icon(Icons.category_outlined),
          ),
          AppActionButton(
            onPressed: () {
              _fabKey.currentState?.fechar();
              widget.onNavegarParaAba?.call(4); 
            },
            icon: const Icon(Icons.inventory_2_outlined),
          ),
        ],
      ),
    );
  }
}