import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Traduções e cores dos enums de Comanda vindos da API.
///
/// O backend devolve os valores crus (`'AGUARDANDO_PAGAMENTO'`,
/// `'EM_PREPARO'`, `'LANCAMENTO_INCORRETO'`); estas funções são o único
/// lugar que converte isso em texto e cor de tela. Antes viviam como
/// métodos privados dentro do `State` da página de detalhe, o que impedia
/// reaproveitá-las nos widgets extraídos.
///
/// Todas caem em um padrão seguro quando o valor não é reconhecido — a API
/// pode ganhar um estado novo sem quebrar a tela.
class RotulosComanda {
  const RotulosComanda._();

  /// Canal de venda: `MESA`, `BALCAO`, `DELIVERY`.
  static String origem(String valor) => switch (valor) {
    'MESA' => 'Mesa',
    'BALCAO' => 'Balcão',
    'DELIVERY' => 'Delivery',
    _ => valor,
  };

  static IconData iconeOrigem(String valor) => switch (valor) {
    'MESA' => Icons.table_restaurant_rounded,
    'DELIVERY' => Icons.delivery_dining_rounded,
    _ => Icons.storefront_rounded,
  };

  /// Status da comanda: `ABERTA`, `AGUARDANDO_PAGAMENTO`, `FECHADA`,
  /// `CANCELADA`.
  static String status(String valor) => switch (valor) {
    'ABERTA' => 'Aberta',
    'AGUARDANDO_PAGAMENTO' => 'Aguardando pagamento',
    'FECHADA' => 'Fechada',
    'CANCELADA' => 'Cancelada',
    _ => valor.replaceAll('_', ' '),
  };

  /// Cor do status da comanda, nas mesmas chaves de [status].
  static Color corStatus(String valor) => switch (valor) {
    'FECHADA' => AppTema.sucesso,
    'CANCELADA' => AppTema.erro,
    'AGUARDANDO_PAGAMENTO' => Colors.orange,
    _ => AppTema.primaria,
  };

  /// Status de um item: `EM_PREPARO`, `ENTREGUE`, `CANCELADO`,
  /// `TRANSFERIDO`.
  static String statusItem(String valor) => switch (valor) {
    'EM_PREPARO' => 'Em preparo',
    'ENTREGUE' => 'Entregue',
    'CANCELADO' => 'Cancelado',
    'TRANSFERIDO' => 'Transferido',
    _ => valor.replaceAll('_', ' '),
  };

  static Color corStatusItem(String valor) => switch (valor) {
    'EM_PREPARO' => AppTema.primaria,
    'ENTREGUE' => AppTema.sucesso,
    'CANCELADO' => AppTema.erro,
    'TRANSFERIDO' => Colors.blueGrey,
    _ => AppTema.textoSecundario,
  };

  /// Ação registrada na auditoria do item (RNF09).
  static String acaoEvento(String valor) => switch (valor) {
    'CRIADO' => 'Criado',
    'EDITADO' => 'Editado',
    'TRANSFERIDO' => 'Transferido',
    'CANCELADO' => 'Cancelado',
    'ENTREGUE' => 'Entregue',
    _ => valor,
  };

  /// Valor monetário no formato brasileiro (`R$ 12,50`).
  static String dinheiro(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Motivos aceitos ao cancelar um item, conforme o enum
/// `MotivoCancelamentoItem` do backend. O motivo é obrigatório em qualquer
/// cancelamento (RN-ITEM-02).
const motivosCancelamentoItem = <String, String>{
  'LANCAMENTO_INCORRETO': 'Lançamento incorreto',
  'CLIENTE_DESISTIU': 'Cliente desistiu',
  'CORTESIA': 'Cortesia',
  'ERRO_PRODUCAO': 'Erro de produção',
};
