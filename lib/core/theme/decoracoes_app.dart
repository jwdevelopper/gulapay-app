import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Decorações compartilhadas entre os campos de formulário.
///
/// Existe para que campo de texto, campo de data e seletores tenham
/// exatamente a mesma moldura — antes cada um repetia o bloco
/// `BoxDecoration` à mão, com a sombra hardcoded em 6 arquivos, e qualquer
/// ajuste precisava ser replicado um a um.
class DecoracoesApp {
  const DecoracoesApp._();

  static const raioCampo = 16.0;

  /// Moldura padrão de um campo editável. [erro] troca a borda para o
  /// vermelho de validação.
  static BoxDecoration campo({bool erro = false}) => BoxDecoration(
    color: AppTema.superficieAlt,
    borderRadius: BorderRadius.circular(raioCampo),
    border: Border.all(color: erro ? AppTema.erro : AppTema.borda),
    boxShadow: const [
      BoxShadow(
        color: AppTema.sombraCampo,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Variante sem sombra, para campos embutidos em cartões que já têm
  /// elevação própria.
  static BoxDecoration campoPlano({bool erro = false}) => BoxDecoration(
    color: AppTema.superficieAlt,
    borderRadius: BorderRadius.circular(raioCampo),
    border: Border.all(color: erro ? AppTema.erro : AppTema.borda),
  );
}
