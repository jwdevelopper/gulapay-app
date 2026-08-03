import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class ProdutoSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String search;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ProdutoSearchField({
    super.key,
    required this.controller,
    required this.search,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: ProdutosPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ProdutosPalette.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08A86D37),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            color: ProdutosPalette.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ProdutosPalette.textMuted,
            ),
            hintText: 'Buscar produto...',
            hintStyle: const TextStyle(color: ProdutosPalette.textMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: search.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
      ),
    );
  }
}
