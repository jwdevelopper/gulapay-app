import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppCampoTexto extends StatelessWidget {
  final TextEditingController controle;
  final String dica;
  final bool ocultar;
  final int? tamanhoMax;
  final Widget? sufixo;
  final Widget? prefixo;
  final TextInputType? tipoTeclado;
  final List<TextInputFormatter>? formatadores;
  final String? Function(String?)? validador;
  final void Function(String)? aoMudar;
  final bool habilitado;
  final int maxLinhas;
  final int? minLinhas;

  const AppCampoTexto({
    super.key,
    required this.controle,
    required this.dica,
    this.ocultar = false,
    this.tamanhoMax,
    this.sufixo,
    this.prefixo,
    this.tipoTeclado,
    this.formatadores,
    this.validador,
    this.aoMudar,
    this.habilitado = true,
    this.maxLinhas = 1,
    this.minLinhas,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controle,
      obscureText: ocultar,
      maxLength: tamanhoMax,
      maxLines: maxLinhas,
      minLines: minLinhas,
      keyboardType: tipoTeclado,
      inputFormatters: formatadores,
      validator: validador,
      onChanged: aoMudar,
      enabled: habilitado,
      style: const TextStyle(color: AppTema.textoEscuro),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppTema.cartao,
        hintText: dica,
        hintStyle: const TextStyle(color: Color(0xFFB7A98A)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        prefixIcon: prefixo,
        suffixIcon: sufixo,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTema.bordaCampo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTema.primaria, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
