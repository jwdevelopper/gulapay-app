import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/lote/dto/filtro_lotes.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';

void main() {
  /// Data ISO a [dias] de hoje. Negativo = já venceu.
  String emDias(int dias) {
    final data = DateTime.now().add(Duration(days: dias));
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '${data.year}-$mes-$dia';
  }

  LoteResponse lote({String? codigo, String? insumo, required int dias}) =>
      LoteResponse(codigo: codigo, insumoNome: insumo, validade: emDias(dias));

  final vencido = lote(codigo: 'L001', insumo: 'Tomate', dias: -3);
  final semana = lote(codigo: 'L002', insumo: 'Alface', dias: 3);
  final mes = lote(codigo: 'L003', insumo: 'Arroz', dias: 20);
  final longe = lote(codigo: 'L004', insumo: 'Sal', dias: 200);
  final todos = [vencido, semana, mes, longe];

  group('janela de validade', () {
    test('todos não recorta nada', () {
      expect(const FiltroLotes().aplicar(todos).length, 4);
    });

    test('vencidos mantém só o que passou da validade', () {
      final r = const FiltroLotes(
        janela: JanelaValidade.vencidos,
      ).aplicar(todos);
      expect(r.single.codigo, 'L001');
    });

    test('7 dias mantém só a semana', () {
      final r = const FiltroLotes(
        janela: JanelaValidade.ate7Dias,
      ).aplicar(todos);
      expect(r.single.codigo, 'L002');
    });

    test('30 dias engloba a janela de 7', () {
      final r = const FiltroLotes(
        janela: JanelaValidade.ate30Dias,
      ).aplicar(todos);
      expect(r.map((l) => l.codigo), ['L002', 'L003']);
    });
  });

  group('busca por texto', () {
    test('confere o código', () {
      expect(
        const FiltroLotes(texto: 'L003').aplicar(todos).single.codigo,
        'L003',
      );
    });

    test('confere o nome do insumo, sem diferenciar maiúsculas', () {
      expect(
        const FiltroLotes(texto: 'tomate').aplicar(todos).single.codigo,
        'L001',
      );
    });

    test('termo em branco não recorta', () {
      expect(const FiltroLotes(texto: '   ').aplicar(todos).length, 4);
    });

    test('combina com a janela', () {
      final r = const FiltroLotes(
        texto: 'alface',
        janela: JanelaValidade.vencidos,
      ).aplicar(todos);
      expect(r, isEmpty);
    });
  });

  test('preserva a ordem FEFO recebida do backend', () {
    final r = const FiltroLotes().aplicar(todos);
    expect(r.map((l) => l.codigo), ['L001', 'L002', 'L003', 'L004']);
  });

  group('contar', () {
    test('conta por janela sem depender do filtro em vigor', () {
      const filtro = FiltroLotes(janela: JanelaValidade.vencidos);
      expect(filtro.contar(todos, JanelaValidade.vencidos), 1);
      expect(filtro.contar(todos, JanelaValidade.ate7Dias), 1);
      expect(filtro.contar(todos, JanelaValidade.todos), 4);
    });
  });

  group('estado', () {
    test('vazio quando nada foi escolhido', () {
      expect(const FiltroLotes().vazio, isTrue);
      expect(const FiltroLotes(texto: 'x').vazio, isFalse);
      expect(const FiltroLotes(janela: JanelaValidade.vencidos).vazio, isFalse);
    });

    test('copiarCom preserva o campo não informado', () {
      const f = FiltroLotes(texto: 'abc', janela: JanelaValidade.ate7Dias);
      expect(f.copiarCom(texto: 'xyz').janela, JanelaValidade.ate7Dias);
      expect(f.copiarCom(janela: JanelaValidade.todos).texto, 'abc');
    });
  });
}
