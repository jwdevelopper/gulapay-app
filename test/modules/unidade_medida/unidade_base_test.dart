import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_base.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/validacao_unidade.dart';

void main() {
  group('catálogo de atalhos', () {
    test('cobre as seis unidades semeadas pelo backend', () {
      expect(unidadesBase.map((u) => u.simbolo).toList(), [
        'g',
        'kg',
        'mL',
        'L',
        'un',
        'dz',
      ]);
    });

    test('há exatamente uma base por tipo de medida', () {
      for (final tipo in ['MASSA', 'VOLUME', 'UNIDADE']) {
        final bases = unidadesBase.where(
          (u) => u.tipoMedida == tipo && u.ehBase,
        );
        expect(bases.length, 1, reason: tipo);
      }
    });

    test('os fatores batem com a documentação', () {
      Map<String, double> fatores = {
        for (final u in unidadesBase) u.simbolo: u.fatorParaBase,
      };
      expect(fatores['g'], 1);
      expect(fatores['kg'], 1000);
      expect(fatores['mL'], 1);
      expect(fatores['L'], 1000);
      expect(fatores['un'], 1);
      expect(fatores['dz'], 12);
    });
  });

  group('baseCorrespondente', () {
    test('encontra pelo símbolo', () {
      expect(baseCorrespondente('kg')?.nome, 'Quilograma');
    });

    test('não diferencia maiúsculas', () {
      expect(baseCorrespondente('ML')?.nome, 'Mililitro');
    });

    test('símbolo próprio não corresponde a atalho nenhum', () {
      expect(baseCorrespondente('cx'), isNull);
      expect(baseCorrespondente(''), isNull);
      expect(baseCorrespondente(null), isNull);
    });
  });

  group('aplicarEm', () {
    test('preenche os quatro campos de uma vez', () {
      final kg = baseCorrespondente('kg')!;
      final dados = kg.aplicarEm(const DadosUnidade());
      expect(dados.nome, 'Quilograma');
      expect(dados.simbolo, 'kg');
      expect(dados.tipoMedida, 'MASSA');
      expect(dados.fatorParaBase, '1000');
    });

    test('o resultado passa na validação de criação', () {
      for (final base in unidadesBase) {
        final dados = base.aplicarEm(const DadosUnidade());
        expect(
          ValidadorUnidade.validar(dados, ehEdicao: false),
          isNull,
          reason: base.simbolo,
        );
      }
    });

    test('o fator aplicado é lido de volta como número', () {
      final dz = baseCorrespondente('dz')!;
      expect(dz.aplicarEm(const DadosUnidade()).fatorNumero, 12);
    });

    test('preserva o ativo do registro em edição', () {
      final kg = baseCorrespondente('kg')!;
      final dados = kg.aplicarEm(const DadosUnidade(ativo: false));
      expect(dados.ativo, isFalse);
    });
  });
}
