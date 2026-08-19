import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoriaGestoStatus extends StatelessWidget {
  const CategoriaGestoStatus({
    super.key,
    required this.chave,
    required this.ativa,
    required this.aoConfirmar,
    required this.aoConcluir,
    required this.child,
  });

  final Object chave;
  final bool ativa;
  final Future<bool> Function() aoConfirmar;
  final VoidCallback aoConcluir;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? Colors.red.shade600 : const Color(0xFF2E8B57);
    final texto = ativa ? 'Inativar' : 'Reativar';
    final icone = ativa
        ? FontAwesomeIcons.ban
        : FontAwesomeIcons.arrowRotateLeft;

    return Dismissible(
      key: ValueKey('categoria_$chave'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {DismissDirection.endToStart: 0.5},
      background: const SizedBox.expand(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(icone, color: Colors.white, size: 18),
          ],
        ),
      ),
      confirmDismiss: (_) => aoConfirmar(),
      onDismissed: (_) => aoConcluir(),
      child: child,
    );
  }
}
