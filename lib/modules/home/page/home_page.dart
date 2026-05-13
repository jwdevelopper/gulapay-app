import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/entregador/page/entregador_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;

  List<Widget> _pages = [
    DashboardPage(),
    CategoriaPage(),
    ProdutoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Usuario'),
              onTap: () {
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delivery_dining),
              title: Text('Entregador'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntregadorPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categoria'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Produto'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      )
    );
  }
}
