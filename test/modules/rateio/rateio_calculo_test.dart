import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/rateio/util/rateio_calculo.dart';

void main() {
  group('dividirCentavos', () {
    test('divide exato quando não há resto', () {
      expect(dividirCentavos(1000, 4), [250, 250, 250, 250]);
    });

    test('joga o resto de centavos nas primeiras partes: 10,00 entre 3 = 3,34 + 3,33 + 3,33', () {
      expect(dividirCentavos(1000, 3), [334, 333, 333]);
    });

    test('a soma das partes sempre fecha com o total', () {
      for (var pessoas = 1; pessoas <= 9; pessoas++) {
        final partes = dividirCentavos(8750, pessoas);
        expect(partes.fold<int>(0, (a, b) => a + b), 8750,
            reason: 'falhou com $pessoas pessoas');
      }
    });

    test('devolve vazio para quantidade inválida', () {
      expect(dividirCentavos(500, 0), isEmpty);
    });
  });

  group('calcularRateioPorItem', () {
    test('soma as frações dos itens de cada consumidor', () {
      final totais = calcularRateioPorItem(
        subtotalCentavosPorItem: {900: 3000, 901: 500},
        consumidoresPorItem: {
          900: {1, 2},
          901: {1},
        },
        participantes: [1, 2],
      );

      expect(totais[1], 2000); // 1500 da pizza + 500 do refri
      expect(totais[2], 1500);
    });

    test('participante sem nenhum item marcado fica zerado', () {
      final totais = calcularRateioPorItem(
        subtotalCentavosPorItem: {900: 1000},
        consumidoresPorItem: {
          900: {1},
        },
        participantes: [1, 2],
      );

      expect(totais[2], 0);
    });

    test('ignora item sem consumidor sem estourar', () {
      final totais = calcularRateioPorItem(
        subtotalCentavosPorItem: {900: 1000, 901: 700},
        consumidoresPorItem: {
          900: {1},
          901: <int>{},
        },
        participantes: [1],
      );

      expect(totais[1], 1000);
    });

    test('o total distribuído fecha com a soma dos itens', () {
      final totais = calcularRateioPorItem(
        subtotalCentavosPorItem: {900: 1000, 901: 333, 902: 7},
        consumidoresPorItem: {
          900: {1, 2, 3},
          901: {2, 3},
          902: {1},
        },
        participantes: [1, 2, 3],
      );

      expect(totais.values.fold<int>(0, (a, b) => a + b), 1000 + 333 + 7);
    });
  });
}
