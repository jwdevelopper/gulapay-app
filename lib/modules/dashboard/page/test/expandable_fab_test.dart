import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';

void main() {
  testWidgets('Dashboard expandable FAB navigates to the correct pages', (
    WidgetTester tester,
  ) async {
    final navigationCalls = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          onNavegarParaAba: navigationCalls.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    expect(navigationCalls, isEmpty);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(navigationCalls, [2]);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.category_outlined));
    await tester.pumpAndSettle();
    expect(navigationCalls, [2, 5]);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(navigationCalls, [2, 5, 4]);
  });
}
