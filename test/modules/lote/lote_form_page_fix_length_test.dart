import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';

void main() {
  testWidgets('feature FixLength e Caracteres_Fix validam a quantidade',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoteFormPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final campoQuantidade = find.byType(TextFormField).at(1);
    await tester.enterText(campoQuantidade, '12a3456789012');

    final campoEditavel = find.descendant(
      of: campoQuantidade,
      matching: find.byType(EditableText),
    );
    final textField = tester.widget<EditableText>(campoEditavel);

    expect(textField.controller.text, '12345678901');
    expect(textField.controller.text.length, 11);
    expect(textField.controller.text, isNot(contains('a')));
  });
}
