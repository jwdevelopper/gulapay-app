import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_card.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

import '../../helpers/insumo_fixtures.dart';
import '../../helpers/insumo_harness.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required InsumoResponse insumo,
    double? percentVsMinimo,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    Future<bool> Function()? onConfirmDelete,
  }) {
    return pumpPage(
      tester,
      Scaffold(
        body: InsumoCard(
          insumo: insumo,
          icon: Icons.inventory_2_rounded,
          accentColor: const Color(0xFFF8C39C),
          stockBarColor: Colors.green,
          stockText: '25,000 kg',
          percentVsMinimo: percentVsMinimo,
          onTap: onTap ?? () {},
          onConfirmDelete: onConfirmDelete ?? () async => false,
        ),
      ),
    );
  }

  group('conteúdo', () {
    testWidgets('exibe nome, unidade e estoque atual com símbolo',
        (tester) async {
      await pumpCard(tester, insumo: insumoFixture());
      await tester.pump();

      expect(find.text('Tomate italiano'), findsOneWidget);
      expect(find.text('Quilograma'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('mostra "Sem nome" quando o nome vem nulo', (tester) async {
      await pumpCard(tester, insumo: insumoFixture(nome: null));
      await tester.pump();

      expect(find.text('Sem nome'), findsOneWidget);
    });

    testWidgets('formata estoque fracionário com uma casa e vírgula',
        (tester) async {
      await pumpCard(tester, insumo: insumoFixture(estoqueAtual: 2.5));
      await tester.pump();

      expect(find.text('2,5'), findsOneWidget);
    });

    testWidgets('omite casas decimais quando o estoque é inteiro',
        (tester) async {
      await pumpCard(tester, insumo: insumoFixture(estoqueAtual: 7));
      await tester.pump();

      expect(find.text('7'), findsOneWidget);
      expect(find.text('7,0'), findsNothing);
    });

    testWidgets('trata estoque nulo como zero em vez de quebrar',
        (tester) async {
      await pumpCard(tester, insumo: insumoFixture(estoqueAtual: null));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('cai para o símbolo quando não há nome de unidade',
        (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(
          unidadePadraoNome: null,
          unidadePadraoSimbolo: 'kg',
        ),
      );
      await tester.pump();

      // 'kg' aparece como subtítulo E ao lado do número.
      expect(find.text('kg'), findsNWidgets(2));
    });
  });

  group('badge de estoque abaixo do mínimo', () {
    testWidgets('aparece com o percentual quando abaixoDoMinimo é true',
        (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(abaixoDoMinimo: true),
        percentVsMinimo: -60,
      );
      await tester.pump();

      expect(find.text('-60% DO MÍNIMO'), findsOneWidget);
    });

    testWidgets('não aparece quando o estoque está normal', (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(abaixoDoMinimo: false),
        percentVsMinimo: 150,
      );
      await tester.pump();

      expect(find.textContaining('DO MÍNIMO'), findsNothing);
    });

    testWidgets('não aparece quando o percentual é indefinido', (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(abaixoDoMinimo: true),
        percentVsMinimo: null,
      );
      await tester.pump();

      expect(find.textContaining('DO MÍNIMO'), findsNothing);
    });
  });

  group('interações', () {
    testWidgets('toque no card dispara onTap', (tester) async {
      var toques = 0;
      await pumpCard(
        tester,
        insumo: insumoFixture(),
        onTap: () => toques++,
      );
      await tester.pump();

      await tester.tap(find.text('Tomate italiano'));
      await tester.pump();

      expect(toques, 1);
    });

    testWidgets('swipe para a esquerda revela a ação de excluir',
        (tester) async {
      await pumpCard(tester, insumo: insumoFixture());
      await tester.pump();

      await tester.drag(find.byType(Dismissible), const Offset(-300, 0));
      await tester.pump();

      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('swipe consulta onConfirmDelete', (tester) async {
      var consultas = 0;
      await pumpCard(
        tester,
        insumo: insumoFixture(),
        onConfirmDelete: () async {
          consultas++;
          return false;
        },
      );
      await tester.pump();

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(consultas, 1);
    });

    testWidgets('card permanece na tela quando a exclusão é negada',
        (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(),
        onConfirmDelete: () async => false,
      );
      await tester.pump();

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Tomate italiano'), findsOneWidget);
    });

    testWidgets('card some quando a exclusão é confirmada', (tester) async {
      await pumpCard(
        tester,
        insumo: insumoFixture(),
        onConfirmDelete: () async => true,
      );
      await tester.pump();

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Tomate italiano'), findsNothing);
    });
  });

  testWidgets('cada card tem uma key estável baseada no id', (tester) async {
    await pumpCard(tester, insumo: insumoFixture(id: 42));
    await tester.pump();

    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.key, const ValueKey('insumo-42'));
  });
}
