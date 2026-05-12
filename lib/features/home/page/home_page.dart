import 'package:flutter/material.dart';
import 'package:my_app_teste/features/categoria/page/categoria_lista_page.dart';
import 'package:my_app_teste/features/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/features/produto/page/produto_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CategoriaListaPage(),
    ProdutoListPage(),
  ];

  void _selecionar(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
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
              onTap: () => _selecionar(0),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Usuario'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categoria'),
              onTap: () => _selecionar(1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Produto'),
              onTap: () => _selecionar(2),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
