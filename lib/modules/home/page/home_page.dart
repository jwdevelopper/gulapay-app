import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    const DashboardPage(),
    const CategoriaPage(),
    ProdutoPage(onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer()),
  ];

  String get _title {
    switch (_selectedIndex) {
      case 1:
        return 'Categoria';
      default:
        return 'Home';
    }
  }

  void _selectIndex(int index) {
    Navigator.of(context).pop();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showShell = _selectedIndex != 2;

    return Scaffold(
      key: _scaffoldKey,
      appBar: showShell ? AppBar(title: Text(_title)) : null,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _selectIndex(0),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Usuario'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categoria'),
              onTap: () => _selectIndex(1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Produto'),
              onTap: () => _selectIndex(2),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
