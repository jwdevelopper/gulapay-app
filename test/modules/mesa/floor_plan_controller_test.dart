import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/dto/mesa_dto.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_form_page.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('converte requisicao e resposta seguindo o padrao em portugues', () {
    final requisicao = MesaSalvarRequisicao(numero: '12', capacidade: 4);
    final resposta = MesaResposta.deJson({
      'id': '12',
      'numero': 12,
      'capacidade': '4',
      'status': 'LIVRE',
      'ativo': true,
    });

    expect(requisicao.paraJson(), {'numero': '12', 'capacidade': 4});
    expect(resposta.id, 12);
    expect(resposta.numero, '12');
    expect(resposta.capacidade, 4);
    expect(resposta.situacao, 'LIVRE');
  });

  test('preserva o formato antigo dos dados locais do mapa', () {
    final mesa = MesaRestaurante.deMapa({
      'id': 'm1',
      'code': 'Mesa 01',
      'areaId': 'salao',
      'x': 10,
      'y': 20,
      'width': 112,
      'height': 84,
      'shape': 'round',
      'chairsCount': 4,
      'status': 'free',
      'isJoined': false,
    });

    expect(mesa.formato, FormatoMesa.redonda);
    expect(mesa.situacao, SituacaoMesa.livre);
    expect(mesa.paraMapa()['shape'], 'round');
    expect(mesa.paraMapa()['status'], 'free');
  });

  test('bloqueia mesa duplicada e pessoas acima da capacidade', () async {
    final controlador = ControladorMapaMesas();
    await controlador.carregar();

    await controlador.salvarMesa(
      RascunhoMesa(
        codigo: 'Mesa 01',
        idArea: 'salao',
        formato: FormatoMesa.retangular,
        quantidadeCadeiras: 4,
        width: 112,
        height: 84,
      ),
    );

    expect(
      controlador.erroUltimaAcao,
      'Ja existe uma mesa com esse codigo nessa area.',
    );

    await controlador.salvarMesa(
      RascunhoMesa(
        codigo: 'Mesa 99',
        idArea: 'salao',
        formato: FormatoMesa.retangular,
        quantidadeCadeiras: 2,
        width: 112,
        height: 84,
        pessoasSentadas: 3,
      ),
    );

    expect(
      controlador.erroUltimaAcao,
      'Pessoas sentadas nao podem ultrapassar a capacidade da mesa.',
    );
    expect(
      controlador
          .buscarAreaPorId('salao')!
          .mesas
          .any((mesa) => mesa.codigo == 'Mesa 99'),
      isFalse,
    );

    controlador.dispose();
  });

  test('sugere uniao quando mesas ficam proximas no mapa', () async {
    final controlador = ControladorMapaMesas();
    await controlador.carregar();

    controlador.iniciarMovimento('m3');
    await controlador.moverMesa(
      'm3',
      const Offset(-78, -162),
      const Size(920, 640),
    );

    expect(controlador.idAlvoUniaoSugerida, 'm2');
    expect(controlador.idOrigemUniaoSugerida, 'm3');

    controlador.dispose();
  });

  test('move mesa com delta pequeno sem travar no snap da grade', () async {
    final controlador = ControladorMapaMesas();
    await controlador.carregar();

    final before = controlador.buscarMesaPorId('m3')!;
    controlador.iniciarMovimento('m3');
    await controlador.moverMesa(
      'm3',
      const Offset(2.5, 1.5),
      const Size(920, 640),
    );
    final duringMove = controlador.buscarMesaPorId('m3')!;

    expect(duringMove.x, closeTo(before.x + 2.5, 0.01));
    expect(duringMove.y, closeTo(before.y + 1.5, 0.01));

    await controlador.finalizarMovimento();
    final afterDrop = controlador.buscarMesaPorId('m3')!;

    expect(afterDrop.x % 12, 0);
    expect(afterDrop.y % 12, 0);

    controlador.dispose();
  });

  test('une mesas sugeridas direto pelo mapa de edicao', () async {
    final controlador = ControladorMapaMesas();
    await controlador.carregar();

    controlador.iniciarMovimento('m3');
    await controlador.moverMesa(
      'm3',
      const Offset(-78, -162),
      const Size(920, 640),
    );

    final error = await controlador.unirMesasSugeridas();

    expect(error, isNull);
    expect(controlador.buscarMesaPorId('m2')!.estaUnida, isTrue);
    expect(controlador.buscarMesaPorId('m3')!.estaUnida, isTrue);
    expect(controlador.buscarAreaPorId('salao')!.gruposUniao, hasLength(1));

    controlador.dispose();
  });

  test('bloqueia uniao de mesas com comandas ativas diferentes', () async {
    final controlador = ControladorMapaMesas();
    await controlador.carregar();

    final result = await controlador.abrirComandaDaMesa('m2');
    expect(result, isNotNull);
    expect(
      controlador.mesasCompativeisParaUniao('m1').map((mesa) => mesa.id),
      isNot(contains('m2')),
    );

    final error = await controlador.unirMesas(
      idMesaOrigem: 'm1',
      idMesaAlvo: 'm2',
    );

    expect(
      error,
      'As mesas possuem pedidos diferentes e nao podem ser unidas agora.',
    );

    controlador.dispose();
  });

  test(
    'bloqueia mover ou esvaziar mesa com comanda ativa pela edicao',
    () async {
      final controlador = ControladorMapaMesas();
      await controlador.carregar();

      await controlador.salvarMesa(
        RascunhoMesa(
          id: 'm1',
          codigo: 'Mesa 01',
          idArea: 'varanda',
          formato: FormatoMesa.retangular,
          quantidadeCadeiras: 6,
          width: 116,
          height: 86,
          pessoasSentadas: 4,
        ),
      );

      expect(
        controlador.erroUltimaAcao,
        'Encerre a comanda antes de mover a mesa para outra area.',
      );

      await controlador.salvarMesa(
        RascunhoMesa(
          id: 'm1',
          codigo: 'Mesa 01',
          idArea: 'salao',
          formato: FormatoMesa.retangular,
          quantidadeCadeiras: 6,
          width: 116,
          height: 86,
        ),
      );

      expect(
        controlador.erroUltimaAcao,
        'Mesa com comanda ativa precisa manter ao menos uma pessoa sentada.',
      );

      controlador.dispose();
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
      MaterialApp(theme: GulaTheme.light(), home: const MesaPagina()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salao interno'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('abre o formulario de mesa em largura mobile sem overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: GulaTheme.light(), home: const MesaPagina()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mesa 01'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Detalhes da mesa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar mesa'), findsOneWidget);
    expect(find.text('Código da mesa *'), findsOneWidget);
    expect(find.byType(AppCampoTexto), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('seleciona a area da nova mesa pela modal personalizada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final areas = [
      AreaRestaurante(
        id: 'salao',
        nome: 'Salao interno',
        tipo: 'interno',
        mesas: [],
      ),
      AreaRestaurante(
        id: 'varanda',
        nome: 'Varanda',
        tipo: 'externo',
        mesas: [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: GulaTheme.light(),
        home: MesaFormularioPagina(areas: areas, idAreaInicial: 'salao'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salao interno'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha a área'), findsOneWidget);
    expect(find.text('Varanda'), findsOneWidget);

    await tester.tap(find.text('Varanda'));
    await tester.pumpAndSettle();

    expect(find.text('Varanda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('alterna formatos circulares sem erro durante a animacao', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: GulaTheme.light(),
        home: MesaFormularioPagina(
          areas: [
            AreaRestaurante(
              id: 'salao',
              nome: 'Salao interno',
              tipo: 'interno',
              mesas: [],
            ),
          ],
          idAreaInicial: 'salao',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Redonda'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 90));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quadrada'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 90));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

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
        MaterialApp(theme: GulaTheme.light(), home: const MesaPagina()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mesa 01'));
      await tester.pumpAndSettle();

      expect(find.text('Pedido #1001'), findsOneWidget);
      expect(find.text('Ver comanda'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar resumo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modo layout'));
      await tester.pumpAndSettle();

      expect(find.text('Layout ativo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
