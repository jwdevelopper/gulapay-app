import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/home/dto/aba_principal.dart';

/// Barra inferior curvada da [Home].
///
/// Mostra as abas fixas mais um botão "Mais", que abre o menu lateral com o
/// resto. A bolha da curva acompanha [indiceVisual], que **não** é o índice
/// da página: quando a aba aberta não está na barra, a bolha fica sobre o
/// "Mais" — a última posição.
class BarraInferiorHome extends StatelessWidget {
  /// Apenas as abas fixas na barra.
  final List<AbaPrincipal> abas;

  /// Posição da bolha: de `0` a `abas.length` (o último é o "Mais").
  final int indiceVisual;

  /// Chamado com o índice da aba tocada.
  final ValueChanged<int> aoTocarAba;

  /// Chamado ao tocar no "Mais".
  final VoidCallback aoTocarMais;

  const BarraInferiorHome({
    super.key,
    required this.abas,
    required this.indiceVisual,
    required this.aoTocarAba,
    required this.aoTocarMais,
  });

  Color _cor(int indice) =>
      indice == indiceVisual ? Colors.white : AppTema.textoSecundario;

  @override
  Widget build(BuildContext context) => CurvedNavigationBar(
    height: 65,
    index: indiceVisual,
    backgroundColor: AppTema.fundo,
    color: Color.lerp(AppTema.fundo, Colors.black, 0.08)!,
    buttonBackgroundColor: AppTema.primaria,
    animationDuration: const Duration(milliseconds: 300),
    animationCurve: Curves.easeInOut,
    items: [
      for (var i = 0; i < abas.length; i++)
        Icon(abas[i].icone, size: 30, color: _cor(i)),
      Icon(Icons.more_horiz, size: 30, color: _cor(abas.length)),
    ],
    onTap: (indice) =>
        indice < abas.length ? aoTocarAba(indice) : aoTocarMais(),
  );
}
