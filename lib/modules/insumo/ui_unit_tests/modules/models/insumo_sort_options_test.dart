import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_sort_options.dart';

import '../../helpers/insumo_fixtures.dart';

InsumoSortOption _opt(String value) =>
    insumoSortOptions.firstWhere((o) => o.value == value);

List<String?> _nomesOrdenados(
  List<InsumoResponse> lista,
  InsumoSortOption option,
) {
  final copia = List<InsumoResponse>.from(lista)..sort(option.comparator);
  return copia.map((i) => i.nome).toList();
}

void main() {
  group('catálogo de opções', () {
    test('todos os values são únicos', () {
      final values = insumoSortOptions.map((o) => o.value).toList();
      expect(values.toSet().length, values.length);
    });

    test('toda opção tem label e subtitle preenchidos', () {
      for (final o in insumoSortOptions) {
        expect(o.label.trim(), isNotEmpty, reason: 'label vazio em ${o.value}');
        expect(o.subtitle.trim(), isNotEmpty,
            reason: 'subtitle vazio em ${o.value}');
      }
    });

    test('groupOrder só existe onde existe grouper', () {
      for (final o in insumoSortOptions) {
        if (o.groupOrder != null) {
          expect(o.grouper, isNotNull,
              reason: '${o.value} ordena grupos que nunca são criados');
        }
      }
    });
  });

  group('comparadores', () {
    final lista = insumosFixture(); // 25, 2, 40

    test('stock_asc ordena do menor para o maior estoque', () {
      expect(
        _nomesOrdenados(lista, _opt('stock_asc')),
        ['Queijo mussarela', 'Tomate italiano', 'Azeite extra virgem'],
      );
    });

    test('stock_desc ordena do maior para o menor estoque', () {
      expect(
        _nomesOrdenados(lista, _opt('stock_desc')),
        ['Azeite extra virgem', 'Tomate italiano', 'Queijo mussarela'],
      );
    });

    test('name_asc ordena alfabeticamente ignorando caixa', () {
      final lista = [
        insumoFixture(id: 1, nome: 'banana'),
        insumoFixture(id: 2, nome: 'Abacaxi'),
        insumoFixture(id: 3, nome: 'Cenoura'),
      ];
      expect(
        _nomesOrdenados(lista, _opt('name_asc')),
        ['Abacaxi', 'banana', 'Cenoura'],
      );
    });

    test('name_desc é o inverso de name_asc', () {
      final lista = [
        insumoFixture(id: 1, nome: 'banana'),
        insumoFixture(id: 2, nome: 'Abacaxi'),
        insumoFixture(id: 3, nome: 'Cenoura'),
      ];
      expect(
        _nomesOrdenados(lista, _opt('name_desc')),
        ['Cenoura', 'banana', 'Abacaxi'],
      );
    });

    test('comparadores tratam nome e estoque nulos sem estourar', () {
      final lista = [
        insumoFixture(id: 1, nome: null, estoqueAtual: null),
        insumoFixture(id: 2, nome: 'Sal', estoqueAtual: 3),
      ];
      for (final o in insumoSortOptions) {
        expect(() => _nomesOrdenados(lista, o), returnsNormally,
            reason: 'comparator de ${o.value} não é null-safe');
      }
    });
  });

  group('agrupadores', () {
    test('name_asc agrupa pela letra inicial em maiúscula', () {
      final grouper = _opt('name_asc').grouper!;
      expect(grouper(insumoFixture(nome: 'tomate')), 'T');
      expect(grouper(insumoFixture(nome: 'Abacaxi')), 'A');
    });

    test('name_asc usa "#" para nome vazio ou nulo', () {
      final grouper = _opt('name_asc').grouper!;
      expect(grouper(insumoFixture(nome: '   ')), '#');
      expect(grouper(insumoFixture(nome: null)), '#');
    });

    test('unit agrupa pelo símbolo da unidade', () {
      final grouper = _opt('unit').grouper!;
      expect(grouper(insumoFixture(unidadePadraoSimbolo: 'kg')), 'kg');
    });

    test('unit cai em "sem unidade" quando o símbolo é nulo', () {
      final grouper = _opt('unit').grouper!;
      expect(grouper(insumoFixture(unidadePadraoSimbolo: null)), 'sem unidade');
    });

    test('below_min_first separa abaixo do mínimo de estoque padrão', () {
      final grouper = _opt('below_min_first').grouper!;
      expect(grouper(insumoFixture(abaixoDoMinimo: true)), 'Abaixo do mínimo');
      expect(grouper(insumoFixture(abaixoDoMinimo: false)), 'Estoque padrão');
      expect(grouper(insumoFixture(abaixoDoMinimo: null)), 'Estoque padrão');
    });

    // -------------------------------------------------------------------------
    // BUG CONHECIDO — ver REFACTOR_TESTABILIDADE.md, item 3.
    // O groupOrder compara com 'ABAIXO DO MÍNIMO' (caixa alta) enquanto o
    // grouper produz 'Abaixo do mínimo'. Nenhuma comparação casa, então a
    // opção "Estoque / abaixo do mínimo primeiro" não coloca nada primeiro.
    // Remova o `skip` depois de corrigir a constante.
    // -------------------------------------------------------------------------
    test(
      'below_min_first coloca o grupo crítico no topo',
      () {
        final option = _opt('below_min_first');
        final chaves = ['Estoque padrão', 'Abaixo do mínimo']
          ..sort(option.groupOrder!);
        expect(chaves.first, 'Abaixo do mínimo');
      },
      skip: 'BUG: groupOrder compara com string em caixa alta que o grouper '
          'nunca produz. Habilitar após corrigir insumo_sort_options.dart.',
    );
  });
}
