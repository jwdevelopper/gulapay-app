import 'package:flutter/material.dart';
import 'package:my_app_teste/features/produto/model/produto.dart';

typedef OnSubmitProduto = Future<Produto> Function(Produto produto);

class ProductFormComponent extends StatefulWidget {
  final Produto? produto;
  final OnSubmitProduto onSubmit;

  const ProductFormComponent({super.key, this.produto, required this.onSubmit});

  @override
  State<ProductFormComponent> createState() => _ProductFormComponentState();
}

class _ProductFormComponentState extends State<ProductFormComponent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _categoriaController;
  String _tipoProduto = 'UNITARIO';
  String _setorProducao = 'COZINHA';
  bool _ativo = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _nomeController = TextEditingController(text: p?.nome ?? '');
    _descricaoController = TextEditingController(text: p?.descricao ?? '');
    _precoController =
        TextEditingController(text: p != null ? p.preco.toString() : '0');
    _categoriaController = TextEditingController(
      text: p?.categoriaId != null ? p!.categoriaId.toString() : '0',
    );
    _tipoProduto = p?.tipoProduto ?? 'UNITARIO';
    _setorProducao = p?.setorProducao ?? 'COZINHA';
    _ativo = p?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final produto = Produto(
      id: widget.produto?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      preco: double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0,
      tipoProduto: _tipoProduto,
      setorProducao: _setorProducao,
      categoriaId: int.tryParse(_categoriaController.text) ?? 0,
      ativo: _ativo,
    );

    try {
      await widget.onSubmit(produto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do produto'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe o nome do produto' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço'),
              validator: (v) {
                final val = double.tryParse(v?.replaceAll(',', '.') ?? '');
                if (val == null) return 'Informe um preço válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipoProduto,
              items: ['UNITARIO', 'VARIAVEL']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _tipoProduto = v ?? 'UNITARIO'),
              decoration: const InputDecoration(labelText: 'Tipo do produto'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _setorProducao,
              items: ['COZINHA', 'BAR']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _setorProducao = v ?? 'COZINHA'),
              decoration: const InputDecoration(labelText: 'Setor de produção'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoriaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Categoria Id'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a categoria (id)';
                if (int.tryParse(v) == null) return 'Informe um id válido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Ativo'),
              value: _ativo,
              onChanged: (v) => setState(() => _ativo = v),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
