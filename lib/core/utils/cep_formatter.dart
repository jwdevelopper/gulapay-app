import 'package:flutter/services.dart';

/// Máscara de CEP brasileiro (`01310-100`).
///
/// Segue o mesmo desenho do [TelefoneFormatter]: a máscara é só
/// apresentação, e [somenteDigitos] é o que vai para a API. Foi escrita à
/// mão, e não com um pacote de máscaras, para o app não ganhar uma
/// dependência inteira por causa de um campo — e para o comportamento
/// ficar igual ao do telefone, que já é feito assim.
final class CepFormatter extends TextInputFormatter {
  /// CEP tem 8 dígitos; formatado, ocupa 9 caracteres com o hífen.
  static const int digitos = 8;
  static const int maxCaracteresFormatados = 9;

  const CepFormatter();

  /// Só os dígitos, sem o hífen — é esta forma que a API recebe.
  static String somenteDigitos(String? valor) =>
      (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  /// Formata um valor existente, para preencher o campo na edição.
  ///
  /// ```dart
  /// CepFormatter.formatar('01310100'); // '01310-100'
  /// CepFormatter.formatar('013101');   // '01310-1'
  /// ```
  static String formatar(String? valor) {
    final numeros = _limitar(somenteDigitos(valor));
    if (numeros.length <= 5) return numeros;
    return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
  }

  /// O CEP está completo?
  static bool completo(String? valor) =>
      somenteDigitos(valor).length == digitos;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    final texto = formatar(novo.text);
    // O cursor vai para o fim do que foi formatado: como a máscara só
    // insere um hífen numa posição fixa, não há ganho em recalcular a
    // posição exata como o telefone faz.
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  static String _limitar(String valor) =>
      valor.length <= digitos ? valor : valor.substring(0, digitos);
}
