import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

/// Traduções, ícones e cores do módulo de produto.
///
/// Único lugar que converte os enums crus da API (`COZINHA`, `UNITARIO`) em
/// texto, ícone e cor de tela. Antes eram seis métodos privados dentro do
/// `State` da vitrine, o que impedia reaproveitá-los nos widgets extraídos.
class RotulosProduto {
  const RotulosProduto._();

  /// Setor de produção: `COZINHA`, `BAR`, `CAIXA`.
  static String setor(String? valor) => switch (valor) {
    'COZINHA' => 'Cozinha',
    'BAR' => 'Bar',
    'CAIXA' => 'Caixa',
    _ => (valor ?? '').isEmpty ? '-' : valor!,
  };

  /// Cor que identifica o setor no card — é o que deixa o garçom localizar
  /// de relance o que sai do bar e o que sai da cozinha.
  static Color corSetor(String? valor) {
    final normalizado = (valor ?? '').toUpperCase();
    if (normalizado.contains('BAR')) return _roxoBar;
    if (normalizado.contains('CAIXA')) return _verdeCaixa;
    return _laranjaCozinha;
  }

  static const _roxoBar = Color(0xFFB182D1);
  static const _verdeCaixa = Color(0xFF8FB37A);
  static const _laranjaCozinha = Color(0xFFDA8F56);

  /// Ícone de uma categoria, deduzido do nome.
  ///
  /// O cadastro de categoria não tem campo de ícone; enquanto não tiver,
  /// o nome é a única pista disponível.
  static IconData iconeDaCategoria(String nome) {
    final texto = nome.toLowerCase();
    if (texto.contains('beb')) return Icons.local_bar_rounded;
    if (texto.contains('sob')) return Icons.cake_rounded;
    if (texto.contains('entr')) return Icons.ramen_dining_rounded;
    if (texto.contains('por')) return Icons.fastfood_rounded;
    if (texto.contains('prato') || texto.contains('principal')) {
      return Icons.dinner_dining_rounded;
    }
    return Icons.restaurant_rounded;
  }

  /// Ícone de um produto: tenta o tipo, depois o nome da categoria.
  static IconData iconeDoProduto(Produto produto, String nomeCategoria) {
    final tipo = (produto.tipoProduto ?? '').toUpperCase();
    if (tipo.contains('BEBIDA')) return Icons.local_bar_rounded;
    if (tipo.contains('SOBREMESA')) return Icons.cake_rounded;
    if (tipo.contains('PORCAO')) return Icons.fastfood_rounded;
    if (tipo.contains('PRATO')) return Icons.dinner_dining_rounded;
    return iconeDaCategoria(nomeCategoria);
  }

  /// Cor de destaque do card, estável por categoria.
  ///
  /// Deriva do nome da categoria (ou do produto, quando não há categoria),
  /// então produtos da mesma categoria saem sempre com a mesma cor — o que
  /// dá à vitrine variedade sem virar aleatoriedade a cada carga.
  static Color corDestaque(Produto produto, String nomeCategoria) {
    final semente = nomeCategoria.isEmpty ? produto.nome : nomeCategoria;
    return _paletaDestaque[semente.hashCode.abs() % _paletaDestaque.length];
  }

  static const _paletaDestaque = <Color>[
    Color(0xFFF8C39C),
    Color(0xFFF6C48A),
    Color(0xFFE7C7F3),
    Color(0xFFF3D0A3),
    Color(0xFFDCE7C1),
  ];

  /// Preço no formato brasileiro. Produto sem preço vale zero na vitrine.
  static String preco(double? valor) => formatarMoedaBr(valor ?? 0);

  /// Cor sólida do tema, para quando o destaque não se aplica.
  static const corPadrao = AppTema.primaria;
}
