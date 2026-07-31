import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_botao_componente.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void funcaoExecutadaPeloBotao() {
    print("Função executada pelo botão presente em dashboard");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppBotaoComponente(
        altura: 70,
        largura: 340,
        textoBotao: "Botão presente em dashboard",
        funcaoExecutada: funcaoExecutadaPeloBotao,
        icone: Icon(Icons.dashboard),
        alinharIconeADireita: true,
        corFundoBotao: Colors.deepOrange,
        foregroundColor: Colors.black,
      ),
    );
  }
}
