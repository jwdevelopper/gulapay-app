import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';

/// Tipos de produto oferecidos no formulário.
///
/// Espelha o enum `TipoProduto` do backend e define como o produto baixa
/// estoque: `UNITARIO` dá baixa direta no insumo vinculado, `COMPOSTO`
/// baixa pela ficha técnica e `COMBO` explode recursivamente os
/// componentes.
const List<OpcaoEscolha> tiposProduto = [
  OpcaoEscolha(
    rotulo: 'Unitário',
    descricao: 'Produto vendido por unidade',
    valor: 'UNITARIO',
    icone: Icons.inventory_2_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Composto',
    descricao: 'Produto composto por insumos',
    valor: 'COMPOSTO',
    icone: Icons.layers_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Combo',
    descricao: 'Conjunto de itens',
    valor: 'COMBO',
    icone: Icons.local_offer_rounded,
  ),
];

/// Setores de produção — para onde o pedido é impresso quando o item é
/// lançado. Espelha o enum `SetorProducao` do backend.
const List<OpcaoEscolha> setoresProducao = [
  OpcaoEscolha(
    rotulo: 'Cozinha',
    descricao: 'Pratos quentes, pré-preparo',
    valor: 'COZINHA',
    icone: Icons.dining_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Bar',
    descricao: 'Bebidas, drinks, vinhos',
    valor: 'BAR',
    icone: Icons.wine_bar_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Balcão',
    descricao: 'Atendimento no balcão',
    valor: 'BALCAO',
    icone: Icons.storefront_rounded,
  ),
];
