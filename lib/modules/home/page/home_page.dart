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
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CategoriaPage(),
    ProdutoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final showShell = _selectedIndex != 2;

    return Scaffold(
      appBar: showShell ? AppBar(title: const Text('Home')) : null,
      drawer: showShell
          ? Drawer(
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
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Usuario'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categoria'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Produto'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
