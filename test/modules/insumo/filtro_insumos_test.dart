import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/dto/cabecalho_secao.dart';
import 'package:my_app_teste/modules/insumo/dto/filtro_insumos.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

void main() {
  InsumoResponse insumo({
    required String nome,
    double estoque = 10,
    bool abaixo = false,
    String unidade = 'kg',
  }) => InsumoResponse(
    id: nome.hashCode,
    nome: nome,
    estoqueAtual: estoque,
    abaixoDoMinimo: abaixo,
    unidadePadraoSimbolo: unidade,
  );

  final tomate = insumo(nome: 'Tomate', estoque: 5, abaixo: true);
  final acucar = insumo(nome: 'Açúcar', estoque: 30, unidade: 'kg');
  final leite = insumo(nome: 'Leite', estoque: 12, unidade: 'L');
  final todos = [tomate, acucar, leite];

  group('busca', () {
    test('encontra ignorando acento', () {
      final r = const FiltroInsumos(texto: 'acucar').aplicar(todos);
      expect(r.single.nome, 'Açúcar');
    });

    test('termo em branco não recorta', () {
      expect(const FiltroInsumos(texto: '  ').aplicar(todos).length, 3);
    });

    test('vazio reflete só a busca', () {
      expect(const FiltroInsumos().vazio, isTrue);
      expect(const FiltroInsumos(texto: 'x').vazio, isFalse);
      expect(
        const FiltroInsumos(ordenacao: OrdenacaoInsumo.unidade).vazio,
        isTrue,
      );
    });
  });

  group('ordenação', () {
    test('estoque crescente', () {
      final r = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.estoqueCrescente,
      ).aplicar(todos);
      expect(r.map((i) => i.nome), ['Tomate', 'Leite', 'Açúcar']);
    });

    test('estoque decrescente', () {
      final r = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.estoqueDecrescente,
      ).aplicar(todos);
      expect(r.map((i) => i.nome), ['Açúcar', 'Leite', 'Tomate']);
    });

    test('nome A-Z respeita acento', () {
      final r = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.nomeCrescente,
      ).aplicar(todos);
      expect(r.map((i) => i.nome), ['Açúcar', 'Leite', 'Tomate']);
    });

    test('nome Z-A', () {
      final r = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.nomeDecrescente,
      ).aplicar(todos);
      expect(r.map((i) => i.nome), ['Tomate', 'Leite', 'Açúcar']);
    });

    test('não altera a lista recebida', () {
      final original = [tomate, acucar, leite];
      const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.nomeCrescente,
      ).aplicar(original);
      expect(original.map((i) => i.nome), ['Tomate', 'Açúcar', 'Leite']);
    });
  });

  group('agrupamento', () {
    test('sem agrupar devolve só os insumos', () {
      final itens = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.estoqueCrescente,
      ).agrupar(todos);
      expect(itens.whereType<CabecalhoSecao>(), isEmpty);
      expect(itens.length, 3);
    });

    test('alerta põe "Abaixo do mínimo" primeiro', () {
      final itens = const FiltroInsumos().agrupar(todos);
      final cabecalhos = itens.whereType<CabecalhoSecao>().toList();
      expect(cabecalhos.first.rotulo, 'Abaixo do mínimo');
      expect(cabecalhos.first.quantidade, 1);
      expect(cabecalhos.last.rotulo, 'Estoque padrão');
      expect(cabecalhos.last.quantidade, 2);
      expect(itens.first, isA<CabecalhoSecao>());
      expect((itens[1] as InsumoResponse).nome, 'Tomate');
    });

    test('alerta sem nenhum abaixo do mínimo tem uma seção só', () {
      final itens = const FiltroInsumos().agrupar([acucar, leite]);
      final cabecalhos = itens.whereType<CabecalhoSecao>().toList();
      expect(cabecalhos.single.rotulo, 'Estoque padrão');
    });

    test('A-Z agrupa por letra inicial, em ordem', () {
      final itens = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.nomeCrescente,
      ).agrupar(todos);
      final letras = itens
          .whereType<CabecalhoSecao>()
          .map((c) => c.rotulo)
          .toList();
      expect(letras, ['A', 'L', 'T']);
    });

    test('unidade agrupa pelo símbolo', () {
      final itens = const FiltroInsumos(
        ordenacao: OrdenacaoInsumo.unidade,
      ).agrupar(todos);
      final secoes = itens
          .whereType<CabecalhoSecao>()
          .map((c) => '${c.rotulo}:${c.quantidade}')
          .toList();
      expect(secoes, ['kg:2', 'L:1']);
    });

    test('o agrupamento respeita a busca', () {
      final itens = const FiltroInsumos(texto: 'tomate').agrupar(todos);
      expect(itens.whereType<InsumoResponse>().single.nome, 'Tomate');
      expect(itens.whereType<CabecalhoSecao>().single.quantidade, 1);
    });
  });
}
