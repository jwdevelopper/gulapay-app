import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/texto_br.dart';

void main() {
  group('normalizarTexto', () {
    test('remove acentos e baixa a caixa', () {
      expect(normalizarTexto('Água'), 'agua');
      expect(normalizarTexto('AÇÚCAR'), 'acucar');
      expect(normalizarTexto('Pão de Ló'), 'pao de lo');
    });

    test('texto sem acento passa intacto', () {
      expect(normalizarTexto('pizza'), 'pizza');
    });

    test('nulo e vazio viram string vazia', () {
      expect(normalizarTexto(null), '');
      expect(normalizarTexto(''), '');
    });
  });

  group('compararTextoBr', () {
    test('acento não joga a palavra para o fim', () {
      final nomes = ['Zebra', 'Água', 'Bolo']
        ..sort((a, b) => compararTextoBr(a, b));
      expect(nomes, ['Água', 'Bolo', 'Zebra']);
    });

    test('compareTo cru erraria essa ordem', () {
      final nomes = ['Zebra', 'Água', 'Bolo']..sort();
      expect(nomes.first, 'Bolo');
      expect(nomes.last, 'Água');
    });

    test('ignora maiúsculas', () {
      expect(compararTextoBr('agua', 'ÁGUA'), 0);
    });
  });

  group('contemTextoBr', () {
    test('encontra ignorando acento', () {
      expect(contemTextoBr('Açúcar cristal', 'acucar'), isTrue);
      expect(contemTextoBr('Açúcar cristal', 'AÇÚCAR'), isTrue);
    });

    test('termo em branco não recorta', () {
      expect(contemTextoBr('qualquer', ''), isTrue);
      expect(contemTextoBr('qualquer', '   '), isTrue);
      expect(contemTextoBr('qualquer', null), isTrue);
    });

    test('não encontra o que não está lá', () {
      expect(contemTextoBr('Pizza', 'lasanha'), isFalse);
    });

    test('texto nulo não encontra nada', () {
      expect(contemTextoBr(null, 'x'), isFalse);
    });
  });
}
