import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';

/// Tipos de movimentação oferecidos no formulário.
///
/// Espelha o enum `TipoMovimentacao` do backend, menos `SAIDA_VENDA`: essa
/// é gerada automaticamente pelo fechamento de comanda e o backend bloqueia
/// seu lançamento manual pela API.
///
/// As duas entradas (`ENTRADA_COMPRA` e `ENTRADA_TROCA`) criam lote novo e
/// por isso pedem validade e custo; as demais baixam de um lote existente.
const List<OpcaoEscolha> tiposMovimentacao = [
  OpcaoEscolha(
    rotulo: 'Compra',
    descricao: 'Entrada de fornecedor',
    valor: 'ENTRADA_COMPRA',
    icone: Icons.shopping_cart_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Perda validade',
    descricao: 'Insumo vencido',
    valor: 'SAIDA_PERDA_VALIDADE',
    icone: Icons.timer_off_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Perda quebra',
    descricao: 'Quebra/avaria',
    valor: 'SAIDA_PERDA_QUEBRA',
    icone: Icons.broken_image_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Troca',
    descricao: 'Entrada por troca',
    valor: 'ENTRADA_TROCA',
    icone: Icons.swap_horiz_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Ajuste de inventário',
    descricao: 'Corrige saldo pós-contagem física',
    valor: 'AJUSTE_INVENTARIO',
    icone: Icons.tune_rounded,
  ),
];

/// Rótulo amigável de um tipo de movimentação.
///
/// Atalho sobre [rotuloDaOpcao] com a lista já fixada e o padrão que o
/// cabeçalho do formulário usa quando nada foi escolhido.
String rotuloTipoMovimentacao(
  String? valor, {
  String sePadrao = 'Nova movimentação',
}) => rotuloDaOpcao(tiposMovimentacao, valor, sePadrao: sePadrao);
