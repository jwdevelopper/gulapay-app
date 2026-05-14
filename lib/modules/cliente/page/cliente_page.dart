// lib/modules/cliente/page/cliente_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../service/cliente_service.dart';
import '../dto/cliente_response.dart';
import 'cliente_form_page.dart';
import 'cliente_detalhe_page.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  List<ClienteResponse> _clientes = [];
  List<ClienteResponse> _clientesFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    try {
      final clientes = await listarClientes();
      if (!mounted) return;
      setState(() {
        _clientes = clientes;
        _clientesFiltrados = clientes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar clientes.')),
      );
    }
  }

  void _filtrar(String query) {
    final queryLower = query.toLowerCase();
    setState(() {
      _clientesFiltrados = _clientes
          .where((c) =>
              (c.nome ?? '').toLowerCase().contains(queryLower) ||
              (c.telefone != null && c.telefone!.contains(query)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEC8550)))
                  : _clientesFiltrados.isEmpty
                  ? _buildEmptyState()
                  : _buildLista(),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFEC8550),
            elevation: 2,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClienteFormPage()),
              );
              if (result == true) _carregarClientes();
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Color(0xFFEC8550),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _buscaController,
          onChanged: _filtrar,
          decoration: const InputDecoration(
            hintText: 'Buscar por nome ou telefone...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.usersSlash, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Nenhum cliente encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Tente ajustar sua busca ou cadastre um novo.',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = _clientesFiltrados[index];
        // Assumindo que você adicione isAtivo no backend. Se não tiver, remova esta lógica.
        final bool isAtivo = cliente.ativo ?? true;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isAtivo ? const Color.fromARGB(255, 189, 110, 24).withOpacity(0.1) : Colors.grey[200],
              child: FaIcon(FontAwesomeIcons.user, color: isAtivo ? const Color.fromARGB(255, 189, 110, 24) : Colors.grey),
            ),
            title: Text(cliente.nome ?? 'Sem nome',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAtivo ? const Color(0xFF1E293B) : Colors.grey,
                  decoration: isAtivo ? null : TextDecoration.lineThrough,
                )),
            subtitle: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(cliente.telefone ?? 'Não informado')
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClienteDetalhesPage(cliente: cliente)),
              );
              if (result == true) _carregarClientes();
            },
          ),
        );
      },
    );
  }
}