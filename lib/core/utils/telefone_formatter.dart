import 'package:flutter/services.dart';

/// Máscara global para telefones brasileiros.
///
/// Formatos suportados:
/// - telefone fixo: `(11) 3333-4444`;
/// - celular: `(11) 99999-9999`;
/// - celular com país: `+55 (11) 99999-9999`.
///
/// A classe cuida somente da apresentação. DTOs e services continuam
/// responsáveis por decidir como o valor será persistido ou enviado à API.
final class TelefoneFormatter extends TextInputFormatter {
  static const int maxDigitosNacionais = 11;
  static const int maxDigitosComPais = 13;
  static const int maxCaracteresFormatados = 19;

  const TelefoneFormatter();

  /// Formata um valor já existente para uso em controllers, cards e detalhes.
  static String formatar(String? value) {
    final original = value?.trim() ?? '';
    if (original.isEmpty) return '';

    final digits = original.replaceAll(RegExp(r'\D'), '');
    if (original.startsWith('+')) {
      final limited = _limit(digits, maxDigitosComPais);
      if (limited.isEmpty) return '+';
      if (limited.length < 2) return '+$limited';

      final countryCode = limited.substring(0, 2);
      if (countryCode != '55') return '+$limited';

      final national = limited.substring(2);
      if (national.isEmpty) return '+55';
      return '+55 ${_formatNational(national)}';
    }

    return _formatNational(_limit(digits, maxDigitosNacionais));
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatar(newValue.text);
    final originalOffset = newValue.selection.extentOffset
        .clamp(0, newValue.text.length)
        .toInt();
    final digitsBeforeCursor = newValue.text
        .substring(0, originalOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final selectionOffset = _selectionOffset(
      formatted,
      digitsBeforeCursor,
      originalOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }

  static String _formatNational(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length == 1) return '($digits';

    final ddd = digits.substring(0, 2);
    if (digits.length == 2) return '($ddd)';

    final subscriber = digits.substring(2);
    final prefixLength = subscriber.startsWith('9') ? 5 : 4;
    if (subscriber.length <= prefixLength) {
      return '($ddd) $subscriber';
    }

    return '($ddd) ${subscriber.substring(0, prefixLength)}-'
        '${subscriber.substring(prefixLength)}';
  }

  static int _selectionOffset(
    String formatted,
    int digitCount,
    int originalOffset,
  ) {
    if (formatted.isEmpty) return 0;
    if (digitCount == 0) {
      if (originalOffset > 0 &&
          (formatted.startsWith('+') || formatted.startsWith('('))) {
        return 1;
      }
      return 0;
    }

    var seen = 0;
    for (var index = 0; index < formatted.length; index++) {
      if (_isDigit(formatted.codeUnitAt(index))) {
        seen++;
        if (seen == digitCount) {
          var offset = index + 1;
          while (offset < formatted.length &&
              !_isDigit(formatted.codeUnitAt(offset))) {
            offset++;
          }
          return offset;
        }
      }
    }
    return formatted.length;
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;

  static String _limit(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength);
  }
}
