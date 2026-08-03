import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool secondary;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.onPressed,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ProdutosPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ProdutosPalette.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: ProdutosPalette.shadow,
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
              color: ProdutosPalette.inputFill,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: ProdutosPalette.primary, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProdutosPalette.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProdutosPalette.textMuted,
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProdutosPalette.text,
                      side: const BorderSide(color: ProdutosPalette.border),
                      backgroundColor: ProdutosPalette.surfaceAlt,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: Text(buttonLabel),
                  )
                : ElevatedButton.icon(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProdutosPalette.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: ProdutosPalette.primaryPressed.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }
}
