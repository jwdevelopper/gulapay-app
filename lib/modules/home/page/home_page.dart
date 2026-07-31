import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/login/page/login_page.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/page/estoque_page.dart';
import 'package:my_app_teste/modules/pedidos/page/pedidos_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_list_page.dart';
import 'package:my_app_teste/modules/insumo/pages/insumos_list_page.dart';
import 'package:my_app_teste/modules/lote/page/lotes_page.dart';
import 'package:my_app_teste/shared/bottom_bar/bottom_bar.dart';

class _AbaPrincipal {
  final String tituloAppBar;
  final String rotuloInferior;
  final IconData icone;
  final Widget pagina;
  final bool apenasAdmin;

  const _AbaPrincipal({
    required this.tituloAppBar,
    required this.rotuloInferior,
    required this.icone,
    required this.pagina,
    this.apenasAdmin = false,
  });
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const List<_AbaPrincipal> _todasAbas = [
    _AbaPrincipal(
      tituloAppBar: 'Início',
      rotuloInferior: 'Início',
      icone: Icons.home_outlined,
      pagina: DashboardPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Produtos',
      rotuloInferior: 'Produtos',
      icone: Icons.shopping_bag_outlined,
      pagina: ProdutoPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Pedidos',
      rotuloInferior: 'Pedidos',
      icone: Icons.receipt_long_outlined,
      pagina: PedidosPagina(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Estoque',
      rotuloInferior: 'Estoque',
      icone: Icons.inventory_2_outlined,
      pagina: EstoquePage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Categorias',
      rotuloInferior: 'Categorias',
      icone: Icons.category_outlined,
      pagina: CategoriaPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Insumos',
      rotuloInferior: 'Insumos',
      icone: Icons.local_grocery_store_outlined,
      pagina: InsumosListPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Lotes',
      rotuloInferior: 'Lotes',
      icone: Icons.layers_outlined,
      pagina: LotesPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Usuários',
      rotuloInferior: 'Equipe',
      icone: Icons.people_outline,
      pagina: UsuarioListaPagina(),
      apenasAdmin: true,
    ),
  ];

  int _indiceSelecionado = 0;
  bool _ehAdministrador = false;

  List<_AbaPrincipal> get _abasVisiveis => _todasAbas
      .where((aba) => !aba.apenasAdmin || _ehAdministrador)
      .toList();

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final admin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() {
      _ehAdministrador = admin;
      if (_indiceSelecionado >= _abasVisiveis.length) {
        _indiceSelecionado = 0;
      }
    });
  }

  void _aoTocarAba(int indice) {
    setState(() => _indiceSelecionado = indice);
  }

  Future<void> _confirmarLogout() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja encerrar a sessão?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
    if (sair != true || !mounted) return;
    await ApiClient.removerToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _abrirNotificacoes() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTema.cartao,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTema.textoEscuro,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma notificação no momento.',
                  style: TextStyle(
                    color: AppTema.textoSecundario,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final abas = _abasVisiveis;
    final abaAtual =
        _indiceSelecionado < abas.length ? abas[_indiceSelecionado] : abas.first;

    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        title: Text(
          abaAtual.tituloAppBar,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTema.textoEscuro,
          ),
        ),
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Notificações',
            onPressed: _abrirNotificacoes,
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _confirmarLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTema.bordaCampo),
        ),
      ),
      body: IndexedStack(
        index: _indiceSelecionado.clamp(0, abas.length - 1),
        children: abas.map((a) => a.pagina).toList(),
      ),
      bottomNavigationBar: BottomBar(
        items: abas
            .map(
              (a) =>
                  BottomBarItem(label: a.rotuloInferior, icon: a.icone),
            )
            .toList(),
        selectedIndex: _indiceSelecionado.clamp(0, abas.length - 1),
        onTap: _aoTocarAba,
        backgroundColor: AppTema.cartao,
        borderColor: AppTema.bordaCampo,
        activeColor: AppTema.primariaEscura,
        inactiveColor: AppTema.textoSecundario,
        activeIndicatorColor: AppTema.fundoDica,
      ),
    );
  }
}
