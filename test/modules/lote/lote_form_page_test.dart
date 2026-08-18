import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';

void main() {
  testWidgets('renderiza o formulário de novo lote sem erros', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoteFormPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoteFormPage), findsOneWidget);
    expect(find.text('Novo lote'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aciona o botão de confirmação do formulário sem quebrar a UI',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoteFormPage(),
      ),
    );
    await tester.pumpAndSettle();

    final botaoConfirmacao = find.byType(ElevatedButton).last;
    await tester.tap(botaoConfirmacao);
    await tester.pump();

    expect(find.byType(LoteFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
