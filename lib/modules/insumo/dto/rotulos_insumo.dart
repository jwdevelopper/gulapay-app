import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

/// Ícones, cores e formatações da listagem de insumos.
///
/// Único lugar que decide como um insumo aparece. Antes eram cinco métodos
/// privados dentro do `State` da listagem.
class RotulosInsumo {
  const RotulosInsumo._();

  /// Quantidade em estoque com o símbolo da unidade.
  static String estoque(InsumoResponse insumo) {
    final quantidade = formatarNumeroBr(
      insumo.estoqueAtual ?? 0,
      casas: null,
      vazio: '0',
    );
    return '$quantidade ${insumo.unidadePadraoSimbolo ?? ''}'.trim();
  }

  /// Quanto o saldo está acima (positivo) ou abaixo (negativo) do mínimo,
  /// em porcentagem.
  ///
  /// Devolve `null` quando o mínimo é zero — sem referência não há
  /// percentual, e dividir por zero daria infinito.
  static double? percentualVsMinimo(InsumoResponse insumo) {
    final minimo = insumo.estoqueMinimo ?? 0;
    if (minimo == 0) return null;
    return (((insumo.estoqueAtual ?? 0) - minimo) / minimo) * 100;
  }

  /// Cor da barra de estoque: verde em dia, laranja pouco abaixo do mínimo,
  /// vermelho quando a falta passa de 30% — a diferença entre "repor esta
  /// semana" e "repor hoje".
  static Color corDaBarra(InsumoResponse insumo) {
    if (insumo.abaixoDoMinimo != true) return AppTema.sucesso;
    final percentual = percentualVsMinimo(insumo) ?? 0;
    return percentual < -30 ? AppTema.erro : AppTema.avisoBorda;
  }

  /// Cor de destaque do card, estável por nome — a mesma lógica da vitrine
  /// de produtos, para as duas listas parecerem da mesma família.
  static Color corDestaque(InsumoResponse insumo) {
    final semente = (insumo.nome ?? '').isEmpty ? 'insumo' : insumo.nome!;
    return _paletaDestaque[semente.hashCode.abs() % _paletaDestaque.length];
  }

  static const _paletaDestaque = <Color>[
    Color(0xFFF8C39C),
    Color(0xFFF6C48A),
    Color(0xFFE7C7F3),
    Color(0xFFF3D0A3),
    Color(0xFFDCE7C1),
  ];

  /// Ícone deduzido do nome do insumo.
  ///
  /// O cadastro não tem campo de ícone; enquanto não tiver, o nome é a
  /// única pista. Cada família tem os termos mais comuns da cozinha.
  static IconData icone(InsumoResponse insumo) {
    final nome = (insumo.nome ?? '').toLowerCase();
    for (final familia in _familias) {
      if (familia.termos.any(nome.contains)) return familia.icone;
    }
    return Icons.inventory_2_rounded;
  }

  static const _familias = <({List<String> termos, IconData icone})>[
    (
      termos: ['tomate', 'alface', 'cebola', 'legume', 'verdura'],
      icone: Icons.eco_rounded,
    ),
    (
      termos: ['queijo', 'leite', 'mussarela', 'manteiga', 'creme'],
      icone: Icons.icecream_rounded,
    ),
    (
      termos: ['carne', 'picanha', 'frango', 'peixe', 'bacon'],
      icone: Icons.set_meal_rounded,
    ),
    (
      termos: ['vinho', 'cerveja', 'refri', 'suco', 'agua'],
      icone: Icons.wine_bar_rounded,
    ),
    (
      termos: ['macarrao', 'macarrão', 'arroz', 'feijao', 'feijão'],
      icone: Icons.rice_bowl_rounded,
    ),
  ];
}
