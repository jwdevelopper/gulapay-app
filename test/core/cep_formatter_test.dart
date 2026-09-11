import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/cep_formatter.dart';

void main() {
  group('formatar', () {
    test('insere o hífen depois do quinto dígito', () {
      expect(CepFormatter.formatar('01310100'), '01310-100');
    });

    test('formata parcialmente enquanto se digita', () {
      expect(CepFormatter.formatar('013'), '013');
      expect(CepFormatter.formatar('01310'), '01310');
      expect(CepFormatter.formatar('013101'), '01310-1');
    });

    test('descarta o que passa de oito dígitos', () {
      expect(CepFormatter.formatar('0131010099'), '01310-100');
    });

    test('reformata um valor que já vem com hífen', () {
      expect(CepFormatter.formatar('01310-100'), '01310-100');
    });

    test('nulo e vazio viram string vazia', () {
      expect(CepFormatter.formatar(null), '');
      expect(CepFormatter.formatar(''), '');
    });
  });

  group('somenteDigitos', () {
    test('remove o hífen', () {
      expect(CepFormatter.somenteDigitos('01310-100'), '01310100');
    });

    test('ida e volta preserva o valor', () {
      final ida = CepFormatter.formatar('01310100');
      expect(CepFormatter.somenteDigitos(ida), '01310100');
    });
  });

  group('completo', () {
    test('exige os oito dígitos', () {
      expect(CepFormatter.completo('01310-100'), isTrue);
      expect(CepFormatter.completo('01310-10'), isFalse);
      expect(CepFormatter.completo(''), isFalse);
    });
  });

  group('digitação', () {
    const formatador = CepFormatter();

    TextEditingValue digitar(String texto) => formatador.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: texto),
    );

    test('aplica a máscara e leva o cursor ao fim', () {
      final valor = digitar('01310100');
      expect(valor.text, '01310-100');
      expect(valor.selection.extentOffset, valor.text.length);
    });

    test('ignora letras digitadas', () {
      expect(digitar('01a31b0100').text, '01310-100');
    });
  });
}
