// Testes unitários do FormatadorEntradaMonetaria, criado para o BUG-03
// (campos "Desconto" e "Acréscimo" da comanda sem máscara/limite de dígitos).
//
// Sugestão de local no projeto:
// test/modules/comanda/page/comanda_detalhe_page_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/comanda/page/comanda_detalhe_page.dart';

void main() {
  late FormatadorEntradaMonetaria formatador;

  setUp(() {
    formatador = FormatadorEntradaMonetaria();
  });

  /// Simula o usuário digitando [texto] do zero (campo estava vazio antes).
  TextEditingValue digitar(String texto) {
    return formatador.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: texto,
        selection: TextSelection.collapsed(offset: texto.length),
      ),
    );
  }

  group('FormatadorEntradaMonetaria', () {
    test('campo vazio permanece vazio', () {
      final resultado = digitar('');
      expect(resultado.text, '');
    });

    test('um dígito vira centavos: "2" -> "0,02"', () {
      final resultado = digitar('2');
      expect(resultado.text, '0,02');
    });

    test('formata progressivamente conforme os dígitos aumentam', () {
      expect(digitar('2').text, '0,02');
      expect(digitar('22').text, '0,22');
      expect(digitar('222').text, '2,22');
      expect(digitar('2222').text, '22,22');
      expect(digitar('22222').text, '222,22');
    });

    test('6 dígitos formam o maior valor permitido antes do truncamento', () {
      final resultado = digitar('222222'); // 6 dígitos, no limite
      expect(resultado.text, '2222,22');
    });

    test('trunca entradas acima de 6 dígitos em vez de estourar o valor', () {
      final resultado = digitar('222222222'); // 9 dígitos, como no bug reportado
      // Deve considerar apenas os 6 primeiros dígitos: "222222" -> 2222,22
      expect(resultado.text, '2222,22');
      expect(resultado.text.replaceAll(RegExp(r'[^0-9]'), '').length, 6);
    });

    test('ignora caracteres não numéricos (prefixo, espaços, letras)', () {
      final resultado = formatador.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'R\$ 12,34 reais'),
      );
      expect(resultado.text, '12,34');
    });

    test('cursor sempre fica no fim do texto formatado', () {
      final resultado = digitar('12345');
      expect(resultado.selection.baseOffset, resultado.text.length);
      expect(resultado.selection.extentOffset, resultado.text.length);
    });

    test('apagar tudo (backspace até vazio) limpa o campo corretamente', () {
      final digitado = digitar('222');
      expect(digitado.text, '2,22');

      final apagado = formatador.formatEditUpdate(
        digitado,
        const TextEditingValue(text: ''),
      );
      expect(apagado.text, '');
    });

    test('colar um valor muito grande também respeita o limite de dígitos', () {
      final colado = formatador.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '999999999999'), // 12 dígitos
      );
      expect(colado.text, '9999,99');
    });

    test('valor máximo permitido é R\$ 9.999,99', () {
      final resultado = digitar('999999');
      expect(resultado.text, '9999,99');
    });
  });
}