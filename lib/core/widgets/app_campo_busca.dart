import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppCampoBusca extends StatelessWidget {
  final TextEditingController controle;
  final String dica;
  final void Function(String) aoMudar;

  const AppCampoBusca({
    super.key,
    required this.controle,
    required this.aoMudar,
    this.dica = 'Buscar...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controle,
      onChanged: aoMudar,
      decoration: InputDecoration(
        hintText: dica,
        hintStyle: const TextStyle(color: Color(0xFFB7A98A)),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: AppTema.primariaEscura),
        suffixIcon: controle.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: AppTema.primariaEscura),
                onPressed: () {
                  controle.clear();
                  aoMudar('');
                },
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTema.bordaCampo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTema.primaria, width: 1.5),
        ),
      ),
    );
  }
}
