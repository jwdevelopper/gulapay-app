import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class InsumoSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String search;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const InsumoSearchField({
    super.key,
    required this.controller,
    required this.search,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = search.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar insumo...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: AppTema.textoSecundario,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  splashRadius: 18,
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTema.bordaCampo,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTema.bordaCampo,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTema.primaria,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}