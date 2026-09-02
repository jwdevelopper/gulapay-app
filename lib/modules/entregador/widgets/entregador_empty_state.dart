import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


class EntregadorEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final bool secondary;

  const EntregadorEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = secondary
        ? OutlinedButton.styleFrom(
            foregroundColor: PaletaApp.text,
            side: const BorderSide(color: PaletaApp.border),
            backgroundColor: PaletaApp.surfaceAlt,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: PaletaApp.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PaletaApp.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PaletaApp.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: PaletaApp.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: PaletaApp.inputFill,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: PaletaApp.primary, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PaletaApp.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PaletaApp.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: secondary
                ? OutlinedButton.icon(
                    onPressed: onPressed,
                    style: buttonStyle,
                    icon: Icon(buttonIcon),
                    label: Text(buttonLabel),
                  )
                : ElevatedButton.icon(
                    onPressed: onPressed,
                    style: buttonStyle,
                    icon: Icon(buttonIcon),
                    label: Text(buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
