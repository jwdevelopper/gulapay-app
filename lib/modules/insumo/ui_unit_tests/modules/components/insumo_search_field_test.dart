import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_search_field.dart';

import '../../helpers/insumo_harness.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpField(
    WidgetTester tester, {
    String search = '',
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return pumpPage(
      tester,
      Scaffold(
        body: InsumoSearchField(
          controller: controller,
          search: search,
          onChanged: onChanged ?? (_) {},
          onClear: onClear ?? () {},
        ),
      ),
    );
  }

  testWidgets('exibe o placeholder do módulo de insumos', (tester) async {
    await pumpField(tester);
    await tester.pump();

    expect(find.text('Buscar insumo...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('propaga cada tecla digitada via onChanged', (tester) async {
    final digitado = <String>[];
    await pumpField(tester, onChanged: digitado.add);
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pump();

    expect(digitado.last, 'tom');
  });

  testWidgets('não mostra o botão limpar quando a busca está vazia',
      (tester) async {
    await pumpField(tester, search: '');
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('mostra o botão limpar quando há texto', (tester) async {
    await pumpField(tester, search: 'tomate');
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('botão limpar dispara onClear', (tester) async {
    var limpou = false;
    await pumpField(
      tester,
      search: 'tomate',
      onClear: () => limpou = true,
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(limpou, isTrue);
  });

  testWidgets('o campo reflete o texto do controller', (tester) async {
    controller.text = 'queijo';
    await pumpField(tester, search: 'queijo');
    await tester.pump();

    expect(find.text('queijo'), findsOneWidget);
  });
}
