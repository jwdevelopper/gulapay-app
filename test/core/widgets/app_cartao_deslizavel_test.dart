import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel.dart';

void main() {
  Widget criarCenario({required Future<bool> Function() aoExcluir}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 92,
            child: AppCartaoDeslizavel(
              chave: 'item_1',
              aoConfirmarAcao: aoExcluir,
              child: const ColoredBox(
                color: Colors.white,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra apenas o icone enquanto a abertura ainda e curta', (
    tester,
  ) async {
    await tester.pumpWidget(criarCenario(aoExcluir: () async => false));

    final gesto = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('item_1'))),
    );
    await gesto.moveBy(const Offset(-80, 0));
    await tester.pump();

    expect(find.text('Excluir'), findsNothing);
    expect(find.byType(FaIcon), findsOneWidget);

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets('mostra rotulo e icone somente quando ha espaco para ambos', (
    tester,
  ) async {
    await tester.pumpWidget(criarCenario(aoExcluir: () async => false));

    final gesto = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('item_1'))),
    );
    await gesto.moveBy(const Offset(-150, 0));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Excluir'), findsOneWidget);
    expect(find.byType(FaIcon), findsOneWidget);

    await gesto.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'mantem um painel vermelho completo por baixo do card principal',
    (tester) async {
      await tester.pumpWidget(criarCenario(aoExcluir: () async => false));

      final painel = find.byKey(const ValueKey('app_cartao_painel_item_1'));
      expect(tester.getSize(painel), const Size(320, 92));

      final gesto = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('item_1'))),
      );
      await gesto.moveBy(const Offset(-80, 0));
      await tester.pump();

      final primeiroPlano = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('app_cartao_primeiro_plano_item_1')),
      );
      final decoracao = primeiroPlano.decoration as BoxDecoration;

      expect(tester.getSize(painel), const Size(320, 92));
      expect(
        tester.getSize(
          find.byKey(const ValueKey('app_cartao_primeiro_plano_item_1')),
        ),
        const Size(320, 92),
      );
      expect(decoracao.boxShadow!.single.color.a, greaterThan(0));

      await gesto.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('mantem o card quando a exclusao e cancelada', (tester) async {
    var chamadas = 0;
    await tester.pumpWidget(
      criarCenario(
        aoExcluir: () async {
          chamadas++;
          return false;
        },
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('item_1')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    expect(chamadas, 1);
    expect(find.byKey(const ValueKey('item_1')), findsOneWidget);
  });
}
