import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_page.dart';
import 'package:my_app_teste/modules/comanda/page/comandas_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/entregador/page/entregador_page.dart';
import 'package:my_app_teste/modules/home/dto/aba_principal.dart';
import 'package:my_app_teste/modules/insumo/page/insumos_list_page.dart';
import 'package:my_app_teste/modules/lote/page/lotes_page.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_page.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/page/estoque_page.dart';
import 'package:my_app_teste/modules/pedidos/page/pedidos_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';
import 'package:my_app_teste/modules/unidade_medida/page/unidade_medida_page.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_list_page.dart';

/// Títulos das abas que outras telas precisam abrir por atalho.
///
/// Navegar por título, e não pelo índice na lista, é o que impede um
/// atalho de apontar para a tela errada quando uma aba entra ou sai do
/// meio do menu — foi o que aconteceu com os atalhos do painel inicial.
class TitulosAba {
  const TitulosAba._();

  static const inicio = 'Início';
  static const mesas = 'Mesas';
  static const produtos = 'Produtos';
  static const comandas = 'Comandas';
  static const pedidos = 'Pedidos';
  static const estoque = 'Estoque';
  static const categorias = 'Categorias';
  static const clientes = 'Clientes';
}

/// Índice da aba com este título, ou `-1` quando ela não está visível ao
/// perfil atual.
int indiceDaAba(List<AbaPrincipal> abas, String titulo) =>
    abas.indexWhere((aba) => aba.tituloAppBar == titulo);

/// O catálogo de abas do app, na ordem em que aparecem no menu.
///
/// É o único lugar que sabe quais telas existem e quem as vê. A [Home] só
/// consome esta lista: filtra por perfil, monta o drawer, a barra inferior
/// e o `IndexedStack`.
///
/// [aoAbrirAba] é repassado ao painel inicial, que oferece atalhos para
/// outras telas — ele pede a troca pelo título, e quem controla o índice
/// resolve.
///
/// A ordem importa: o índice de cada aba nesta lista é o índice do
/// `IndexedStack`, e a primeira é a que abre ao entrar no app.
List<AbaPrincipal> construirAbas({required ValueChanged<String> aoAbrirAba}) =>
    [
      AbaPrincipal(
        tituloAppBar: TitulosAba.inicio,
        rotuloInferior: 'Início',
        icone: Icons.home_outlined,
        fixaNaBarra: true,
        pagina: DashboardPage(aoAbrirAba: aoAbrirAba),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.mesas,
        rotuloInferior: 'Mesas',
        icone: Icons.grid_view_outlined,
        fixaNaBarra: true,
        pagina: MesaPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.produtos,
        rotuloInferior: 'Produtos',
        icone: Icons.shopping_bag_outlined,
        pagina: ProdutoPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.comandas,
        rotuloInferior: 'Comandas',
        icone: Icons.receipt_long_outlined,
        pagina: ComandasPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.pedidos,
        rotuloInferior: 'Pedidos',
        icone: Icons.list_alt_outlined,
        fixaNaBarra: true,
        pagina: PedidosPagina(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.estoque,
        rotuloInferior: 'Estoque',
        icone: Icons.inventory_2_outlined,
        pagina: EstoquePage(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.categorias,
        rotuloInferior: 'Categorias',
        icone: Icons.category_outlined,
        pagina: CategoriaPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: TitulosAba.clientes,
        rotuloInferior: 'Clientes',
        icone: Icons.groups_outlined,
        fixaNaBarra: true,
        pagina: ClientePage(),
      ),
      const AbaPrincipal(
        tituloAppBar: 'Insumos',
        rotuloInferior: 'Insumos',
        icone: Icons.local_grocery_store_outlined,
        pagina: InsumosListPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: 'Lotes',
        rotuloInferior: 'Lotes',
        icone: Icons.layers_outlined,
        pagina: LotesPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: 'Unidades de Medida',
        rotuloInferior: 'Unidades',
        icone: Icons.straighten_outlined,
        pagina: UnidadeMedidaPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: 'Entregadores',
        rotuloInferior: 'Entregas',
        icone: Icons.delivery_dining_outlined,
        pagina: EntregadorPage(),
      ),
      const AbaPrincipal(
        tituloAppBar: 'Usuários',
        rotuloInferior: 'Equipe',
        icone: Icons.people_outline,
        apenasAdmin: true,
        pagina: UsuarioListaPagina(),
      ),
    ];
