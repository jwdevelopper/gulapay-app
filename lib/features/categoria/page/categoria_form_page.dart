import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_colors.dart';
import 'package:my_app_teste/features/categoria/model/categoria_dto.dart';
import 'package:my_app_teste/features/categoria/service/categoria_service.dart';

class CategoriaFormPage extends StatefulWidget {
  final CategoriaDto? categoria;

  const CategoriaFormPage({super.key, this.categoria});

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  static const int _limiteNome = 100;
  static const int _limiteDescricao = 255;

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final CategoriaService _categoriaService = CategoriaService();

  bool _isLoading = false;
  bool _tentouEnviar = false;

  bool get _modoEdicao => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    if (_modoEdicao) {
      _nomeController.text = widget.categoria!.nome;
      _descricaoController.text = widget.categoria!.descricao ?? '';
    }
    _nomeController.addListener(() => setState(() {}));
    _descricaoController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _tentouEnviar = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoriaRequest = CategoriaDto(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        ativo: widget.categoria?.ativo,
      );

      final CategoriaDto resultado;
      if (_modoEdicao) {
        resultado = await _categoriaService.atualizarCategoria(
          widget.categoria!.id!,
          categoriaRequest,
        );
      } else {
        resultado = await _categoriaService.criarCategoria(categoriaRequest);
      }

      if (!mounted) return;

      if (resultado.nome == 'Erro') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado.message ?? 'Erro ao salvar categoria'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _modoEdicao
                  ? 'Categoria atualizada com sucesso!'
                  : 'Categoria cadastrada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomeFaltando = _tentouEnviar && _nomeController.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoEscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _modoEdicao ? 'Editar categoria' : 'Nova categoria',
              style: const TextStyle(
                color: AppColors.textoEscuro,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _modoEdicao
                  ? 'Altere os dados da categoria'
                  : 'Etapa 1 de 1 · Identidade',
              style: const TextStyle(color: AppColors.textoClaro, fontSize: 12),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.textoClaro.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.laranja),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelComContador(
                      'Nome da categoria *',
                      _nomeController.text.length,
                      _limiteNome,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nomeController,
                      hint: 'Ex.: Pratos principais',
                      maxLength: _limiteNome,
                      obrigatorio: true,
                      mensagemErro: 'Informe o nome da categoria.',
                    ),
                    const SizedBox(height: 24),
                    _buildLabelComContador(
                      'Descrição',
                      _descricaoController.text.length,
                      _limiteDescricao,
                      opcional: true,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descricaoController,
                      hint: 'Detalhes, ingredientes, acompanhamentos...',
                      maxLines: 4,
                      maxLength: _limiteDescricao,
                      obrigatorio: false,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.amareloDestaque,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.laranja,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use um nome curto e claro. A descrição aparece no cardápio digital pro cliente.',
                              style: TextStyle(
                                color: AppColors.textoEscuro.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (nomeFaltando) ...[
                      const SizedBox(height: 16),
                      _buildBannerErro(
                        '1 campo obrigatório precisa ser preenchido antes de continuar.',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildLabelComContador(
    String label,
    int atual,
    int limite, {
    bool opcional = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          opcional ? '$label (opcional)' : label,
          style: const TextStyle(
            color: AppColors.textoEscuro,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          '$atual/$limite',
          style: const TextStyle(color: AppColors.textoClaro, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required int maxLength,
    required bool obrigatorio,
    String mensagemErro = 'Campo obrigatório',
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textoClaro, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textoClaro.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.laranja, width: 2),
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
          return mensagemErro;
        }
        return null;
      },
    );
  }

  Widget _buildBannerErro(String mensagem) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD86E)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFB8860B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(color: Color(0xFF856404), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.fundo,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.textoEscuro),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textoEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _salvar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.laranja,
                disabledBackgroundColor: AppColors.laranja.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _modoEdicao
                          ? 'Salvar alterações ✓'
                          : 'Cadastrar categoria',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
