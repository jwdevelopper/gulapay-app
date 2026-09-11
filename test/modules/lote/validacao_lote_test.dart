import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/lote/dto/validacao_lote.dart';

void main() {
  group('código do lote', () {
    test('é opcional', () {
      expect(ValidadorLote.validarCodigo(''), isNull);
      expect(ValidadorLote.validarCodigo('   '), isNull);
      expect(ValidadorLote.validarCodigo(null), isNull);
    });

    test('aceita letras e números', () {
      expect(ValidadorLote.validarCodigo('L0241'), isNull);
      expect(ValidadorLote.validarCodigo('abc123'), isNull);
    });

    test('recusa pontuação e espaço', () {
      expect(ValidadorLote.validarCodigo('L-0241'), isNotNull);
      expect(ValidadorLote.validarCodigo('L 0241'), isNotNull);
      expect(ValidadorLote.validarCodigo('L/241'), isNotNull);
    });

    test('recusa código longo demais', () {
      final longo = 'A' * (ValidadorLote.codigoTamanhoMaximo + 1);
      expect(ValidadorLote.validarCodigo(longo), isNotNull);
    });

    test('o código inválido reprova o formulário', () {
      final dados = DadosLote(
        ehEdicao: true,
        validade: DateTime(2030, 1, 1),
        codigo: 'L-0241',
      );
      expect(ValidadorLote.validar(dados), isNotNull);
    });
  });

  group('formulário', () {
    final validade = DateTime(2030, 1, 1);

    test('edição passa com validade e código válido', () {
      final dados = DadosLote(
        ehEdicao: true,
        validade: validade,
        codigo: 'L0241',
      );
      expect(ValidadorLote.validar(dados), isNull);
    });

    test('edição sem validade não passa', () {
      const dados = DadosLote(ehEdicao: true);
      expect(ValidadorLote.validar(dados), 'Informe a validade.');
    });

    test('criação exige insumo antes de tudo', () {
      final dados = DadosLote(validade: validade);
      expect(ValidadorLote.validar(dados), 'Selecione o insumo.');
    });
  });
}
