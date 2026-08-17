import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_sort_sheet.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_sort_options.dart';

void main() {
  /// Abre o sheet e devolve um getter para o valor retornado no pop.
  Future<String? Function()> abrirSheet(
    WidgetTester tester, {
    String selecionado = 'stock_asc',
  }) async {
    String? resultado;
    var fechou = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  resultado = await InsumoSortSheet.show(
                    context,
                    selectedSort: selecionado,
                  );
                  fechou = true;
                },
                child: const Text('__abrir__'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('__abrir__'));
    await tester.pumpAndSettle();

    return () => fechou ? resultado : null;
  }

  testWidgets('lista todas as opções de ordenação cadastradas', (tester) async {
    await abrirSheet(tester);

    for (final option in insumoSortOptions) {
      expect(
        find.text(option.label),
        findsOneWidget,
        reason: 'faltou a opção ${option.value}',
      );
    }
  });

  testWidgets('exibe o subtítulo explicativo de cada opção', (tester) async {
    await abrirSheet(tester);

    expect(find.text('Do menor para o maior'), findsOneWidget);
    expect(find.text('Agrupado por letra inicial'), findsOneWidget);
  });

  testWidgets('marca com check apenas a opção selecionada', (tester) async {
    await abrirSheet(tester, selecionado: 'name_asc');

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('retorna o value da opção tocada', (tester) async {
    final resultado = await abrirSheet(tester, selecionado: 'stock_asc');

    await tester.tap(find.text('Nome A-Z'));
    await tester.pumpAndSettle();

    expect(resultado(), 'name_asc');
  });

  testWidgets('fecha sem resultado ao tocar no X', (tester) async {
    final resultado = await abrirSheet(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(resultado(), isNull);
    expect(find.byType(InsumoSortSheet), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // BUG DE COPY — ver REFACTOR_TESTABILIDADE.md, item 5.
  // O título do sheet diz "Ordenar produtos" dentro do módulo de insumos
  // (resquício do componente que serviu de referência).
  // ---------------------------------------------------------------------------
  testWidgets(
    'o título fala de insumos, não de produtos',
    (tester) async {
      await abrirSheet(tester);
      expect(find.text('Ordenar insumos'), findsOneWidget);
    },
  );
}
