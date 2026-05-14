import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Menu de 3 pontos padrão para cards de listagem.
///
/// Convenção do app (ver CLAUDE.md, seção "Padrão de cards de listagem"):
/// o card de qualquer listagem expõe três caminhos de ação equivalentes:
///   1. **Tap no card** → edição;
///   2. **Swipe-to-delete** (Dismissible) → confirmação + exclusão;
///   3. **AppMenuAcoes (3 pontos)** → fallback acessível com as mesmas duas
///      ações ("Editar" e "Excluir"). É o que este widget renderiza.
///
/// O item "Excluir" é destacado em vermelho para sinalizar ação destrutiva.
/// O parent é responsável por mostrar a confirmação antes de executar a
/// exclusão de fato — assim o fluxo do menu fica idêntico ao do swipe.
class AppMenuAcoes extends StatelessWidget {
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  /// Rótulo do item de edição (ex.: "Editar produto"). Default: "Editar".
  final String rotuloEditar;

  /// Rótulo do item de exclusão (ex.: "Excluir produto"). Default: "Excluir".
  final String rotuloExcluir;

  /// Tooltip exibido ao manter pressionado o botão (ex.: "Ações do produto").
  final String tooltip;

  const AppMenuAcoes({
    super.key,
    required this.onEditar,
    required this.onExcluir,
    this.rotuloEditar = 'Editar',
    this.rotuloExcluir = 'Excluir',
    this.tooltip = 'Ações',
  });

  @override
  Widget build(BuildContext context) {
    final corExcluir = Colors.red.shade600;

    return PopupMenuButton<String>(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      offset: const Offset(0, 8),
      color: AppTema.cartao,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTema.bordaCampo),
      ),
      constraints: const BoxConstraints(minWidth: 176),
      onSelected: (value) {
        switch (value) {
          case 'editar':
            onEditar();
            break;
          case 'excluir':
            onExcluir();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'editar',
          child: Row(
            children: [
              const Icon(
                Icons.edit_rounded,
                size: 18,
                color: AppTema.textoEscuro,
              ),
              const SizedBox(width: 12),
              Text(
                rotuloEditar,
                style: const TextStyle(color: AppTema.textoEscuro),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'excluir',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: corExcluir,
              ),
              const SizedBox(width: 12),
              Text(
                rotuloExcluir,
                style: TextStyle(
                  color: corExcluir,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppTema.textoSecundario,
        size: 22,
      ),
    );
  }
}
