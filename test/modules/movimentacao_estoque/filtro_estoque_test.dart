import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/filtro_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';

void main() {
  MovimentacaoEstoque mov({
    required String tipo,
    int insumoId = 1,
    String? data,
  }) => MovimentacaoEstoque(
    tipo: tipo,
    insumoId: insumoId,
    dataHora: data,
    quantidade: 1,
  );

  final compra = mov(tipo: 'ENTRADA_COMPRA', data: '2026-03-10T10:00:00');
  final perda = mov(tipo: 'SAIDA_PERDA_QUEBRA', data: '2026-03-11T10:00:00');
  final ajuste = mov(tipo: 'AJUSTE_INVENTARIO', data: '2026-03-12T10:00:00');
  final todas = [compra, perda, ajuste];

  group('filtro por tipo', () {
    test('TUDO não filtra nada', () {
      expect(const FiltroEstoque().aplicar(todas).length, 3);
    });

    test('ENTRADAS mantém só as entradas', () {
      final r = const FiltroEstoque(
        tipo: FiltroEstoque.entradas,
      ).aplicar(todas);
      expect(r.single.tipo, 'ENTRADA_COMPRA');
    });

    test('SAIDAS mantém só as saídas', () {
      final r = const FiltroEstoque(tipo: FiltroEstoque.saidas).aplicar(todas);
      expect(r.single.tipo, 'SAIDA_PERDA_QUEBRA');
    });

    test('AJUSTES mantém só os ajustes', () {
      final r = const FiltroEstoque(tipo: FiltroEstoque.ajustes).aplicar(todas);
      expect(r.single.tipo, 'AJUSTE_INVENTARIO');
    });
  });

  group('filtro por insumo', () {
    test('mantém apenas o insumo escolhido', () {
      final lista = [
        mov(tipo: 'ENTRADA_COMPRA', insumoId: 1, data: '2026-03-10T10:00:00'),
        mov(tipo: 'ENTRADA_COMPRA', insumoId: 2, data: '2026-03-10T11:00:00'),
      ];
      final r = const FiltroEstoque(insumoId: 2).aplicar(lista);
      expect(r.single.insumoId, 2);
    });
  });

  group('filtro por período', () {
    test('respeita o limite inicial', () {
      final r = FiltroEstoque(de: DateTime(2026, 3, 11)).aplicar(todas);
      expect(r.length, 2);
    });

    test('respeita o limite final', () {
      final r = FiltroEstoque(
        ate: DateTime(2026, 3, 11, 23, 59, 59),
      ).aplicar(todas);
      expect(r.length, 2);
    });

    test('combina os dois limites', () {
      final r = FiltroEstoque(
        de: DateTime(2026, 3, 11),
        ate: DateTime(2026, 3, 11, 23, 59, 59),
      ).aplicar(todas);
      expect(r.single.tipo, 'SAIDA_PERDA_QUEBRA');
    });

    test('descarta registros sem data quando há período', () {
      final semData = mov(tipo: 'ENTRADA_COMPRA');
      final r = FiltroEstoque(de: DateTime(2026, 1, 1)).aplicar([semData]);
      expect(r, isEmpty);
    });

    test('mantém registros sem data quando não há período', () {
      final semData = mov(tipo: 'ENTRADA_COMPRA');
      expect(const FiltroEstoque().aplicar([semData]).length, 1);
    });
  });

  test('ordena da movimentação mais recente para a mais antiga', () {
    final r = const FiltroEstoque().aplicar([compra, ajuste, perda]);
    expect(r.map((m) => m.tipo).toList(), [
      'AJUSTE_INVENTARIO',
      'SAIDA_PERDA_QUEBRA',
      'ENTRADA_COMPRA',
    ]);
  });

  group('estado do filtro', () {
    test('vazio quando nada foi escolhido', () {
      expect(const FiltroEstoque().vazio, isTrue);
      expect(const FiltroEstoque().temFiltroAvancado, isFalse);
    });

    test('só o tipo não conta como filtro avançado', () {
      const f = FiltroEstoque(tipo: FiltroEstoque.entradas);
      expect(f.temFiltroAvancado, isFalse);
      expect(f.vazio, isFalse);
    });

    test('insumo e período contam como avançado', () {
      expect(const FiltroEstoque(insumoId: 1).temFiltroAvancado, isTrue);
      expect(FiltroEstoque(de: DateTime(2026)).temFiltroAvancado, isTrue);
    });
  });

  group('copiarCom', () {
    test('preserva os campos não informados', () {
      final f = FiltroEstoque(
        tipo: FiltroEstoque.entradas,
        insumoId: 5,
        de: DateTime(2026, 1, 1),
      );
      final novo = f.copiarCom(tipo: FiltroEstoque.saidas);
      expect(novo.tipo, FiltroEstoque.saidas);
      expect(novo.insumoId, 5);
      expect(novo.de, DateTime(2026, 1, 1));
    });

    test('as flags de limpar zeram o campo', () {
      const f = FiltroEstoque(insumoId: 5);
      expect(f.copiarCom(limparInsumo: true).insumoId, isNull);
    });
  });
}
