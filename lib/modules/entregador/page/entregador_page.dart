import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EntregadorPage extends StatefulWidget {
  const EntregadorPage({super.key});

  @override
  State<EntregadorPage> createState() => _EntregadorPageState();
}

class _EntregadorPageState extends State<EntregadorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  bool _ativo = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarEntregador() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, verifique os campos do formulário.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entregador "${_nomeController.text}" salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar entregador: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregador', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 205, 105, 40),
        foregroundColor: const Color.fromARGB(255, 206, 127, 53),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        color: const Color.fromARGB(255, 242, 236, 226),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Row(
                      children: const [
                        FaIcon(FontAwesomeIcons.truckFast, size: 26.0),
                        SizedBox(width: 12.0),
                        Text(
                          'Cadastro de Entregador',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        labelText: 'Nome',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: IconButton(
                          onPressed: () => _nomeController.clear(),
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 16.0,
                            color: const Color.fromARGB(255, 248, 151, 40),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o nome do entregador.';
                        } else if (value.length < 3) {
                          return 'O nome deve ter ao menos 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        labelText: 'Telefone',
                        prefixIcon: const Icon(Icons.phone),
                        suffixIcon: IconButton(
                          onPressed: () => _telefoneController.clear(),
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 16.0,
                            color: const Color.fromARGB(255, 248, 151, 40),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o telefone do entregador.';
                        } else if (value.length < 10) {
                          return 'Telefone inválido. Use DDD + número.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    SwitchListTile(
                      value: _ativo,
                      onChanged: (value) => setState(() => _ativo = value),
                      title: const Text('Status'),
                      subtitle: Text(_ativo ? 'Ativo' : 'Inativo'),
                      secondary: FaIcon(
                        _ativo ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circleXmark,
                        color: _ativo ? Colors.green : Colors.red,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24.0),
                    Card(
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Resumo', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8.0),
                                  Text('Nome: ${_nomeController.text.isEmpty ? '—' : _nomeController.text}'),
                                  const SizedBox(height: 4.0),
                                  Text('Telefone: ${_telefoneController.text.isEmpty ? '—' : _telefoneController.text}'),
                                  const SizedBox(height: 4.0),
                                  Text('Status: ${_ativo ? 'Ativo' : 'Inativo'}'),
                                ],
                              ),
                            ),
                            const FaIcon(FontAwesomeIcons.infoCircle, size: 20.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      height: 56.0,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const FaIcon(FontAwesomeIcons.paperPlane, size: 18.0),
                        label: Text(
                          _isLoading ? 'Salvando...' : 'Salvar Entregador',
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLoading ? null : _salvarEntregador,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 236, 133, 80),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    
  }
}
