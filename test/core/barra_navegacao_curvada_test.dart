import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/widgets/barra_navegacao_curvada.dart';

void main() {
  Widget montar({
    required int quantidadeItens,
    required int indice,
    bool comAcao = false,
    ValueChanged<int>? aoTocar,
    VoidCallback? aoTocarAcao,
  }) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BarraNavegacaoCurvada(
          altura: 65,
          indice: indice,
          itens: [
            for (var i = 0; i < quantidadeItens; i++)
              Icon(Icons.circle, size: 30, key: ValueKey('item_$i')),
          ],
          acaoFinal: comAcao
              ? const Icon(Icons.add_rounded, key: ValueKey('acao'))
              : null,
          aoTocar: aoTocar,
          aoTocarAcaoFinal: aoTocarAcao,
        ),
      ),
    );
  }

  testWidgets('renderiza sem ação e sem erros de layout', (tester) async {
    await tester.pumpWidget(montar(quantidadeItens: 4, indice: 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('acao')), findsNothing);
  });

  testWidgets('renderiza com ação no canto e dispara o callback',
      (tester) async {
    var criacaoDisparada = false;
    await tester.pumpWidget(montar(
      quantidadeItens: 4,
      indice: 2,
      comAcao: true,
      aoTocarAcao: () => criacaoDisparada = true,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('acao')), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(criacaoDisparada, isTrue);
  });

  testWidgets('troca dinâmica da quantidade de slots não quebra a barra',
      (tester) async {
    // 4 itens sem ação (Início) → 4 itens com ação (Clientes centralizado)
    // → 5 itens com ação (página do drawer) → volta para 4 sem ação.
    await tester.pumpWidget(montar(quantidadeItens: 4, indice: 0));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      montar(quantidadeItens: 4, indice: 2, comAcao: true),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('acao')), findsOneWidget);

    await tester.pumpWidget(
      montar(quantidadeItens: 5, indice: 2, comAcao: true),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(montar(quantidadeItens: 4, indice: 3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('acao')), findsNothing);
  });

  testWidgets('toque em item anima a bolha e notifica o índice',
      (tester) async {
    int? tocado;
    await tester.pumpWidget(montar(
      quantidadeItens: 4,
      indice: 0,
      comAcao: true,
      aoTocar: (i) => tocado = i,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('item_3')),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tocado, 3);
  });
}
