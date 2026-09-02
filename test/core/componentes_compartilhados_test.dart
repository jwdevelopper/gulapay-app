import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';
import 'package:my_app_teste/core/widgets/app_botao_icone.dart';
import 'package:my_app_teste/core/widgets/app_data.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';

void main() {
  Widget montar(Widget filho) => MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('pt', 'BR')],
    locale: const Locale('pt', 'BR'),
    home: Scaffold(body: filho),
  );

  group('AppRotuloCampo', () {
    testWidgets('sem obrigatório não mostra asterisco', (tester) async {
      await tester.pumpWidget(montar(const AppRotuloCampo('Validade')));
      final texto = tester.widget<Text>(find.byType(Text));
      expect(texto.textSpan!.toPlainText(), 'Validade');
    });

    testWidgets('com obrigatório acrescenta o asterisco', (tester) async {
      await tester.pumpWidget(
        montar(const AppRotuloCampo('Validade', obrigatorio: true)),
      );
      final texto = tester.widget<Text>(find.byType(Text));
      expect(texto.textSpan!.toPlainText(), 'Validade *');
    });

    testWidgets('renderiza o acessório à direita', (tester) async {
      await tester.pumpWidget(
        montar(
          const AppRotuloCampo(
            'Lote',
            obrigatorio: true,
            acessorio: Text('FEFO'),
          ),
        ),
      );
      expect(find.text('FEFO'), findsOneWidget);
    });
  });

  group('AppMensagemErroCampo', () {
    testWidgets('oculta quando não visível', (tester) async {
      await tester.pumpWidget(
        montar(const AppMensagemErroCampo('Campo obrigatório', visivel: false)),
      );
      expect(find.text('Campo obrigatório'), findsNothing);
    });

    testWidgets('mostra quando visível', (tester) async {
      await tester.pumpWidget(
        montar(const AppMensagemErroCampo('Campo obrigatório', visivel: true)),
      );
      expect(find.text('Campo obrigatório'), findsOneWidget);
    });
  });

  group('AppBotaoIcone', () {
    testWidgets('dispara o toque', (tester) async {
      var tocou = false;
      await tester.pumpWidget(
        montar(
          AppBotaoIcone(
            icone: Icons.filter_alt_outlined,
            aoTocar: () => tocou = true,
          ),
        ),
      );
      await tester.tap(find.byType(AppBotaoIcone));
      expect(tocou, isTrue);
    });

    testWidgets('selo aparece só quando pedido', (tester) async {
      await tester.pumpWidget(
        montar(const AppBotaoIcone(icone: Icons.filter_alt_outlined)),
      );
      expect(find.byKey(AppBotaoIcone.chaveSelo), findsNothing);

      await tester.pumpWidget(
        montar(
          const AppBotaoIcone(
            icone: Icons.filter_alt_outlined,
            mostrarSelo: true,
          ),
        ),
      );
      expect(find.byKey(AppBotaoIcone.chaveSelo), findsOneWidget);
    });
  });

  group('AppLinhaResumo', () {
    testWidgets('exibe rótulo e valor', (tester) async {
      await tester.pumpWidget(
        montar(const AppLinhaResumo(rotulo: 'Tipo', valor: 'Compra')),
      );
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Compra'), findsOneWidget);
    });
  });

  group('formatação de data', () {
    test('formatarDataBr usa dd/mm/aaaa', () {
      expect(formatarDataBr(DateTime(2026, 12, 31)), '31/12/2026');
      expect(formatarDataBr(DateTime(2026, 1, 5)), '05/01/2026');
    });

    test('formatarDataIso usa aaaa-mm-dd', () {
      expect(formatarDataIso(DateTime(2026, 12, 31)), '2026-12-31');
      expect(formatarDataIso(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('AppCampoData', () {
    testWidgets('mostra a dica quando vazio', (tester) async {
      await tester.pumpWidget(
        montar(AppCampoData(valor: null, aoSelecionar: (_) {})),
      );
      expect(find.text('dd/mm/aaaa'), findsOneWidget);
    });

    testWidgets('mostra a data formatada quando preenchido', (tester) async {
      await tester.pumpWidget(
        montar(
          AppCampoData(valor: DateTime(2026, 12, 31), aoSelecionar: (_) {}),
        ),
      );
      expect(find.text('31/12/2026'), findsOneWidget);
    });

    testWidgets('abre o calendário temático ao toque', (tester) async {
      await tester.pumpWidget(
        montar(
          AppCampoData(valor: DateTime(2026, 6, 15), aoSelecionar: (_) {}),
        ),
      );
      await tester.tap(find.byType(AppCampoData));
      await tester.pumpAndSettle();

      // O calendário abriu com os botões traduzidos.
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // E vestido com a paleta do app, não com o azul do tema global.
      final dialogo = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      final tema = Theme.of(tester.element(find.byWidget(dialogo)));
      expect(tema.colorScheme.primary, PaletaApp.primary);
    });
  });
}
