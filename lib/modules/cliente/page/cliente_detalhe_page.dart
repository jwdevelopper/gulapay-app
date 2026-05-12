// lib/modules/cliente/page/cliente_detalhes_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import '../dto/cliente_response.dart';
import 'cliente_form_page.dart';
// import '../service/cliente_service.dart'; // Descomente após criar o método inativarCliente

class ClienteDetalhesPage extends StatelessWidget {
  final ClienteResponse cliente;

  const ClienteDetalhesPage({super.key, required this.cliente});

  void _confirmarInativacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Inativar Cliente"),
        content: const Text(
          "Deseja inativar este cliente? Ele não aparecerá mais nas buscas ativas, mas o histórico de pedidos será preservado.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            onPressed: () async {
              await inativarCliente(cliente.id as int);
              Navigator.pop(ctx); // Fecha dialog
              Navigator.pop(
                context,
                true,
              ); // Volta para lista indicando atualização
            },
            child: const Text(
              "Inativar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Detalhes do Cliente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClienteFormPage(cliente: cliente),
                ),
              );
              if (result == true) Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardPerfil(),
            const SizedBox(height: 16),
            _buildCardContato(),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.block),
              label: const Text('Inativar Cliente'),
              onPressed: () => _confirmarInativacao(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPerfil() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: FaIcon(
                FontAwesomeIcons.userLarge,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cliente.nome!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cliente.email ?? 'E-mail não informado',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cliente.endereco?.cidade ?? 'Cidade não informada',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Text(
                  ' - ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  cliente.endereco?.uf ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContato() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
            ),
            title: const Text(
              'WhatsApp',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            subtitle: Text(
              cliente.telefone ?? 'Não informado',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.blueAccent),
              onPressed: () {
                // Lógica para abrir url launcher
              },
            ),
          ),
        ],
      ),
    );
  }
}
