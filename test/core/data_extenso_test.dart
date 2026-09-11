import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/data_extenso.dart';

void main() {
  String iso(DateTime d) => d.toIso8601String();

  group('cabecalho', () {
    test('devolve HOJE para a data corrente', () {
      expect(DataExtenso.cabecalho(iso(DateTime.now())), 'HOJE');
    });

    test('devolve ONTEM para o dia anterior', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      expect(DataExtenso.cabecalho(iso(ontem)), 'ONTEM');
    });

    test('omite o ano dentro do ano corrente', () {
      final agora = DateTime.now();
      // Uma data do ano corrente distante de hoje, para não cair em
      // HOJE/ONTEM: usa o mês oposto ao atual.
      final mes = agora.month > 6 ? 1 : 12;
      final data = DateTime(agora.year, mes, 15);
      expect(
        DataExtenso.cabecalho(iso(data)),
        '15 ${mes == 1 ? 'JAN' : 'DEZ'}',
      );
    });

    test('inclui o ano em datas de anos anteriores', () {
      expect(DataExtenso.cabecalho('2020-03-12T10:00:00'), '12 MAR 2020');
    });

    test('devolve vazio para null e para texto inválido', () {
      expect(DataExtenso.cabecalho(null), '');
      expect(DataExtenso.cabecalho('nao é data'), '');
    });
  });

  group('hora', () {
    test('formata com dois dígitos', () {
      expect(DataExtenso.hora('2026-03-12T09:05:00'), '09:05');
      expect(DataExtenso.hora('2026-03-12T23:59:00'), '23:59');
    });

    test('devolve vazio para entrada inválida', () {
      expect(DataExtenso.hora(null), '');
      expect(DataExtenso.hora('x'), '');
    });
  });

  group('chaveDoDia', () {
    test('usa aaaa-mm-dd com zero à esquerda', () {
      expect(DataExtenso.chaveDoDia('2026-03-05T23:00:00'), '2026-03-05');
    });

    test('horários diferentes do mesmo dia geram a mesma chave', () {
      expect(
        DataExtenso.chaveDoDia('2026-03-05T01:00:00'),
        DataExtenso.chaveDoDia('2026-03-05T22:00:00'),
      );
    });
  });

  group('curta', () {
    test('formata dd/mm/aaaa', () {
      expect(DataExtenso.curta(DateTime(2026, 3, 5)), '05/03/2026');
    });

    test('usa o padrão quando a data é nula', () {
      expect(DataExtenso.curta(null), 'Selecionar');
      expect(DataExtenso.curta(null, sePadrao: '—'), '—');
    });
  });
}
