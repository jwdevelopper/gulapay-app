import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_chip.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_chips.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

import '../../helpers/insumo_fixtures.dart';
import '../../helpers/insumo_harness.dart';

void main() {
  Future<void> pumpChips(
    WidgetTester tester, {
    int? selecionada,
    VoidCallback? onClear,
    ValueChanged<UnidadeMedidaResponse>? onSelected,
    List<UnidadeMedidaResponse>? unidades,
  }) {
    return pumpPage(
      tester,
      Scaffold(
        body: UnidadesMedidasChips(
          unidadesMedidas: unidades ?? unidadesFixture(),
          selectedUnidadeMedidaId: selecionada,
          onClear: onClear ?? () {},
          onSelected: onSelected ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('sempre inclui o chip "Todos" antes das unidades',
      (tester) async {
    await pumpChips(tester);
    await tester.pump();

    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Quilograma'), findsOneWidget);
    expect(find.text('Litro'), findsOneWidget);
  });

  testWidgets('renderiza um chip por unidade recebida, mais o "Todos"',
      (tester) async {
    await pumpChips(tester);
    await tester.pump();

    expect(find.byType(UnidadeMedidaChip), findsNWidgets(4));
  });

  testWidgets('"Todos" fica selecionado quando não há unidade escolhida',
      (tester) async {
    await pumpChips(tester, selecionada: null);
    await tester.pump();

    final chip = tester.widget<UnidadeMedidaChip>(
      find.widgetWithText(UnidadeMedidaChip, 'Todos'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('a unidade escolhida fica selecionada e "Todos" não',
      (tester) async {
    await pumpChips(tester, selecionada: 2);
    await tester.pump();

    final litro = tester.widget<UnidadeMedidaChip>(
      find.widgetWithText(UnidadeMedidaChip, 'Litro'),
    );
    final todos = tester.widget<UnidadeMedidaChip>(
      find.widgetWithText(UnidadeMedidaChip, 'Todos'),
    );

    expect(litro.selected, isTrue);
    expect(todos.selected, isFalse);
  });

  testWidgets('tocar em uma unidade devolve o objeto correto', (tester) async {
    UnidadeMedidaResponse? recebida;
    await pumpChips(tester, onSelected: (u) => recebida = u);
    await tester.pump();

    await tester.tap(find.text('Litro'));
    await tester.pump();

    expect(recebida?.id, 2);
  });

  testWidgets('tocar em "Todos" dispara onClear', (tester) async {
    var limpou = false;
    await pumpChips(tester, selecionada: 1, onClear: () => limpou = true);
    await tester.pump();

    await tester.tap(find.text('Todos'));
    await tester.pump();

    expect(limpou, isTrue);
  });

  testWidgets('sobrevive a uma lista vazia de unidades', (tester) async {
    await pumpChips(tester, unidades: const []);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(UnidadeMedidaChip), findsOneWidget);
  });
}
