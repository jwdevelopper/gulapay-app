import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/pagamento/dto/forma_pagamento.dart';
import 'package:my_app_teste/modules/pagamento/dto/pagamento_response.dart';

void main() {
  group('formas de pagamento', () {
    test('os valores batem com o enum do backend', () {
      // Se divergirem, o backend recusa o registro. O PR original usava
      // CARTAO_CREDITO / CARTAO_DEBITO, que nao existem la.
      expect(formasPagamento.map((f) => f.valor).toSet(), {
        'DINHEIRO',
        'PIX',
        'CREDITO',
        'DEBITO',
        'VALE_ALIMENTACAO',
      });
    });

    test('traduz para texto de tela', () {
      expect(rotuloFormaPagamento('CREDITO'), 'Crédito');
      expect(rotuloFormaPagamento('VALE_ALIMENTACAO'), 'Vale-alimentação');
    });

    test('valor desconhecido volta como veio', () {
      expect(rotuloFormaPagamento('BITCOIN'), 'BITCOIN');
      expect(rotuloFormaPagamento(null), '—');
    });

    test('só dinheiro entra na conferência da gaveta', () {
      expect(afetaSaldoDoCaixa('DINHEIRO'), isTrue);
      for (final outra in ['PIX', 'CREDITO', 'DEBITO', 'VALE_ALIMENTACAO']) {
        expect(afetaSaldoDoCaixa(outra), isFalse, reason: outra);
      }
    });
  });

  group('PagamentoResponse', () {
    test('lê o retorno do backend', () {
      final p = PagamentoResponse.fromJson({
        'id': 7,
        'comandaId': 3,
        'comandaCodigo': 'M-12-001',
        'caixaId': 1,
        'formaPagamento': 'PIX',
        'valor': 45.5,
        'status': 'ATIVO',
        'registradoPor': 'maria',
      });
      expect(p.id, 7);
      expect(p.valor, 45.5);
      expect(p.formaPagamento, 'PIX');
      expect(p.ativo, isTrue);
    });

    test('pagamento cancelado não conta como ativo', () {
      final p = PagamentoResponse.fromJson({'status': 'CANCELADO'});
      expect(p.ativo, isFalse);
    });

    test('valor em string ainda é lido', () {
      final p = PagamentoResponse.fromJson({'valor': '12.30'});
      expect(p.valor, 12.3);
    });
  });

  group('PagamentosDaComanda', () {
    test('lê a situação e a lista', () {
      final s = PagamentosDaComanda.fromJson({
        'comandaId': 3,
        'totalDevido': 100.0,
        'totalPago': 40.0,
        'saldoRestante': 60.0,
        'pagamentos': [
          {'id': 1, 'valor': 40.0, 'formaPagamento': 'DINHEIRO'},
        ],
      });
      expect(s.totalDevido, 100.0);
      expect(s.saldoRestante, 60.0);
      expect(s.pagamentos.single.valor, 40.0);
      expect(s.quitada, isFalse);
    });

    test('saldo zerado significa quitada', () {
      final s = PagamentosDaComanda.fromJson({'saldoRestante': 0.0});
      expect(s.quitada, isTrue);
    });

    test('resposta sem lista de pagamentos não quebra', () {
      final s = PagamentosDaComanda.fromJson({'totalDevido': 10.0});
      expect(s.pagamentos, isEmpty);
    });
  });
}
