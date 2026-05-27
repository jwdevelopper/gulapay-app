import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app_teste/main.dart';

void main() {
  testWidgets('App boots on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Logar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
