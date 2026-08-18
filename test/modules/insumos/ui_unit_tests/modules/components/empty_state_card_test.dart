import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/empty_state_card.dart';

import '../../helpers/insumo_harness.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    bool secondary = false,
    VoidCallback? onPressed,
  }) {
    return pumpPage(
      tester,
      Scaffold(
        body: EmptyStateCard(
          title: 'Sem insumos por aqui',
          subtitle: 'Cadastre seu primeiro insumo.',
          icon: Icons.inventory_2_rounded,
          buttonLabel: 'Cadastrar insumo',
          onPressed: onPressed ?? () {},
          secondary: secondary,
        ),
      ),
    );
  }

  testWidgets('exibe título, subtítulo, ícone e rótulo do botão',
      (tester) async {
    await pumpCard(tester);
    await tester.pump();

    expect(find.text('Sem insumos por aqui'), findsOneWidget);
    expect(find.text('Cadastre seu primeiro insumo.'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    expect(find.text('Cadastrar insumo'), findsOneWidget);
  });

  testWidgets('usa botão primário por padrão', (tester) async {
    await pumpCard(tester);
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('usa botão secundário quando secondary é true', (tester) async {
    await pumpCard(tester, secondary: true);
    await tester.pump();

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('o botão dispara onPressed', (tester) async {
    var cliques = 0;
    await pumpCard(tester, onPressed: () => cliques++);
    await tester.pump();

    await tester.tap(find.text('Cadastrar insumo'));
    await tester.pump();

    expect(cliques, 1);
  });

  testWidgets('o botão secundário também dispara onPressed', (tester) async {
    var cliques = 0;
    await pumpCard(tester, secondary: true, onPressed: () => cliques++);
    await tester.pump();

    await tester.tap(find.text('Cadastrar insumo'));
    await tester.pump();

    expect(cliques, 1);
  });
}
