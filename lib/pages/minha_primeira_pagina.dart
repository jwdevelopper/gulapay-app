import 'package:flutter/material.dart';
import 'package:my_app_teste/pages/alinhamento_horizontal.dart';

class MinhaPrimeiraPagina extends StatelessWidget {
  const MinhaPrimeiraPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppBar aplicação", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 28, 28),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Texto centralizado",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Text("Segundo texto"),
          SizedBox(height: 10.0),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AlinhamnetoHorizontal()));
            },
            label: Text(
              "Botão para teste", 
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(Icons.login, color: Colors.white),
            style: ElevatedButton.styleFrom(
              elevation: 2.0,
              backgroundColor: Colors.blueAccent,
              iconAlignment: IconAlignment.end
            ),
            ),
        ],
      ),
    );
  }
}
