import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';
import 'package:my_app_teste/modules/insumo/pages/insumo_form_page.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

import '../../helpers/insumo_fixtures.dart';
import '../../helpers/insumo_harness.dart';


void main() {
  late MockInsumoService service;

  setUpAll(registerInsumoFallbacks);

  setUp(() {
    service = MockInsumoService();
  });

  Finder campoNome() => find.widgetWithText(TextFormField, 'Nome');
  Finder campoEstoque() =>
      find.widgetWithText(TextFormField, 'Estoque mínimo');
  Finder dropdownUnidade() =>
      find.byType(DropdownButtonFormField<UnidadeMedidaResponse>);

  Future<void> selecionarUnidade(WidgetTester tester, String rotulo) async {
    await tester.tap(dropdownUnidade());
    await tester.pumpAndSettle();
    await tester.tap(find.text(rotulo).last);
    await tester.pumpAndSettle();
  }

  Future<void> preencherFormularioValido(WidgetTester tester) async {
    await tester.enterText(campoNome(), 'Tomate italiano');
    await tester.pump();
    await selecionarUnidade(tester, 'Quilograma (kg)');
    await tester.enterText(campoEstoque(), '2,5');
    await tester.pump();
  }

  // ---------------------------------------------------------------------------
  // Estrutura e modo
  // ---------------------------------------------------------------------------

  group('estrutura da tela', () {
    testWidgets('modo cadastro exibe título e rótulo de criação',
        (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Novo insumo'), findsOneWidget);
      expect(find.text('Cadastrar insumo'), findsOneWidget);
    });

    testWidgets('modo cadastro não mostra o switch de ativo', (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('modo edição exibe título, rótulo e switch de ativo',
        (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 1,
          insumo: insumoFixture(estoqueMinimo: 2.5),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar insumo'), findsOneWidget);
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Ativo'), findsOneWidget);
    });

    testWidgets('modo edição pré-preenche nome e estoque mínimo',
        (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 1,
          insumo: insumoFixture(nome: 'Queijo', estoqueMinimo: 2.5),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Queijo'), findsOneWidget);
      expect(find.text('2,5'), findsOneWidget,
          reason: 'o decimal precisa aparecer com vírgula no input');
    });

    testWidgets('o switch reflete o estado inativo do insumo', (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 1,
          insumo: insumoFixture(ativo: false),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isFalse);
      expect(find.textContaining('não aparece em listagens'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Carregamento das unidades
  // ---------------------------------------------------------------------------

  group('carregamento das unidades', () {
    testWidgets('mantém o botão salvar desabilitado enquanto carrega',
        (tester) async {
      final completer = Completer<List<UnidadeMedidaResponse>>();

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesPendentes(completer),
        ),
      );
      await tester.pump();

      expect(
        botaoHabilitado<ElevatedButton>(tester, 'Cadastrar insumo'),
        isFalse,
      );

      completer.complete(unidadesFixture());
      await tester.pumpAndSettle();

      expect(
        botaoHabilitado<ElevatedButton>(tester, 'Cadastrar insumo'),
        isTrue,
      );
    });

    testWidgets('oferece apenas unidades ativas no dropdown', (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(dropdownUnidade());
      await tester.pumpAndSettle();

      expect(find.text('Quilograma (kg)'), findsWidgets);
      expect(find.text('Litro (L)'), findsWidgets);
      expect(
        find.text('Caixa (cx)'),
        findsNothing,
        reason: 'unidade inativa não pode ser selecionável',
      );
    });

    testWidgets('falha no carregamento troca o form pela tela de erro',
        (tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesErro('sem conexão'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('sem conexão'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.byType(Form), findsNothing);
    });

    testWidgets('"Tentar novamente" refaz o carregamento e recupera o form',
        (tester) async {
      var tentativas = 0;
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: () async {
            tentativas++;
            if (tentativas == 1) throw Exception('falhou');
            return unidadesFixture();
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(tentativas, 2);
      expect(find.byType(Form), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Validação
  // ---------------------------------------------------------------------------

  group('validação', () {
    Future<void> abrirEValidar(WidgetTester tester) async {
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();
    }

    testWidgets('form vazio acusa os três campos obrigatórios',
        (tester) async {
      await abrirEValidar(tester);

      expect(find.text('Informe o nome do insumo'), findsOneWidget);
      expect(find.text('Selecione uma unidade de medida'), findsOneWidget);
      expect(find.text('Informe o estoque mínimo'), findsOneWidget);
    });

    testWidgets('form inválido não chama o serviço', (tester) async {
      await abrirEValidar(tester);

      verifyNever(() => service.criar(any()));
    });

    testWidgets('nome com menos de 2 caracteres é rejeitado', (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoNome(), 'A');
      await tester.pumpAndSettle();

      expect(find.text('Nome deve ter no mínimo 2 caracteres'), findsOneWidget);
    });

    testWidgets('nome só com espaços conta como vazio', (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoNome(), '    ');
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do insumo'), findsOneWidget);
    });

    testWidgets('estoque com formato quebrado acusa valor inválido',
        (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoEstoque(), '1,2,3');
      await tester.pumpAndSettle();

      expect(find.text('Valor inválido'), findsOneWidget);
    });

    testWidgets('estoque aceita vírgula como separador decimal',
        (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoEstoque(), '0,5');
      await tester.pumpAndSettle();

      expect(find.text('Valor inválido'), findsNothing);
      expect(find.text('Informe o estoque mínimo'), findsNothing);
    });

    testWidgets('estoque zero é aceito', (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoEstoque(), '0');
      await tester.pumpAndSettle();

      expect(find.text('Não pode ser negativo'), findsNothing);
      expect(find.text('Valor inválido'), findsNothing);
    });

    testWidgets('o campo de estoque bloqueia caracteres não numéricos',
        (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoEstoque(), 'abc-12');
      await tester.pumpAndSettle();

      // O inputFormatter só deixa passar [0-9,.]
      expect(find.text('abc-12'), findsNothing);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('validação limpa a mensagem quando o campo é corrigido',
        (tester) async {
      await abrirEValidar(tester);

      await tester.enterText(campoNome(), 'Tomate');
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do insumo'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Salvamento — cadastro
  // ---------------------------------------------------------------------------

  group('cadastro', () {
    testWidgets('envia o payload com nome, unidade e estoque corretos',
        (tester) async {
      when(() => service.criar(any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      final req = verify(() => service.criar(captureAny())).captured.single
          as InsumoCreateRequest;

      expect(req.nome, 'Tomate italiano');
      expect(req.unidadePadraoId, 1);
      expect(req.estoqueMinimo, 2.5);
    });

    testWidgets('o JSON usa a chave unidadePadraoId exigida pelo back-end',
        (tester) async {
      when(() => service.criar(any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      final req = verify(() => service.criar(captureAny())).captured.single
          as InsumoCreateRequest;

      expect(req.toJson().containsKey('unidadePadraoId'), isTrue);
      expect(req.toJson()['unidadePadraoId'], 1);
    });

    testWidgets('o nome é enviado sem espaços nas pontas', (tester) async {
      when(() => service.criar(any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(campoNome(), '   Tomate   ');
      await selecionarUnidade(tester, 'Quilograma (kg)');
      await tester.enterText(campoEstoque(), '1');
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      final req = verify(() => service.criar(captureAny())).captured.single
          as InsumoCreateRequest;
      expect(req.nome, 'Tomate');
    });

    testWidgets('sucesso mostra snackbar de confirmação', (tester) async {
      when(() => service.criar(any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Insumo cadastrado com sucesso.'), findsOneWidget);
    });

    testWidgets('sucesso fecha a tela devolvendo true', (tester) async {
      when(() => service.criar(any()))
          .thenAnswer((_) async => insumoFixture());

      bool? resultado;
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
        onResult: (r) => resultado = r,
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      expect(resultado, isTrue);
      expect(find.text('Novo insumo'), findsNothing);
    });

    testWidgets('exibe o spinner no botão enquanto salva', (tester) async {
      final completer = Completer<InsumoResponse>();
      when(() => service.criar(any())).thenAnswer((_) => completer.future);

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cadastrar insumo'), findsNothing);

      completer.complete(insumoFixture());
      await tester.pumpAndSettle();
    });

    testWidgets('bloqueia os campos durante o salvamento', (tester) async {
      final completer = Completer<InsumoResponse>();
      when(() => service.criar(any())).thenAnswer((_) => completer.future);

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pump();

      final dropdown =
          tester.widget<DropdownButtonFormField<UnidadeMedidaResponse>>(
        dropdownUnidade(),
      );
      expect(dropdown.onChanged, isNull);

      completer.complete(insumoFixture());
      await tester.pumpAndSettle();
    });

    testWidgets('erro no salvamento avisa e mantém a tela aberta',
        (tester) async {
      when(() => service.criar(any())).thenThrow(Exception('409 duplicado'));

      bool? resultado;
      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
        onResult: (r) => resultado = r,
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Erro ao salvar'), findsOneWidget);
      expect(find.text('Novo insumo'), findsOneWidget);
      expect(resultado, isNull);
    });

    testWidgets('após o erro o botão volta a ficar utilizável',
        (tester) async {
      when(() => service.criar(any())).thenThrow(Exception('boom'));

      await pushPage(
        tester,
        InsumoFormPage(
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await preencherFormularioValido(tester);
      await tester.tap(find.text('Cadastrar insumo'));
      await tester.pumpAndSettle();

      expect(
        botaoHabilitado<ElevatedButton>(tester, 'Cadastrar insumo'),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Salvamento — edição
  // ---------------------------------------------------------------------------

  group('edição', () {
    testWidgets('envia update com o id do insumo e o estado do switch',
        (tester) async {
      when(() => service.atualizar(any(), any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 7,
          insumo: insumoFixture(id: 7, nome: 'Queijo', estoqueMinimo: 5),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await selecionarUnidade(tester, 'Litro (L)');
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => service.atualizar(captureAny(), captureAny()),
      ).captured;

      expect(captured[0], 7);
      final req = captured[1] as InsumoUpdate;
      expect(req.nome, 'Queijo');
      expect(req.unidadePadraoId, 2);
      expect(req.estoqueMinimo, 5);
      expect(req.ativo, isFalse, reason: 'o switch foi desligado');
    });

    testWidgets('edição não chama criar', (tester) async {
      when(() => service.atualizar(any(), any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 7,
          insumo: insumoFixture(id: 7, estoqueMinimo: 5),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await selecionarUnidade(tester, 'Quilograma (kg)');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      verifyNever(() => service.criar(any()));
    });

    testWidgets('sucesso na edição mostra a mensagem de atualização',
        (tester) async {
      when(() => service.atualizar(any(), any()))
          .thenAnswer((_) async => insumoFixture());

      await pushPage(
        tester,
        InsumoFormPage(
          insumoId: 7,
          insumo: insumoFixture(id: 7, estoqueMinimo: 5),
          insumoService: service,
          listarUnidades: unidadesOk(unidadesFixture()),
        ),
      );
      await tester.pumpAndSettle();

      await selecionarUnidade(tester, 'Quilograma (kg)');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Insumo atualizado com sucesso.'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // BUG CONHECIDO — ver REFACTOR_TESTABILIDADE.md, itens 1 e 2.
    // A listagem navega com `InsumoFormPage(insumo: insumo)`, sem `insumoId`.
    // Como `isEditing => insumoId != null`, a tela abre em modo cadastro e o
    // save chama `criar()` em vez de `atualizar()`. Além disso, o dropdown usa
    // `initialValue`, que só vale no primeiro build — a unidade atual do insumo
    // chega depois do carregamento e nunca aparece pré-selecionada.
    // -------------------------------------------------------------------------
    testWidgets(
      'abrir só com o objeto insumo já entra em modo edição',
      (tester) async {
        await pushPage(
          tester,
          InsumoFormPage(
            insumo: insumoFixture(id: 7),
            insumoService: service,
            listarUnidades: unidadesOk(unidadesFixture()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Editar insumo'), findsOneWidget);
      },
    );

    testWidgets(
      'a unidade atual do insumo já vem selecionada na edição',
      (tester) async {
        await pushPage(
          tester,
          InsumoFormPage(
            insumoId: 7,
            insumo: insumoFixture(id: 7, unidadePadraoId: 2),
            insumoService: service,
            listarUnidades: unidadesOk(unidadesFixture()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Litro (L)'), findsOneWidget);
      },
    );
  });
}
