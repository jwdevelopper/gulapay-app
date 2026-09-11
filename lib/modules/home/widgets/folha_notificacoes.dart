import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';

/// Abre a folha de notificações.
///
/// Ainda não há fonte de notificações no backend; a folha existe para o
/// sino da AppBar ter destino e mostrar honestamente que não há nada —
/// melhor que um botão inerte.
Future<void> abrirFolhaNotificacoes(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTema.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificações',
                style: TextStyle(
                  color: AppTema.texto,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              AppEstadoVazio(
                icone: Icons.notifications_none_rounded,
                mensagem: 'Nenhuma notificação no momento.',
              ),
            ],
          ),
        ),
      ),
    );
