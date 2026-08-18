import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_patch.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------

class MockInsumoService extends Mock implements InsumoService {}

class _FakeInsumoCreateRequest extends Fake implements InsumoCreateRequest {}

class _FakeInsumoUpdate extends Fake implements InsumoUpdate {}

class _FakeInsumoPatch extends Fake implements InsumoPatch {}

/// Chame uma vez em `setUpAll` de cada arquivo que usa `any()` com DTOs.
void registerInsumoFallbacks() {
  registerFallbackValue(_FakeInsumoCreateRequest());
  registerFallbackValue(_FakeInsumoUpdate());
  registerFallbackValue(_FakeInsumoPatch());
}

// -----------------------------------------------------------------------------
// Stubs de carregamento de unidades
// -----------------------------------------------------------------------------

/// Retorna imediatamente a lista informada.
Future<List<UnidadeMedidaResponse>> Function() unidadesOk(
  List<UnidadeMedidaResponse> unidades,
) {
  return () async => unidades;
}

/// Sempre falha — usado para exercitar o estado de erro.
Future<List<UnidadeMedidaResponse>> Function() unidadesErro([
  String mensagem = 'falha de rede',
]) {
  return () async => throw Exception(mensagem);
}

/// Fica pendente até você chamar `completer.complete(...)`.
/// Indispensável para capturar o estado de LOADING antes da resolução.
Future<List<UnidadeMedidaResponse>> Function() unidadesPendentes(
  Completer<List<UnidadeMedidaResponse>> completer,
) {
  return () => completer.future;
}

// -----------------------------------------------------------------------------
// Pump helpers
// -----------------------------------------------------------------------------

/// Monta o widget dentro de um MaterialApp mínimo.
/// NÃO chama pumpAndSettle — quem chama decide, para poder inspecionar loading.
Future<void> pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(MaterialApp(home: page));
}

/// Empurra `page` como uma rota real, para que `Navigator.pop(context, true)`
/// tenha uma rota de origem para onde voltar.
///
/// O resultado do pop chega em [onResult]. Depois desta chamada a transição
/// de rota já foi concluída, mas os Futures da página podem continuar pendentes.
Future<void> pushPage(
  WidgetTester tester,
  Widget page, {
  void Function(bool? resultado)? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                final resultado = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
                onResult?.call(resultado);
              },
              child: const Text('__abrir__'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('__abrir__'));
  await tester.pump(); // inicia a transição
  await tester.pump(const Duration(milliseconds: 400)); // conclui a transição
}

// -----------------------------------------------------------------------------
// Finders utilitários
// -----------------------------------------------------------------------------

/// Lê o `onPressed` de um botão para afirmar habilitado/desabilitado sem
/// depender de cor ou de pixel.
bool botaoHabilitado<T extends ButtonStyleButton>(
  WidgetTester tester,
  String texto,
) {
  final botao = tester.widget<T>(find.widgetWithText(T, texto));
  return botao.onPressed != null;
}
