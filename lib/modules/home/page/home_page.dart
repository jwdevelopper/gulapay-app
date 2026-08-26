import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/barra_navegacao_curvada.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/entregador/page/entregador_page.dart';
import 'package:my_app_teste/modules/login/page/login_page.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_page.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/page/estoque_page.dart';
import 'package:my_app_teste/modules/comanda/page/comandas_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';
import 'package:my_app_teste/modules/unidade_medida/page/unidade_medida_page.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_list_page.dart';
import 'package:my_app_teste/modules/insumo/pages/insumos_list_page.dart';
import 'package:my_app_teste/modules/lote/page/lotes_page.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _indiceSelecionado = 0; // Índice lógico da página atual

  bool _ehAdministrador = false;

  late final List<_AbaPrincipal> _todasAbas = [
    _AbaPrincipal(
      tituloAppBar: 'Início',
      rotuloInferior: 'Início',
      icone: Icons.home_outlined,
      pagina: DashboardPage(
        onNavegarParaAba: (indice) {
          setState(() => _indiceSelecionado = indice);
        },
      ),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Mesas',
      rotuloInferior: 'Mesas',
      icone: Icons.grid_view_outlined,
      pagina: MesaPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Produtos',
      rotuloInferior: 'Produtos',
      icone: Icons.shopping_bag_outlined,
      pagina: ProdutoPage(),
    ),
    _AbaPrincipal(
      tituloAppBar: 'Comandas',
      rotuloInferior: 'Comandas',
    const _AbaPrincipal(
      tituloAppBar: 'Pedidos',
      rotuloInferior: 'Pedidos',
      icone: Icons.receipt_long_outlined,
      pagina: ComandasPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Estoque',
      rotuloInferior: 'Estoque',
      icone: Icons.inventory_2_outlined,
      pagina: EstoquePage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Categorias',
      rotuloInferior: 'Categorias',
      icone: Icons.category_outlined,
      pagina: CategoriaPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Clientes',
      rotuloInferior: 'Clientes',
      icone: Icons.groups_outlined,
      pagina: ClientePage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Insumos',
      rotuloInferior: 'Insumos',
      icone: Icons.local_grocery_store_outlined,
      pagina: InsumosListPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Lotes',
      rotuloInferior: 'Lotes',
      icone: Icons.layers_outlined,
      pagina: LotesPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Unidades de Medida',
      rotuloInferior: 'Unidades',
      icone: Icons.straighten_outlined,
      pagina: UnidadeMedidaPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Entregadores',
      rotuloInferior: 'Entregas',
      icone: Icons.delivery_dining_outlined,
      pagina: EntregadorPage(),
    ),
    const _AbaPrincipal(
      tituloAppBar: 'Usuários',
      rotuloInferior: 'Equipe',
      icone: Icons.people_outline,
      pagina: UsuarioListaPagina(),
      apenasAdmin: true,
    ),
  ];

  List<_AbaPrincipal> get _abasVisiveis =>
      _todasAbas.where((aba) => !aba.apenasAdmin || _ehAdministrador).toList();

  List<_AbaPrincipal> get _abasFixasNavBar => _abasVisiveis.where((aba) {
    return aba.rotuloInferior == 'Início' ||
        aba.rotuloInferior == 'Mesas' ||
        aba.rotuloInferior == 'Pedidos' ||
        aba.rotuloInferior == 'Clientes';
  }).toList();

  _AbaPrincipal get _abaAtual {
    final abas = _abasVisiveis;
    return abas[_indiceSelecionado.clamp(0, abas.length - 1)];
  }

  /// Menu dinâmico:
  ///
  /// - Tela SEM cadastro (Início, Mesas, Pedidos): abas fixas nas posições
  ///   naturais, bolha na aba tocada.
  /// - Tela COM cadastro ("+" visível): o item atual — aba fixa ou página
  ///   vinda do drawer — vai para o CENTRO da barra com a bolha, e o "+"
  ///   ocupa o canto direito. A curva acompanha os dois: bolha no centro,
  ///   "+" elevado no canto.
  List<_AbaPrincipal> get _itensNavBar {
    final fixas = _abasFixasNavBar;
    final atual = _abaAtual;
    final temCriacao = AcoesCriacao.de(atual.tituloAppBar) != null;

    if (!temCriacao) {
      if (fixas.contains(atual)) return fixas;
      return List<_AbaPrincipal>.of(fixas)..insert(fixas.length ~/ 2, atual);
    }

    final itens = List<_AbaPrincipal>.of(fixas)..remove(atual);
    itens.insert((itens.length + 1) ~/ 2, atual);
    return itens;
  }

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

  void _aoTocarNavBar(int indice) {
    final itens = _itensNavBar;
    if (indice >= itens.length) return;

    final indiceCompleto = _abasVisiveis.indexOf(itens[indice]);
    if (indiceCompleto >= 0) {
      setState(() => _indiceSelecionado = indiceCompleto);
    }
  }

  void _selecionarPeloMenu(int indice) {
    Navigator.pop(context);
    setState(() => _indiceSelecionado = indice);
  }

  Widget _construirMenuLateral(List<_AbaPrincipal> abas) {
    final selecionado = _indiceSelecionado.clamp(0, abas.length - 1);
    return Drawer(
      backgroundColor: AppTema.fundo,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTema.primaria),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          for (var i = 0; i < abas.length; i++)
            ListTile(
              leading: Icon(abas[i].icone),
              title: Text(abas[i].tituloAppBar),
              selected: i == selecionado,
              selectedColor: AppTema.primariaEscura,
              iconColor: AppTema.textoSecundario,
              textColor: AppTema.textoEscuro,
              selectedTileColor: AppTema.fundoDica,
              onTap: () => _selecionarPeloMenu(i),
            ),
        ],
      ),
    );
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
    final abasDrawer = _abasVisiveis;
    final itensNavBar = _itensNavBar;
    final abaAtual = _abaAtual;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTema.fundo,
      drawer: _construirMenuLateral(abasDrawer),
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
        iconTheme: const IconThemeData(color: AppTema.primariaEscura),
        elevation: 0,
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
        index: _indiceSelecionado.clamp(0, abasDrawer.length - 1),
        children: abasDrawer.map((a) => a.pagina).toList(),
      ),

      // Menu dinâmico: quando a tela atual tem cadastro (FAB "+"), o item
      // dela é remanejado para o CENTRO da barra (_itensNavBar); nas demais,
      // as abas ficam nas posições naturais. A bolha anima normalmente.
      bottomNavigationBar: BarraNavegacaoCurvada(
        altura: 65,
        indice: itensNavBar.indexOf(abaAtual),
        corFundo: AppTema.fundo,
        cor: Color.lerp(AppTema.fundo, Colors.black, 0.08)!,
        corBotao: AppTema.primaria,
        duracaoAnimacao: const Duration(milliseconds: 300),
        curvaAnimacao: Curves.easeInOut,
        itens: [
          for (final aba in itensNavBar)
            Icon(
              aba.icone,
              size: 30,
              color: aba == abaAtual ? Colors.white : AppTema.textoSecundario,
            ),
        ],
        aoTocar: _aoTocarNavBar,
      ),
    );
  }
}
