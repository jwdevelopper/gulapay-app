import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_filter_component.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_list_filter.dart';

void main() {
  /// Abre o sheet e devolve um getter para o filtro retornado no pop.
  Future<InsumosFilters? Function()> abrirFiltros(
    WidgetTester tester, {
    InsumosFilters inicial = const InsumosFilters(),
  }) async {
    InsumosFilters? resultado;
    var fechou = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  resultado = await InsumoFilterComponent.show(
                    context,
                    initialFilter: inicial,
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

  // 'Todos' aparece duas vezes: seção Estoque (0) e seção Status (1).
  Finder todosEstoque() => find.text('Todos').first;
  Finder todosStatus() => find.text('Todos').at(1);

  group('estrutura', () {
    testWidgets('exibe as seções Estoque e Status com suas opções',
        (tester) async {
      await abrirFiltros(tester);

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Estoque'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Abaixo do mínimo'), findsOneWidget);
      expect(find.text('Ativo'), findsOneWidget);
      expect(find.text('Inativo'), findsOneWidget);
      expect(find.text('Todos'), findsNWidgets(2));
    });

    testWidgets('sem filtro ativo, "Todos" está marcado nas duas seções',
        (tester) async {
      await abrirFiltros(tester);

      // Duas opções marcadas => dois ícones de check.
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    });

    testWidgets('reflete o filtro inicial recebido', (tester) async {
      await abrirFiltros(
        tester,
        inicial: const InsumosFilters(abaixoDoMinimo: true, ativo: false),
      );

      // Agora os marcados são "Abaixo do mínimo" e "Inativo",
      // então nenhum "Todos" está marcado.
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));

      // Confirma tocando: se já estivesse em "Todos", o estado mudaria.
      final abaixo = tester.widget<Text>(find.text('Abaixo do mínimo'));
      expect(abaixo.style?.fontWeight, FontWeight.w600);
    });
  });

  group('seleção e retorno', () {
    testWidgets('aplicar devolve o filtro com as opções escolhidas',
        (tester) async {
      final resultado = await abrirFiltros(tester);

      await tester.tap(find.text('Abaixo do mínimo'));
      await tester.pump();
      await tester.tap(find.text('Ativo'));
      await tester.pump();
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(resultado()?.abaixoDoMinimo, isTrue);
      expect(resultado()?.ativo, isTrue);
    });

    testWidgets('aplicar preserva campos que o sheet não edita',
        (tester) async {
      final resultado = await abrirFiltros(
        tester,
        inicial: const InsumosFilters(nome: 'tomate', unidadePadraoId: 2),
      );

      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(resultado()?.nome, 'tomate');
      expect(resultado()?.unidadePadraoId, 2);
    });

    testWidgets('"Inativo" devolve ativo == false, não null', (tester) async {
      final resultado = await abrirFiltros(tester);

      await tester.tap(find.text('Inativo'));
      await tester.pump();
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(resultado()?.ativo, isFalse);
    });

    testWidgets('fechar no X não devolve filtro nenhum', (tester) async {
      final resultado = await abrirFiltros(tester);

      await tester.tap(find.text('Abaixo do mínimo'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(resultado(), isNull);
    });

    testWidgets('"Limpar" desmarca as opções na própria tela', (tester) async {
      await abrirFiltros(tester);

      await tester.tap(find.text('Abaixo do mínimo'));
      await tester.pump();
      await tester.tap(find.text('Inativo'));
      await tester.pump();

      await tester.tap(find.text('Limpar'));
      await tester.pump();

      // Voltou para "Todos" nas duas seções.
      final estoque = tester.widget<Text>(todosEstoque());
      final status = tester.widget<Text>(todosStatus());
      expect(estoque.style?.fontWeight, FontWeight.w600);
      expect(status.style?.fontWeight, FontWeight.w600);
    });
  });

  // ---------------------------------------------------------------------------
  // BUG CONHECIDO — ver REFACTOR_TESTABILIDADE.md, item 4.
  // "Limpar" muda a UI, mas o `copyWith` não sabe distinguir "não informado"
  // de "limpar", então o filtro antigo volta intacto ao aplicar.
  // ---------------------------------------------------------------------------
  testWidgets(
    'limpar + aplicar remove de fato os filtros anteriores',
    (tester) async {
      final resultado = await abrirFiltros(
        tester,
        inicial: const InsumosFilters(abaixoDoMinimo: true, ativo: false),
      );

      await tester.tap(find.text('Limpar'));
      await tester.pump();
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(resultado()?.abaixoDoMinimo, isNull);
      expect(resultado()?.ativo, isNull);
    },
  );
}
