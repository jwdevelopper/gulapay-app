import 'package:flutter/material.dart';

import 'estoque_palette.dart';

class EstoqueEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final String? tipText;

  const EstoqueEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
    this.tipText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EstoquePalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EstoquePalette.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: EstoquePalette.shadow,
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
              color: EstoquePalette.inputFill,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: EstoquePalette.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: EstoquePalette.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: EstoquePalette.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EstoquePalette.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: EstoquePalette.primaryPressed.withValues(
                    alpha: 0.35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(buttonLabel!),
              ),
            ),
          ],
          if (tipText != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: EstoquePalette.textMuted,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tipText!,
                    style: const TextStyle(
                      color: EstoquePalette.textMuted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
