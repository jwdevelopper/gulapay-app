import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

Future<bool> confirmarMudancaStatusCategoria(
  BuildContext context,
  Categoria categoria, {
  required bool inativar,
}) async {
  final acao = inativar ? 'Inativar' : 'Reativar';
  final cor = inativar ? Colors.red.shade600 : const Color(0xFF2E8B57);
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: [
          FaIcon(
            inativar
                ? FontAwesomeIcons.triangleExclamation
                : FontAwesomeIcons.circleCheck,
            color: AppTema.primaria,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$acao categoria',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTema.textoEscuro,
            ),
          ),
        ],
      ),
      content: Text(
        inativar
            ? 'Deseja inativar "${categoria.nome}"? A categoria poderá ser reativada depois pelo filtro "INATIVAS".'
            : 'Deseja reativar "${categoria.nome}"?',
        style: const TextStyle(color: AppTema.textoEscuro),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          style: TextButton.styleFrom(foregroundColor: AppTema.textoSecundario),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: cor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(acao),
        ),
      ],
    ),
  );
  return confirmou ?? false;
}
