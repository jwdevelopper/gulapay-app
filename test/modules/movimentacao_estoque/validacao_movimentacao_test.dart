import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';

void main() {
  final insumo = Insumo(id: 1, nome: 'Farinha', unidadePadraoId: 2);
  final unidade = UnidadeMedida(id: 2, nome: 'Grama', simbolo: 'g');
  final lote = Lote(id: 10, codigo: 'NF-1');

  ResultadoValidacao validar(int etapa, DadosMovimentacao dados) =>
      ValidadorMovimentacao.validarEtapa(etapa, dados);

  group('etapa 0 — tipo', () {
    test('sem tipo escolhido marca o campo e bloqueia', () {
      final r = validar(0, const DadosMovimentacao());
      expect(r.valido, isFalse);
      expect(r.erroEm(CampoMovimentacao.tipo), isTrue);
      expect(r.mensagem, 'Selecione o tipo de movimentação.');
    });

    test('com tipo escolhido avança', () {
      final r = validar(0, const DadosMovimentacao(tipo: 'ENTRADA_COMPRA'));
      expect(r.valido, isTrue);
    });
  });

  group('etapa 1 — insumo, quantidade e unidade', () {
    test('vazia acusa os três campos obrigatórios', () {
      final r = validar(1, const DadosMovimentacao(tipo: 'ENTRADA_COMPRA'));
      expect(r.camposComErro, {
        CampoMovimentacao.insumo,
        CampoMovimentacao.quantidade,
        CampoMovimentacao.unidade,
      });
      expect(r.mensagem, '3 campo(s) obrigatório(s).');
    });

    test('quantidade zero é inválida', () {
      final r = validar(
        1,
        DadosMovimentacao(
          tipo: 'ENTRADA_COMPRA',
          insumo: insumo,
          unidade: unidade,
          quantidade: '0',
        ),
      );
      expect(r.erroEm(CampoMovimentacao.quantidade), isTrue);
    });

    test('aceita vírgula como separador decimal', () {
      final r = validar(
        1,
        DadosMovimentacao(
          tipo: 'ENTRADA_COMPRA',
          insumo: insumo,
          unidade: unidade,
          quantidade: '2,5',
        ),
      );
      expect(r.valido, isTrue);
    });
  });

  group('etapa 2 — entrada (validade e custo obrigatórios)', () {
    DadosMovimentacao entrada({DateTime? validade, String custo = ''}) =>
        DadosMovimentacao(
          tipo: 'ENTRADA_COMPRA',
          insumo: insumo,
          unidade: unidade,
          quantidade: '10',
          validade: validade,
          custoUnitario: custo,
        );

    test('validade e custo vazios bloqueiam o registro', () {
      final r = validar(2, entrada());
      expect(r.valido, isFalse);
      expect(r.camposComErro, {
        CampoMovimentacao.validade,
        CampoMovimentacao.custoUnitario,
      });
    });

    test('custo zero é inválido', () {
      final r = validar(
        2,
        entrada(validade: DateTime(2026, 12, 31), custo: '0,00'),
      );
      expect(r.erroEm(CampoMovimentacao.custoUnitario), isTrue);
    });

    test('validade e custo preenchidos liberam o registro', () {
      final r = validar(
        2,
        entrada(validade: DateTime(2026, 12, 31), custo: '12,50'),
      );
      expect(r.valido, isTrue);
    });
  });

  group('etapa 2 — saída (lote obrigatório)', () {
    DadosMovimentacao saida({Lote? loteEscolhido, bool possuiLotes = true}) =>
        DadosMovimentacao(
          tipo: 'SAIDA_PERDA_QUEBRA',
          insumo: insumo,
          unidade: unidade,
          quantidade: '3',
          lote: loteEscolhido,
          possuiLotes: possuiLotes,
        );

    test('sem lote selecionado bloqueia', () {
      final r = validar(2, saida());
      expect(r.valido, isFalse);
      expect(r.erroEm(CampoMovimentacao.lote), isTrue);
    });

    test('sem lotes disponíveis explica o motivo', () {
      final r = validar(2, saida(possuiLotes: false));
      expect(r.erroEm(CampoMovimentacao.lote), isTrue);
      expect(r.mensagem, contains('Nenhum lote disponível'));
    });

    test('com lote selecionado libera', () {
      final r = validar(2, saida(loteEscolhido: lote));
      expect(r.valido, isTrue);
    });

    test('não exige validade nem custo em saída', () {
      final r = validar(2, saida(loteEscolhido: lote));
      expect(r.erroEm(CampoMovimentacao.validade), isFalse);
      expect(r.erroEm(CampoMovimentacao.custoUnitario), isFalse);
    });
  });

  group('validade no passado', () {
    final hoje = DateTime(2026, 3, 10);

    DadosMovimentacao entradaCom(DateTime validade) => DadosMovimentacao(
      tipo: 'ENTRADA_COMPRA',
      insumo: insumo,
      unidade: unidade,
      quantidade: '5',
      custoUnitario: '7,40',
      validade: validade,
    );

    test('ontem conta como passado', () {
      final ontem = DateTime(2026, 3, 9);
      expect(
        ValidadorMovimentacao.validadeNoPassado(ontem, agora: hoje),
        isTrue,
      );
    });

    test('vencer hoje ainda vale', () {
      expect(
        ValidadorMovimentacao.validadeNoPassado(hoje, agora: hoje),
        isFalse,
      );
    });

    test('a hora do dia não altera a comparação', () {
      expect(
        ValidadorMovimentacao.validadeNoPassado(
          DateTime(2026, 3, 10, 23, 59),
          agora: DateTime(2026, 3, 10, 1),
        ),
        isFalse,
      );
    });

    test('sem validade não acusa passado', () {
      expect(ValidadorMovimentacao.validadeNoPassado(null), isFalse);
    });

    test('entrada de lote já vencido é reprovada', () {
      final r = validar(2, entradaCom(DateTime(2020)));
      expect(r.valido, isFalse);
      expect(r.erroEm(CampoMovimentacao.validade), isTrue);
      expect(r.mensagem, contains('não pode ser no passado'));
    });

    test('entrada com validade futura passa', () {
      final r = validar(2, entradaCom(DateTime(2099)));
      expect(r.valido, isTrue);
    });

    test('a falta de validade ainda vem antes da regra de passado', () {
      const semData = DadosMovimentacao(
        tipo: 'ENTRADA_COMPRA',
        quantidade: '5',
        custoUnitario: '7,40',
      );
      final r = validar(2, semData);
      expect(r.erroEm(CampoMovimentacao.validade), isTrue);
      expect(r.mensagem, contains('obrigatório'));
    });
  });

  group('ResultadoValidacao.sem', () {
    test('remove apenas o campo corrigido', () {
      const r = ResultadoValidacao(
        camposComErro: {CampoMovimentacao.insumo, CampoMovimentacao.quantidade},
        mensagem: '2 campo(s) obrigatório(s).',
      );
      final depois = r.sem(CampoMovimentacao.insumo);
      expect(depois.erroEm(CampoMovimentacao.insumo), isFalse);
      expect(depois.erroEm(CampoMovimentacao.quantidade), isTrue);
    });

    test('volta a válido quando o último erro sai', () {
      const r = ResultadoValidacao(
        camposComErro: {CampoMovimentacao.tipo},
        mensagem: 'Selecione o tipo de movimentação.',
      );
      expect(r.sem(CampoMovimentacao.tipo).valido, isTrue);
    });
  });

  group('payload', () {
    test('omite campos opcionais vazios', () {
      final payload = DadosMovimentacao(
        tipo: 'SAIDA_PERDA_QUEBRA',
        insumo: insumo,
        unidade: unidade,
        quantidade: '3',
        lote: lote,
      ).paraPayload();

      expect(payload['tipo'], 'SAIDA_PERDA_QUEBRA');
      expect(payload['insumoId'], 1);
      expect(payload['unidadeId'], 2);
      expect(payload['quantidade'], 3);
      expect(payload['loteId'], 10);
      expect(payload.containsKey('validade'), isFalse);
      expect(payload.containsKey('custoUnitario'), isFalse);
      expect(payload.containsKey('justificativa'), isFalse);
    });

    test('serializa a validade em ISO para a API', () {
      final payload = DadosMovimentacao(
        tipo: 'ENTRADA_COMPRA',
        insumo: insumo,
        unidade: unidade,
        quantidade: '10',
        validade: DateTime(2026, 1, 5),
        custoUnitario: '12,50',
        codigoLote: 'NF-8821',
        justificativa: 'Compra mensal',
      ).paraPayload();

      expect(payload['validade'], '2026-01-05');
      expect(payload['custoUnitario'], 12.5);
      expect(payload['codigoLote'], 'NF-8821');
      expect(payload['justificativa'], 'Compra mensal');
    });
  });

  test('ehEntrada distingue os canais corretamente', () {
    expect(const DadosMovimentacao(tipo: 'ENTRADA_COMPRA').ehEntrada, isTrue);
    expect(const DadosMovimentacao(tipo: 'ENTRADA_TROCA').ehEntrada, isTrue);
    expect(
      const DadosMovimentacao(tipo: 'SAIDA_PERDA_QUEBRA').ehEntrada,
      isFalse,
    );
    expect(
      const DadosMovimentacao(tipo: 'AJUSTE_INVENTARIO').ehEntrada,
      isFalse,
    );
  });
}
