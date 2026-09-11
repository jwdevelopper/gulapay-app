import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/home/dto/aba_principal.dart';

/// Menu lateral da [Home], com todas as abas visíveis ao perfil.
///
/// É o caminho completo: a barra inferior mostra só as abas fixas, e o
/// botão "Mais" abre este menu para chegar às demais.
class MenuLateralHome extends StatelessWidget {
  /// Abas já filtradas por perfil, na ordem do `IndexedStack`.
  final List<AbaPrincipal> abas;

  /// Índice da aba aberta.
  final int selecionado;

  /// Chamado com o índice escolhido.
  final ValueChanged<int> aoSelecionar;

  const MenuLateralHome({
    super.key,
    required this.abas,
    required this.selecionado,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppTema.fundo,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: AppTema.primaria),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        for (var i = 0; i < abas.length; i++)
          ListTile(
            leading: Icon(abas[i].icone),
            title: Text(abas[i].tituloAppBar),
            selected: i == selecionado,
            selectedColor: AppTema.primariaEscura,
            iconColor: AppTema.textoSecundario,
            textColor: AppTema.texto,
            selectedTileColor: AppTema.avisoFundo,
            onTap: () => aoSelecionar(i),
          ),
      ],
    ),
  );
}
