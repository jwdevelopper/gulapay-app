import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';

/// Formas de pagamento aceitas.
///
/// Espelha o enum `FormaPagamento` do backend (seção 3.7). Os valores
/// precisam bater exatamente — `CREDITO`, não `CARTAO_CREDITO` — senão o
/// backend recusa o registro.
///
/// O registro é **estático**: não há integração com maquininha ou gateway.
/// O caixa informa o que recebeu e o sistema apenas anota.
const List<OpcaoEscolha> formasPagamento = [
  OpcaoEscolha(
    rotulo: 'Dinheiro',
    descricao: 'Entra na gaveta e na conferência do caixa',
    valor: 'DINHEIRO',
    icone: Icons.payments_outlined,
  ),
  OpcaoEscolha(
    rotulo: 'PIX',
    descricao: 'Transferência instantânea',
    valor: 'PIX',
    icone: Icons.pix_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Crédito',
    descricao: 'Cartão de crédito',
    valor: 'CREDITO',
    icone: Icons.credit_card_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Débito',
    descricao: 'Cartão de débito',
    valor: 'DEBITO',
    icone: Icons.credit_score_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Vale-alimentação',
    descricao: 'Cartão de benefício',
    valor: 'VALE_ALIMENTACAO',
    icone: Icons.card_giftcard_rounded,
  ),
];

/// Rótulo amigável de uma forma de pagamento.
String rotuloFormaPagamento(String? valor) =>
    rotuloDaOpcao(formasPagamento, valor, sePadrao: valor ?? '—');

/// Só o dinheiro passa pela gaveta.
///
/// Espelha `FormaPagamento.afetaSaldoFisico()` do backend: as demais
/// formas entram no faturamento, mas não na conferência física do caixa.
bool afetaSaldoDoCaixa(String? valor) => valor == 'DINHEIRO';
