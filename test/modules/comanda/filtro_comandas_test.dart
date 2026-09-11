import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/comanda/dto/filtro_comandas.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';

void main() {
  group('FiltroComandas', () {
    test('nasce sem nenhum filtro', () {
      const f = FiltroComandas();
      expect(f.vazio, isTrue);
      expect(f.status, isNull);
      expect(f.tipoOrigem, isNull);
    });

    test('escolher um status preenche o filtro', () {
      final f = const FiltroComandas().alternarStatus('ABERTA');
      expect(f.status, 'ABERTA');
      expect(f.vazio, isFalse);
    });

    test('tocar no status já escolhido volta para todas', () {
      final f = const FiltroComandas(status: 'ABERTA').alternarStatus('ABERTA');
      expect(f.status, isNull);
    });

    test('alternarStatus(null) limpa o status', () {
      final f = const FiltroComandas(status: 'FECHADA').alternarStatus(null);
      expect(f.status, isNull);
    });

    test('trocar o status preserva o canal', () {
      final f = const FiltroComandas(
        status: 'ABERTA',
        tipoOrigem: 'MESA',
      ).alternarStatus('FECHADA');
      expect(f.status, 'FECHADA');
      expect(f.tipoOrigem, 'MESA');
    });

    test('trocar o canal preserva o status', () {
      final f = const FiltroComandas(
        status: 'ABERTA',
        tipoOrigem: 'MESA',
      ).alternarCanal('DELIVERY');
      expect(f.tipoOrigem, 'DELIVERY');
      expect(f.status, 'ABERTA');
    });

    test('tocar no canal já escolhido o desmarca', () {
      final f = const FiltroComandas(tipoOrigem: 'MESA').alternarCanal('MESA');
      expect(f.tipoOrigem, isNull);
      expect(f.vazio, isTrue);
    });

    test('só é vazio quando nenhum dos dois está preenchido', () {
      expect(const FiltroComandas(status: 'ABERTA').vazio, isFalse);
      expect(const FiltroComandas(tipoOrigem: 'MESA').vazio, isFalse);
    });
  });

  group('RotulosComanda.status', () {
    test('traduz os quatro status do backend', () {
      expect(RotulosComanda.status('ABERTA'), 'Aberta');
      expect(
        RotulosComanda.status('AGUARDANDO_PAGAMENTO'),
        'Aguardando pagamento',
      );
      expect(RotulosComanda.status('FECHADA'), 'Fechada');
      expect(RotulosComanda.status('CANCELADA'), 'Cancelada');
    });

    test('status desconhecido cai em texto legível', () {
      expect(RotulosComanda.status('EM_ANALISE'), 'EM ANALISE');
    });

    test('cobre todos os status oferecidos como filtro', () {
      for (final status in FiltroComandas.statusDisponiveis) {
        expect(RotulosComanda.status(status), isNot(contains('_')));
      }
    });

    test('cobre todos os canais oferecidos como filtro', () {
      for (final canal in FiltroComandas.canaisDisponiveis) {
        expect(RotulosComanda.origem(canal), isNot(canal));
      }
    });
  });
}
