import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel_acao.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_form_campos.dart';

void main() {
  testWidgets('configura a descrição da categoria como área de texto', (
    tester,
  ) async {
    final controleNome = TextEditingController();
    final controleDescricao = TextEditingController();
    addTearDown(controleNome.dispose);
    addTearDown(controleDescricao.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: CategoriaFormCampos(
              controleNome: controleNome,
              controleDescricao: controleDescricao,
              limiteNome: 100,
              limiteDescricao: 255,
              aoMudar: () {},
            ),
          ),
        ),
      ),
    );

    final descricao = tester.widget<EditableText>(
      find.byType(EditableText).at(1),
    );
    expect(descricao.minLines, 3);
    expect(descricao.maxLines, 4);
    expect(descricao.keyboardType, TextInputType.multiline);
  });

  testWidgets('confirma a reativação ao soltar após metade do cartão', (
    tester,
  ) async {
    var confirmacoes = 0;
    const chaveGesto = ValueKey('categoria-inativa');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: AppCartaoDeslizavel(
              chave: 'categoria-inativa',
              acao: const AppCartaoDeslizavelAcao(
                rotulo: 'Reativar',
                icone: Icons.restart_alt,
                cor: Color(0xFF2E8B57),
              ),
              aoConfirmarAcao: () async {
                confirmacoes++;
                return false;
              },
              aoConcluir: () {},
              child: const SizedBox(width: 300, height: 72),
            ),
          ),
        ),
      ),
    );

    final gesto = await tester.startGesture(
      tester.getCenter(find.byKey(chaveGesto)),
    );
    final largura = tester.getSize(find.byKey(chaveGesto)).width;
    await gesto.moveBy(Offset(-(largura * 0.51), 0));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Reativar'), findsOneWidget);
    await gesto.up();
    await tester.pumpAndSettle();

    expect(confirmacoes, 1);
  });
}
