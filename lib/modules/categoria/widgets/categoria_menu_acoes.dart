import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

enum CategoriaAcaoMenu { editar, inativar, reativar }

class CategoriaMenuAcoes extends StatelessWidget {
  const CategoriaMenuAcoes({
    super.key,
    required this.ativa,
    required this.aoSelecionar,
  });

  final bool ativa;
  final ValueChanged<CategoriaAcaoMenu> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CategoriaAcaoMenu>(
      icon: const FaIcon(
        FontAwesomeIcons.ellipsisVertical,
        size: 16,
        color: AppTema.primariaEscura,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: aoSelecionar,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: CategoriaAcaoMenu.editar,
          child: _ItemMenuCategoria(
            icone: FaIcon(FontAwesomeIcons.penToSquare, size: 14),
            texto: 'Editar',
            cor: AppTema.primariaEscura,
          ),
        ),
        if (ativa)
          PopupMenuItem(
            value: CategoriaAcaoMenu.inativar,
            child: _ItemMenuCategoria(
              icone: const Icon(Icons.block, size: 14),
              texto: 'Inativar',
              cor: Colors.red.shade600,
            ),
          )
        else
          PopupMenuItem(
            value: CategoriaAcaoMenu.reativar,
            child: _ItemMenuCategoria(
              icone: const Icon(Icons.check_circle_outline, size: 14),
              texto: 'Reativar',
              cor: Colors.green.shade700,
            ),
          ),
      ],
    );
  }
}

class _ItemMenuCategoria extends StatelessWidget {
  const _ItemMenuCategoria({
    required this.icone,
    required this.texto,
    required this.cor,
  });

  final Widget icone;
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTheme(
          data: IconThemeData(color: cor),
          child: icone,
        ),
        const SizedBox(width: 10),
        Text(texto, style: TextStyle(color: cor)),
      ],
    );
  }
}
