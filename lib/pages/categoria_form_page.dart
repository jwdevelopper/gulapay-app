import 'package:flutter/material.dart';
import 'package:my_app_teste/model/categoria_dto.dart';
import 'package:my_app_teste/services/categoria_service.dart';


class CategoriaFormPage extends StatefulWidget {
  const CategoriaFormPage({super.key});

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  final Color corFundo = const Color(0xFFFCF8F2);
  final Color corLaranja = const Color(0xFFF25D27);
  final Color corTextoEscuro = const Color(0xFF4A342E);
  final Color corTextoClaro = const Color(0xFF8D7A74);

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  final CategoriaService _categoriaService = CategoriaService();
  bool _isLoading = false; // Controla o botão de salvar

  Future<void> _salvarCategoria() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final categoriaRequest = CategoriaDto(
          nome: _nomeController.text.trim(),
          descricao: _descricaoController.text.trim(),
        );

        final resultado = await _categoriaService.criarCategoria(categoriaRequest);

        if (resultado.nome == "Erro") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado.message ?? 'Erro ao salvar categoria'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); 
        }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Erro inesperado na tela: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: corTextoEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nova categoria',
          style: TextStyle(color: corTextoEscuro, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nome da categoria *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nomeController,
                      hint: 'Ex.: Pratos principais',
                      obrigatorio: true,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Descrição (opcional)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descricaoController,
                      hint: 'Detalhes da categoria para organizar o cardápio...',
                      maxLines: 4,
                      obrigatorio: false,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: corLaranja, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use nomes curtos e claros. As categorias ajudam a organizar seu aplicativo.',
                              style: TextStyle(color: corTextoEscuro.withOpacity(0.8), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: corFundo,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: corTextoEscuro),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: corTextoEscuro, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvarCategoria,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: corLaranja,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            'Continuar >',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(color: corTextoEscuro, fontWeight: FontWeight.bold, fontSize: 14));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required bool obrigatorio,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: corTextoClaro, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: corTextoClaro.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: corLaranja, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (obrigatorio && (value == null || value.trim().isEmpty)) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}