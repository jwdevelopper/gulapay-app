import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('bloqueia mesa duplicada e pessoas acima da capacidade', () async {
    final controller = FloorPlanController();
    await controller.load();

    await controller.saveTable(
      TableDraft(
        code: 'Mesa 01',
        areaId: 'salao',
        shape: TableShape.rectangular,
        chairsCount: 4,
        width: 112,
        height: 84,
      ),
    );

    expect(
      controller.lastActionError,
      'Ja existe uma mesa com esse codigo nessa area.',
    );

    await controller.saveTable(
      TableDraft(
        code: 'Mesa 99',
        areaId: 'salao',
        shape: TableShape.rectangular,
        chairsCount: 2,
        width: 112,
        height: 84,
        seatedPeople: 3,
      ),
    );

    expect(
      controller.lastActionError,
      'Pessoas sentadas nao podem ultrapassar a capacidade da mesa.',
    );
    expect(
      controller
          .areaById('salao')!
          .tables
          .any((table) => table.code == 'Mesa 99'),
      isFalse,
    );

    controller.dispose();
  });

  test('sugere uniao quando mesas ficam proximas no mapa', () async {
    final controller = FloorPlanController();
    await controller.load();

    controller.beginMove('m3');
    await controller.moveTable(
      'm3',
      const Offset(-78, -162),
      const Size(920, 640),
    );

    expect(controller.suggestedJoinTargetId, 'm2');
    expect(controller.suggestedJoinSourceId, 'm3');

    controller.dispose();
  });

  test('move mesa com delta pequeno sem travar no snap da grade', () async {
    final controller = FloorPlanController();
    await controller.load();

    final before = controller.findTableById('m3')!;
    controller.beginMove('m3');
    await controller.moveTable(
      'm3',
      const Offset(2.5, 1.5),
      const Size(920, 640),
    );
    final duringMove = controller.findTableById('m3')!;

    expect(duringMove.x, closeTo(before.x + 2.5, 0.01));
    expect(duringMove.y, closeTo(before.y + 1.5, 0.01));

    await controller.finishMove();
    final afterDrop = controller.findTableById('m3')!;

    expect(afterDrop.x % 12, 0);
    expect(afterDrop.y % 12, 0);

    controller.dispose();
  });

  test('une mesas sugeridas direto pelo mapa de edicao', () async {
    final controller = FloorPlanController();
    await controller.load();

    controller.beginMove('m3');
    await controller.moveTable(
      'm3',
      const Offset(-78, -162),
      const Size(920, 640),
    );

    final error = await controller.joinSuggestedTables();

    expect(error, isNull);
    expect(controller.findTableById('m2')!.isJoined, isTrue);
    expect(controller.findTableById('m3')!.isJoined, isTrue);
    expect(controller.areaById('salao')!.joinGroups, hasLength(1));

    controller.dispose();
  });

  test('bloqueia uniao de mesas com comandas ativas diferentes', () async {
    final controller = FloorPlanController();
    await controller.load();

    final result = await controller.openOrderForTable('m2');
    expect(result, isNotNull);
    expect(
      controller.joinableTablesFor('m1').map((table) => table.id),
      isNot(contains('m2')),
    );

    final error = await controller.joinTables(
      sourceTableId: 'm1',
      targetTableId: 'm2',
    );

    expect(
      error,
      'As mesas possuem pedidos diferentes e nao podem ser unidas agora.',
    );

    controller.dispose();
  });

  test(
    'bloqueia mover ou esvaziar mesa com comanda ativa pela edicao',
    () async {
      final controller = FloorPlanController();
      await controller.load();

      await controller.saveTable(
        TableDraft(
          id: 'm1',
          code: 'Mesa 01',
          areaId: 'varanda',
          shape: TableShape.rectangular,
          chairsCount: 6,
          width: 116,
          height: 86,
          seatedPeople: 4,
        ),
      );

      expect(
        controller.lastActionError,
        'Encerre a comanda antes de mover a mesa para outra area.',
      );

      await controller.saveTable(
        TableDraft(
          id: 'm1',
          code: 'Mesa 01',
          areaId: 'salao',
          shape: TableShape.rectangular,
          chairsCount: 6,
          width: 116,
          height: 86,
        ),
      );

      expect(
        controller.lastActionError,
        'Mesa com comanda ativa precisa manter ao menos uma pessoa sentada.',
      );

      controller.dispose();
    },
  );

  testWidgets('renderiza a pagina de mesas em largura mobile sem overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: GulaTheme.light(), home: const MesaPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salao interno'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'abre popover operacional e ativa o modo layout no proprio mapa',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: GulaTheme.light(), home: const MesaPage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mesa 01'));
      await tester.pumpAndSettle();

      expect(find.text('Pedido #1001'), findsOneWidget);
      expect(find.text('Ver comanda'), findsOneWidget);

      await tester.tap(find.text('Modo layout'));
      await tester.pumpAndSettle();

      expect(find.text('Layout ativo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
