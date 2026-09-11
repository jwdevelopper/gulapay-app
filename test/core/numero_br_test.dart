import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';

void main() {
  group('parseNumeroBr', () {
    test('lê vírgula como separador decimal', () {
      expect(parseNumeroBr('7,40'), 7.4);
      expect(parseNumeroBr('0,5'), 0.5);
    });

    test('trata o ponto como separador de milhar', () {
      expect(parseNumeroBr('1.234,56'), 1234.56);
      expect(parseNumeroBr('1.000'), 1000);
    });

    test('aceita inteiro sem separador', () {
      expect(parseNumeroBr('12'), 12.0);
    });

    test('ignora espaços em volta', () {
      expect(parseNumeroBr('  3,5  '), 3.5);
    });

    test('devolve null para vazio, nulo e texto', () {
      expect(parseNumeroBr(''), isNull);
      expect(parseNumeroBr('   '), isNull);
      expect(parseNumeroBr(null), isNull);
      expect(parseNumeroBr('abc'), isNull);
    });
  });

  group('formatarNumeroBr', () {
    test('usa duas casas por padrão', () {
      expect(formatarNumeroBr(7.4), '7,40');
      expect(formatarNumeroBr(12), '12,00');
    });

    test('casas: null remove os zeros à direita', () {
      expect(formatarNumeroBr(5, casas: null), '5');
      expect(formatarNumeroBr(2.5, casas: null), '2,5');
    });

    test('null vira o texto de vazio', () {
      expect(formatarNumeroBr(null), '—');
      expect(formatarNumeroBr(null, vazio: '0'), '0');
    });

    test('ida e volta preserva o valor', () {
      expect(parseNumeroBr(formatarNumeroBr(1234.56)), 1234.56);
    });
  });

  group('formatarMoedaBr', () {
    test('prefixa com o símbolo do real', () {
      expect(formatarMoedaBr(7.4), r'R$ 7,40');
    });

    test('null vira o texto de vazio', () {
      expect(formatarMoedaBr(null), '—');
    });
  });
}
