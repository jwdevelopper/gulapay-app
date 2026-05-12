// lib/modules/cliente/page/cliente_form_page.dart
import 'package:flutter/material.dart';
import '../dto/cliente_endereco.dart';
import '../service/cliente_service.dart';
import '../dto/cliente_response.dart';
import '../dto/cliente_create_request.dart';
import '../dto/cliente_update_request.dart';

class ClienteFormPage extends StatefulWidget {
  final ClienteResponse? cliente; // Se for nulo, é cadastro. Se existir, é edição.

  const ClienteFormPage({super.key, this.cliente});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  bool _isLoading = false;

  bool get isEdicao => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (isEdicao) {
      _nomeController.text = widget.cliente!.nome!;
      _telefoneController.text = widget.cliente!.telefone ?? '';

      _emailController.text = widget.cliente!.email ?? '';

      if (widget.cliente!.endereco != null) {
        _cepController.text = widget.cliente!.endereco!.cep ?? '';
        _logradouroController.text = widget.cliente!.endereco!.logradouro ?? '';
        _numeroController.text = widget.cliente!.endereco!.numero ?? '';
        _complementoController.text = widget.cliente!.endereco!.complemento ?? '';
        _bairroController.text = widget.cliente!.endereco!.bairro ?? '';
        _cidadeController.text = widget.cliente!.endereco!.cidade ?? '';
        _ufController.text = widget.cliente!.endereco!.uf ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final endereco = ClienteEndereco(
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        uf: _ufController.text,
      );

      debugPrint('JSON enviado: ${endereco.toJson()}');

      if (isEdicao) {
        final dto = ClienteUpdateRequest(
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          email: _emailController.text,
          endereco: endereco,
          ativo: widget.cliente!.ativo ?? true,
        );
        await editarCliente(widget.cliente!.id as int, dto);
      } else {
        final dto = ClienteCreateRequest(
          nome: _nomeController.text,
          telefone: _telefoneController.text,
          email: _emailController.text,
          endereco: endereco,
        );
        debugPrint('JSON enviado: ${dto.toJson()}');
        await criarCliente(dto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdicao ? 'Cliente atualizado com sucesso!' : 'Cliente cadastrado!')),
        );
        Navigator.pop(context, true); // Retorna true para atualizar a lista
      }
    } catch (e) {
      // ISSO VAI IMPRIMIR O ERRO REAL NO CONSOLE (DEBUG)
      debugPrint('Erro ao salvar cliente: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'), // Mostra o erro real na tela
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Cliente' : 'Novo Cliente', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Dados de Identificação'),
              _buildTextField('Nome Completo', _nomeController, isRequired: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Contato'),
              _buildTextField("E-mail", _emailController),
              _buildTextField('Telefone (WhatsApp)', _telefoneController, isRequired: true),
              const SizedBox(height: 32),

              _buildSectionTitle('Endereço'),
              _buildTextField('CEP', _cepController),
              const SizedBox(height: 16),
              _buildTextField('Logradouro (Rua/Avenida)', _logradouroController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Número', _numeroController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Complemento', _complementoController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Bairro', _bairroController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField('Cidade', _cidadeController)),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildTextField('UF', _ufController)),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _salvar,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdicao ? 'Salvar Alterações' : 'Cadastrar Cliente',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) return 'Este campo é obrigatório';
        return null;
      } : null,
    );
  }
}