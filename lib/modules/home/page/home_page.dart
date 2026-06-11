import 'package:flutter/material.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/cliente/page/cliente_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';
import 'package:my_app_teste/modules/unidade_medida/page/unidade_medida_page.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_list_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _indiceInicio = 0;
  static const _indiceUsuarios = 1;
  static const _indiceCategoria = 2;
  static const _indiceProduto = 3;
  static const _indiceClientes = 4;
  static const _indiceUnidades = 5;

  int _indiceSelecionado = _indiceInicio;
  bool _ehAdministrador = false;

  final List<Widget> _paginas = const [
    DashboardPage(),
    UsuarioListaPagina(),
    CategoriaPage(),
    ProdutoPage(),
    ClientePage(),
    UnidadeMedidaPage(),
  ];

  static const _titulos = [
    'Início',
    'Usuários',
    'Categoria',
    'Produto',
    'Clientes',
    'Unidades de Medida',
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final admin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() => _ehAdministrador = admin);
  }

  void _selecionar(int indice) {
    Navigator.pop(context);
    setState(() => _indiceSelecionado = indice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        title: Text(
          _titulos[_indiceSelecionado],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTema.textoEscuro,
          ),
        ),
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTema.primariaEscura),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTema.bordaCampo),
        ),
      ),
      onDrawerChanged: (aberto) {
        if (aberto) _carregarPerfil();
      },
      drawer: Drawer(
        backgroundColor: AppTema.fundo,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppTema.primaria),
              child: Text('Menu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              selected: _indiceSelecionado == _indiceInicio,
              onTap: () => _selecionar(_indiceInicio),
            ),
            if (_ehAdministrador)
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Usuários'),
                selected: _indiceSelecionado == _indiceUsuarios,
                onTap: () => _selecionar(_indiceUsuarios),
              ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categoria'),
              selected: _indiceSelecionado == _indiceCategoria,
              onTap: () => _selecionar(_indiceCategoria),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Produto'),
              selected: _indiceSelecionado == _indiceProduto,
              onTap: () => _selecionar(_indiceProduto),
            ),
            
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text('Clientes'),
              selected: _indiceSelecionado == _indiceClientes,
              onTap: () => _selecionar(_indiceClientes),
            ),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Unidades de Medida'),
              selected: _indiceSelecionado == _indiceUnidades,
              onTap: () => _selecionar(_indiceUnidades),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _indiceSelecionado, children: _paginas),
    );
  }
}
