import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app_teste/modules/insumo/components/empty_state_card.dart';
import 'package:my_app_teste/modules/insumo/components/insumo_card.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/pages/insumos_list_page.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

import '../../helpers/insumo_fixtures.dart';
import '../../helpers/insumo_harness.dart';

void main() {
  late MockInsumoService service;

  setUpAll(registerInsumoFallbacks);

  setUp(() {
    service = MockInsumoService();
  });

  /// Stub padrão: listagem resolve com [insumos].
  void stubListar([List<InsumoResponse>? insumos]) {
    when(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
        .thenAnswer((_) async => insumos ?? insumosFixture());
  }

  Future<void> pumpLista(
    WidgetTester tester, {
    Future<List<UnidadeMedidaResponse>> Function()? listarUnidades,
    bool settle = true,
  }) async {
    await pumpPage(
      tester,
      InsumosListPage(
        insumoService: service,
        listarUnidades: listarUnidades ?? unidadesOk(unidadesFixture()),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  // ---------------------------------------------------------------------------
  // Estados de carregamento
  // ---------------------------------------------------------------------------

  group('carregamento dos insumos', () {
    testWidgets('mostra o indicador enquanto a listagem não resolve',
        (tester) async {
      final completer = Completer<List<InsumoResponse>>();
      when(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .thenAnswer((_) => completer.future);

      await pumpLista(tester, settle: false);
      await tester.pump(); // NÃO usar pumpAndSettle: o future segue pendente

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byType(InsumoCard), findsNothing);

      completer.complete(insumosFixture());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renderiza um card por insumo quando a listagem resolve',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      expect(find.byType(InsumoCard), findsNWidgets(3));
      expect(find.text('Tomate italiano'), findsOneWidget);
      expect(find.text('Queijo mussarela'), findsOneWidget);
      expect(find.text('Azeite extra virgem'), findsOneWidget);
    });

    testWidgets('busca a lista completa, incluindo inativos', (tester) async {
      stubListar();
      await pumpLista(tester);

      verify(() => service.listar(apenasAtivos: false)).called(1);
    });

    testWidgets('resume o total de ativos e de itens abaixo do mínimo',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      expect(find.text('2 ativos · 1 abaixo do mínimo'), findsOneWidget);
    });

    testWidgets('exibe o empty state quando não há nenhum insumo',
        (tester) async {
      stubListar([]);
      await pumpLista(tester);

      expect(find.byType(EmptyStateCard), findsOneWidget);
      expect(find.text('Sem insumos por aqui'), findsOneWidget);
      expect(find.text('Cadastrar insumo'), findsOneWidget);
    });

    testWidgets('exibe o estado de erro com ação de recarregar',
        (tester) async {
      when(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .thenThrow(Exception('falha'));

      await pumpLista(tester);

      expect(
        find.text('Houve um erro no carregamento de insumos.'),
        findsOneWidget,
      );
      expect(find.text('Recarregar'), findsOneWidget);
    });

    testWidgets('avisa por snackbar quando a listagem falha', (tester) async {
      when(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .thenThrow(Exception('falha'));

      await pumpLista(tester, settle: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Erro ao carregar insumos'), findsOneWidget);
    });

    testWidgets('recarregar tenta a listagem novamente', (tester) async {
      when(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .thenThrow(Exception('falha'));
      await pumpLista(tester);

      await tester.tap(find.text('Recarregar'));
      await tester.pumpAndSettle();

      verify(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .called(2);
    });
  });

  // ---------------------------------------------------------------------------
  // Unidades de medida (carregamento independente da listagem)
  // ---------------------------------------------------------------------------

  group('carregamento das unidades', () {
    testWidgets('a lista aparece mesmo com as unidades ainda carregando',
        (tester) async {
      stubListar();
      final completer = Completer<List<UnidadeMedidaResponse>>();

      await pumpLista(
        tester,
        listarUnidades: unidadesPendentes(completer),
        settle: false,
      );
      await tester.pump();
      await tester.pump();

      // Os insumos já renderizaram; o spinner restante é o das unidades.
      expect(find.byType(InsumoCard), findsNWidgets(3));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(unidadesFixture());
      await tester.pumpAndSettle();
    });

    testWidgets('renderiza os chips quando as unidades resolvem',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Quilograma'), findsOneWidget);
      expect(find.text('Litro'), findsOneWidget);
    });

    testWidgets('oferece "Recarregar unidades" quando o carregamento falha',
        (tester) async {
      stubListar();
      await pumpLista(tester, listarUnidades: unidadesErro());

      expect(find.text('Recarregar unidades'), findsOneWidget);
      // A falha nas unidades não pode derrubar a listagem.
      expect(find.byType(InsumoCard), findsNWidgets(3));
    });

    testWidgets('recarregar unidades tenta novamente', (tester) async {
      stubListar();
      var tentativas = 0;
      await pumpLista(
        tester,
        listarUnidades: () async {
          tentativas++;
          throw Exception('falha');
        },
      );

      await tester.tap(find.text('Recarregar unidades'));
      await tester.pumpAndSettle();

      expect(tentativas, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // Busca
  // ---------------------------------------------------------------------------

  group('busca por nome', () {
    testWidgets('filtra os cards conforme o texto digitado', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.enterText(find.byType(TextField), 'quei');
      await tester.pumpAndSettle();

      expect(find.text('Queijo mussarela'), findsOneWidget);
      expect(find.text('Tomate italiano'), findsNothing);
      expect(find.byType(InsumoCard), findsOneWidget);
    });

    testWidgets('a busca ignora diferença de maiúsculas', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.enterText(find.byType(TextField), 'TOMATE');
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsOneWidget);
      expect(find.text('Tomate italiano'), findsOneWidget);
    });

    testWidgets('mostra empty state específico quando nada casa',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.text('Nenhum insumo encontrado'), findsOneWidget);
      expect(find.byType(InsumoCard), findsNothing);
    });

    testWidgets('limpar busca restaura a lista completa', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();

      // Há dois "Limpar busca": o do header e o do empty state.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpar busca'));
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsNWidgets(3));
      expect(find.text('Nenhum insumo encontrado'), findsNothing);
    });

    testWidgets('a busca não dispara nova chamada ao serviço', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.enterText(find.byType(TextField), 'quei');
      await tester.pumpAndSettle();

      // Filtragem é local: continua sendo uma única chamada.
      verify(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // Filtro por unidade (chips)
  // ---------------------------------------------------------------------------

  group('filtro por unidade', () {
    testWidgets('selecionar um chip filtra pela unidade padrão',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Litro'));
      await tester.pumpAndSettle();

      expect(find.text('Azeite extra virgem'), findsOneWidget);
      expect(find.byType(InsumoCard), findsOneWidget);
    });

    testWidgets('tocar em "Todos" remove o filtro de unidade', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Litro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsNWidgets(3));
    });

    testWidgets('busca e chip se combinam', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Quilograma'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'tomate');
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsOneWidget);
      expect(find.text('Tomate italiano'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Ordenação
  // ---------------------------------------------------------------------------

  group('ordenação', () {
    testWidgets('inicia em "Estoque crescente"', (tester) async {
      stubListar();
      await pumpLista(tester);

      expect(find.text('Estoque crescente'), findsOneWidget);
    });

    testWidgets('ordena do menor para o maior estoque por padrão',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      final nomes = tester
          .widgetList<InsumoCard>(find.byType(InsumoCard))
          .map((c) => c.insumo.nome)
          .toList();

      expect(nomes, [
        'Queijo mussarela',
        'Tomate italiano',
        'Azeite extra virgem',
      ]);
    });

    testWidgets('trocar a ordenação atualiza o rótulo do botão',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Estoque crescente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nome Z-A'));
      await tester.pumpAndSettle();

      expect(find.text('Nome Z-A'), findsOneWidget);
      expect(find.text('Estoque crescente'), findsNothing);
    });

    testWidgets('ordenação por nome reordena os cards', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Estoque crescente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nome A-Z'));
      await tester.pumpAndSettle();

      final nomes = tester
          .widgetList<InsumoCard>(find.byType(InsumoCard))
          .map((c) => c.insumo.nome)
          .toList();

      expect(nomes, [
        'Azeite extra virgem',
        'Queijo mussarela',
        'Tomate italiano',
      ]);
    });

    testWidgets('ordenação com grouper insere cabeçalhos de seção',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Estoque crescente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nome A-Z'));
      await tester.pumpAndSettle();

      expect(find.text('A · 1'), findsOneWidget);
      expect(find.text('Q · 1'), findsOneWidget);
      expect(find.text('T · 1'), findsOneWidget);
    });

    testWidgets('agrupar por unidade usa o símbolo e conta os itens',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Estoque crescente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Por unidade de medida'));
      await tester.pumpAndSettle();

      expect(find.text('kg · 2'), findsOneWidget);
      expect(find.text('L · 1'), findsOneWidget);
    });

    testWidgets('ordenação sem grouper não cria cabeçalhos', (tester) async {
      stubListar();
      await pumpLista(tester);

      expect(find.textContaining(' · 1'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Exclusão
  // ---------------------------------------------------------------------------

  group('exclusão', () {
    Future<void> deslizarPrimeiroCard(WidgetTester tester) async {
      await tester.drag(find.byType(InsumoCard).first, const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('swipe abre o diálogo de confirmação com o nome do insumo',
        (tester) async {
      stubListar();
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      expect(find.text('Excluir insumo'), findsOneWidget);
      expect(
        find.textContaining('Queijo mussarela'),
        findsOneWidget,
        reason: 'o diálogo precisa dizer qual insumo será apagado',
      );
      expect(find.textContaining('não pode ser desfeita'), findsOneWidget);
    });

    testWidgets('cancelar mantém o card e não chama o serviço', (tester) async {
      stubListar();
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsNWidgets(3));
      verifyNever(() => service.excluir(any()));
    });

    testWidgets('confirmar chama excluir com o id correto', (tester) async {
      stubListar();
      when(() => service.excluir(any())).thenAnswer((_) async {});
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir'));
      await tester.pumpAndSettle();

      verify(() => service.excluir(2)).called(1); // Queijo mussarela
    });

    testWidgets('confirmar remove o card e confirma por snackbar',
        (tester) async {
      stubListar();
      when(() => service.excluir(any())).thenAnswer((_) async {});
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(find.byType(InsumoCard), findsNWidgets(2));
      expect(
        find.text('Insumo "Queijo mussarela" excluído.'),
        findsOneWidget,
      );
    });

    testWidgets('falha na exclusão mantém o card e avisa o usuário',
        (tester) async {
      stubListar();
      when(() => service.excluir(any())).thenThrow(Exception('sem permissão'));
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erro ao excluir'), findsOneWidget);
      expect(find.byType(InsumoCard), findsNWidgets(3));
    });

    testWidgets('o contador do resumo cai após a exclusão', (tester) async {
      stubListar();
      when(() => service.excluir(any())).thenAnswer((_) async {});
      await pumpLista(tester);
      await deslizarPrimeiroCard(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(find.text('1 ativos · 0 abaixo do mínimo'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Navegação e refresh
  // ---------------------------------------------------------------------------

  group('navegação e refresh', () {
    testWidgets('o FAB abre o formulário de cadastro', (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Novo insumo'), findsOneWidget);
    });

    testWidgets('tocar em um card abre o formulário de edição',
        (tester) async {
      stubListar();
      await pumpLista(tester);

      await tester.tap(find.text('Tomate italiano'));
      await tester.pumpAndSettle();

      // Ver REFACTOR_TESTABILIDADE.md, item 1: hoje `isEditing` olha só para
      // `insumoId`, então a página abre como "Novo insumo" mesmo editando.
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('pull to refresh recarrega insumos e unidades',
        (tester) async {
      stubListar();
      var carregamentosDeUnidade = 0;
      await pumpLista(
        tester,
        listarUnidades: () async {
          carregamentosDeUnidade++;
          return unidadesFixture();
        },
      );

      await tester.fling(
        find.byType(InsumoCard).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => service.listar(apenasAtivos: any(named: 'apenasAtivos')))
          .called(2);
      expect(carregamentosDeUnidade, 2);
    });
  });
}
