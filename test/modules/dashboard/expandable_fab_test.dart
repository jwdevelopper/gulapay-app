import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';

void main() {
  testWidgets('os atalhos do painel abrem as abas certas', (tester) async {
    final abertas = <String>[];

    await tester.pumpWidget(
      MaterialApp(home: DashboardPage(aoAbrirAba: abertas.add)),
    );
    await tester.pumpAndSettle();

    // O leque começa fechado: nenhum atalho dispara sozinho.
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(abertas, isEmpty);

    Future<void> tocarNoAtalho(IconData icone) async {
      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(icone));
      await tester.pumpAndSettle();
    }

    await tocarNoAtalho(Icons.shopping_bag_outlined);
    expect(abertas, [TitulosAba.produtos]);

    await tocarNoAtalho(Icons.category_outlined);
    expect(abertas, [TitulosAba.produtos, TitulosAba.categorias]);

    await tocarNoAtalho(Icons.inventory_2_outlined);
    expect(abertas, [
      TitulosAba.produtos,
      TitulosAba.categorias,
      TitulosAba.estoque,
    ]);
  });

  test('indiceDaAba encontra pelo título e avisa quando não existe', () {
    final abas = construirAbas(aoAbrirAba: (_) {});
    expect(
      abas[indiceDaAba(abas, TitulosAba.produtos)].tituloAppBar,
      TitulosAba.produtos,
    );
    expect(
      abas[indiceDaAba(abas, TitulosAba.estoque)].tituloAppBar,
      TitulosAba.estoque,
    );
    expect(indiceDaAba(abas, 'Inexistente'), -1);
  });
}
