import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/page/entregador_page.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';

class _FakeEntregadorService extends EntregadorService {
  _FakeEntregadorService(this.items) : super(dio: Dio());

  final List<EntregadorResponse> items;
  int listCalls = 0;

  @override
  Future<List<EntregadorResponse>> listar({bool apenasAtivos = true}) async {
    listCalls++;
    return items;
  }
}

void main() {
  testWidgets('renderiza e filtra a listagem por nome ou telefone', (
    tester,
  ) async {
    final service = _FakeEntregadorService(const [
      EntregadorResponse(
        id: 1,
        nome: 'Ana Souza',
        telefone: '11999990000',
        ativo: true,
      ),
      EntregadorResponse(
        id: 2,
        nome: 'Bruno Lima',
        telefone: '1133334444',
        ativo: true,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: EntregadorPage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entregadores'), findsNothing);
    expect(find.text('2 entregadores ativos'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('Bruno Lima'), findsOneWidget);
    expect(find.text('(11) 99999-0000'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '3333');
    await tester.pump();

    expect(find.text('Ana Souza'), findsNothing);
    expect(find.text('Bruno Lima'), findsOneWidget);
    expect(find.text('1 entregador'), findsOneWidget);
  });

  testWidgets('reassemble recarrega a pagina sem quebrar o State', (
    tester,
  ) async {
    final service = _FakeEntregadorService(const [
      EntregadorResponse(
        id: 1,
        nome: 'Ana Souza',
        telefone: '11999990000',
        ativo: true,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: EntregadorPage(service: service)),
    );
    await tester.pumpAndSettle();
    expect(service.listCalls, 1);

    // O binding de widgets conclui o reassemble no frame seguinte.
    unawaited(tester.binding.reassembleApplication());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.listCalls, 2);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
