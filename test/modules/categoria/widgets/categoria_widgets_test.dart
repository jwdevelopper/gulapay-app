import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_form_campos.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_gesto_status.dart';

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
    const chaveGesto = ValueKey('categoria_categoria-inativa');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: CategoriaGestoStatus(
              chave: 'categoria-inativa',
              ativa: false,
              aoConfirmar: () async {
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

    final largura = tester.getSize(find.byKey(chaveGesto)).width;
    await tester.drag(find.byKey(chaveGesto), Offset(-(largura * 0.51), 0));
    await tester.pumpAndSettle();

    expect(confirmacoes, 1);
  });
}
