import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_botao_componente.dart';

class CategoriaPage extends StatelessWidget {
  const CategoriaPage({super.key});

  void funcaoExecutada() {
    print("Função executada pelo botão presente em categoria");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppBotaoComponente(
        altura: 140,
        largura: 440,
        textoBotao: "Botão presente em categoria",
        funcaoExecutada: funcaoExecutada,
        icone: Icon(Icons.plus_one),
        corFundoBotao: Colors.green,
        foregroundColor: Colors.yellow,
      ),
    );
  }
}
