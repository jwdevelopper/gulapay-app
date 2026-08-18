import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_list_filter.dart';

void main() {
  group('hasActiveFilter', () {
    test('é falso no estado inicial', () {
      expect(const InsumosFilters().hasActiveFilter, isFalse);
    });

    test('ignora nome composto só de espaços', () {
      expect(const InsumosFilters(nome: '   ').hasActiveFilter, isFalse);
    });

    test('é verdadeiro com nome preenchido', () {
      expect(const InsumosFilters(nome: 'tomate').hasActiveFilter, isTrue);
    });

    test('é verdadeiro com unidade selecionada', () {
      expect(const InsumosFilters(unidadePadraoId: 1).hasActiveFilter, isTrue);
    });

    test('é verdadeiro com abaixoDoMinimo definido', () {
      expect(const InsumosFilters(abaixoDoMinimo: true).hasActiveFilter, isTrue);
    });

    test('é verdadeiro com ativo == false (e não só com true)', () {
      expect(const InsumosFilters(ativo: false).hasActiveFilter, isTrue);
    });
  });

  group('copyWith', () {
    test('mantém os campos não informados', () {
      const base = InsumosFilters(nome: 'tomate', unidadePadraoId: 2);
      final novo = base.copyWith(ativo: true);

      expect(novo.nome, 'tomate');
      expect(novo.unidadePadraoId, 2);
      expect(novo.ativo, isTrue);
    });

    test('sobrescreve o campo informado', () {
      const base = InsumosFilters(unidadePadraoId: 2);
      expect(base.copyWith(unidadePadraoId: 5).unidadePadraoId, 5);
    });

    test('clearUnidadePadraoId zera a unidade', () {
      const base = InsumosFilters(unidadePadraoId: 2);
      expect(base.copyWith(clearUnidadePadraoId: true).unidadePadraoId, isNull);
    });

    test('clearUnidadePadraoId vence sobre o valor informado', () {
      const base = InsumosFilters(unidadePadraoId: 2);
      final novo = base.copyWith(
        unidadePadraoId: 9,
        clearUnidadePadraoId: true,
      );
      expect(novo.unidadePadraoId, isNull);
    });

    test('clearUnidade() é atalho equivalente', () {
      const base = InsumosFilters(nome: 'x', unidadePadraoId: 2);
      final novo = base.clearUnidade();

      expect(novo.unidadePadraoId, isNull);
      expect(novo.nome, 'x', reason: 'não pode derrubar os outros campos');
    });

    test('clearEstoqueMinimo e clearEstoqueAtual zeram seus campos', () {
      const base = InsumosFilters(estoqueAtual: 3, estoqueMinimo: 1);
      expect(base.copyWith(clearEstoqueAtual: true).estoqueAtual, isNull);
      expect(base.copyWith(clearEstoqueMinimo: true).estoqueMinimo, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // BUG CONHECIDO — ver REFACTOR_TESTABILIDADE.md, item 4.
  // `abaixoDoMinimo` e `ativo` não têm flag de limpeza. Como o copyWith usa
  // `valor ?? this.valor`, passar null preserva o valor antigo. Consequência
  // real: no bottom sheet de filtros, "Limpar" + "Aplicar" NÃO limpa nada.
  // ---------------------------------------------------------------------------
  group('limpeza de booleanos', () {
    test(
      'passar null em abaixoDoMinimo limpa o filtro',
      () {
        const base = InsumosFilters(abaixoDoMinimo: true);
        expect(base.copyWith(abaixoDoMinimo: null).abaixoDoMinimo, isNull);
      },
      skip: 'BUG: copyWith não distingue "não informado" de "limpar". '
          'Habilitar após adicionar clearAbaixoDoMinimo/clearAtivo.',
    );

    test(
      'passar null em ativo limpa o filtro',
      () {
        const base = InsumosFilters(ativo: true);
        expect(base.copyWith(ativo: null).ativo, isNull);
      },
      skip: 'BUG: mesmo problema de abaixoDoMinimo.',
    );
  });
}
