import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';

void main() {
  group('TelefoneFormatter.formatar', () {
    test('formata telefone fixo brasileiro', () {
      expect(TelefoneFormatter.formatar('1133334444'), '(11) 3333-4444');
    });

    test('formata celular brasileiro', () {
      expect(TelefoneFormatter.formatar('11987654321'), '(11) 98765-4321');
    });

    test('formata celular com codigo +55', () {
      expect(
        TelefoneFormatter.formatar('+5511987654321'),
        '+55 (11) 98765-4321',
      );
    });

    test('formata progressivamente durante a digitacao', () {
      expect(TelefoneFormatter.formatar('1'), '(1');
      expect(TelefoneFormatter.formatar('11'), '(11)');
      expect(TelefoneFormatter.formatar('119'), '(11) 9');
      expect(TelefoneFormatter.formatar('1198765'), '(11) 98765');
    });

    test('ignora caracteres que nao pertencem ao numero', () {
      expect(TelefoneFormatter.formatar('11abc98765-4321'), '(11) 98765-4321');
    });

    test('limita o numero nacional a onze digitos', () {
      expect(TelefoneFormatter.formatar('11987654321999'), '(11) 98765-4321');
    });

    test('aceita valor nulo ou vazio', () {
      expect(TelefoneFormatter.formatar(null), '');
      expect(TelefoneFormatter.formatar(''), '');
    });
  });

  group('TelefoneFormatter.formatEditUpdate', () {
    const formatter = TelefoneFormatter();

    test('aplica a mascara e posiciona o cursor no final', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '11987654321',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );

      expect(result.text, '(11) 98765-4321');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('preserva a posicao logica do cursor apos o DDD', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '11987654321',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );

      expect(result.text, '(11) 98765-4321');
      expect(result.selection.baseOffset, 5);
    });
  });
}
