import 'package:flutter/material.dart';

class AppBotaoComponente extends StatelessWidget {
  final String textoBotao;
  final double largura;
  final double altura;
  final VoidCallback funcaoExecutada;
  final Icon? icone;
  final bool? alinharIconeADireita;
  final Color? corFundoBotao;
  final Color? foregroundColor;
  final double? tamanhoFonte;
  final double? tamanhoIcone;
  final FontWeight? tipoFonte;

  const AppBotaoComponente({
    super.key,
    required this.textoBotao,
    required this.largura,
    required this.altura,
    required this.funcaoExecutada,
    this.icone,
    this.alinharIconeADireita,
    this.corFundoBotao,
    this.foregroundColor,
    this.tamanhoFonte,
    this.tamanhoIcone,
    this.tipoFonte,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: ElevatedButton.icon(
        onPressed: funcaoExecutada,
        label: Text(
          textoBotao,
          style: TextStyle(
            fontSize: tamanhoFonte,
            fontWeight: tipoFonte,
          ),
          ),
        icon: Icon(
          icone?.icon,
          size: tamanhoIcone,
        ),
        style: ElevatedButton.styleFrom(
          iconAlignment: alinharIconeADireita == true
              ? IconAlignment.end
              : IconAlignment.start,
          backgroundColor: corFundoBotao ?? Colors.blueAccent,
          foregroundColor: foregroundColor ?? Colors.white,
        ),
      ),
    );
  }
}
