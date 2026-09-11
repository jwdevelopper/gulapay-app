import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';

/// Canais de venda de uma comanda.
///
/// Espelha o enum `TipoOrigemComanda` do backend. Os três cobrem todas as
/// formas de venda do sistema — retirada entra em `BALCAO` e pedido do
/// catálogo online entra em `DELIVERY`, conforme decidido no escopo.
///
/// Cada canal muda o que a criação exige: `MESA` pede mesa e garçom;
/// `DELIVERY` pede endereço de entrega do próprio cliente; `BALCAO` não
/// pede nenhum dos dois.
const List<OpcaoEscolha> canaisComanda = [
  OpcaoEscolha(
    rotulo: 'Mesa',
    descricao: 'Venda realizada no salão',
    valor: 'MESA',
    icone: Icons.table_restaurant_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Balcão',
    descricao: 'Venda rápida no atendimento',
    valor: 'BALCAO',
    icone: Icons.storefront_rounded,
  ),
  OpcaoEscolha(
    rotulo: 'Delivery',
    descricao: 'Entrega no endereço do cliente',
    valor: 'DELIVERY',
    icone: Icons.delivery_dining_rounded,
  ),
];
