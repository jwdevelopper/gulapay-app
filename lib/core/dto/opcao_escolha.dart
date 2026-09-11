import 'package:flutter/material.dart';

/// Opção de uma escolha entre alternativas fixas, exibida como cartão ou
/// item de lista em formulários.
///
/// Fonte única desse formato. A mesma estrutura estava declarada como
/// classe privada em quatro lugares — `_ChoiceOption` no formulário de
/// produto e no de movimentação, `_CanalOption` no de comanda e
/// `OpcaoTipoMovimentacao` no módulo de estoque — sempre com os mesmos
/// quatro campos.
///
/// [valor] é o que vai para a API (normalmente um valor de enum do
/// backend, como `'ENTRADA_COMPRA'` ou `'MESA'`); [rotulo] e [descricao]
/// são o texto apresentado ao usuário.
///
/// ## Exemplo
///
/// ```dart
/// const canaisComanda = <OpcaoEscolha>[
///   OpcaoEscolha(
///     rotulo: 'Mesa',
///     descricao: 'Venda realizada no salão',
///     valor: 'MESA',
///     icone: Icons.table_restaurant_rounded,
///   ),
///   // ...
/// ];
///
/// // Rótulo amigável a partir do valor cru vindo da API:
/// final texto = rotuloDaOpcao(canaisComanda, comanda.tipoOrigem);
/// ```
class OpcaoEscolha {
  /// Nome curto exibido em destaque.
  final String rotulo;

  /// Linha de apoio que explica a opção.
  final String descricao;

  /// Valor enviado à API — normalmente um enum do backend.
  final String valor;

  /// Ícone ilustrativo.
  final IconData icone;

  const OpcaoEscolha({
    required this.rotulo,
    required this.descricao,
    required this.valor,
    required this.icone,
  });
}

/// Procura a opção cujo [OpcaoEscolha.valor] corresponde a [valor] e
/// devolve seu rótulo; cai em [sePadrao] quando nada corresponde (valor
/// nulo, ou vindo da API sem opção cadastrada na tela).
String rotuloDaOpcao(
  List<OpcaoEscolha> opcoes,
  String? valor, {
  String sePadrao = '-',
}) {
  for (final opcao in opcoes) {
    if (opcao.valor == valor) return opcao.rotulo;
  }
  return sePadrao;
}
