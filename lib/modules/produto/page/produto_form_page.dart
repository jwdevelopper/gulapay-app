import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';

class ProdutoFormPage extends StatefulWidget {
  final Produto? produto;
  const ProdutoFormPage({super.key, this.produto});

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();

  // selections
  String? _selectedTipo; // PRATO, BEBIDA, SOBREMESA, PORCAO
  String? _selectedSetor; // COZINHA, BAR
  List<Categoria> _categorias = [];
  int? _selectedCategoriaId;

  bool _ativo = true;
  bool _saving = false;
  // loading state is not required for now
  int _step = 0;

  final ProdutoService _service = ProdutoService();

  final List<Map<String, String>> _tipoOptions = [
    {'label': 'Prato', 'desc': 'Refeição preparada', 'value': 'PRATO'},
    {'label': 'Bebida', 'desc': 'Copo, garrafa, drink', 'value': 'BEBIDA'},
    {'label': 'Sobremesa', 'desc': 'Doce, sorvete', 'value': 'SOBREMESA'},
    {'label': 'Porção', 'desc': 'Aperitivo, entrada', 'value': 'PORCAO'},
  ];

  final List<Map<String, String>> _setorOptions = [
    {'label': 'Cozinha', 'desc': 'Pratos quentes, pré-preparo', 'value': 'COZINHA'},
    {'label': 'Bar', 'desc': 'Bebidas, drinks, vinhos', 'value': 'BAR'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    if (p != null) {
      _nome.text = p.nome;
      _descricao.text = p.descricao ?? '';
      _preco.text = p.preco?.toString() ?? '';
      _selectedTipo = p.tipoProduto;
      _selectedSetor = p.setorProducao;
      _selectedCategoriaId = p.categoriaId;
      _ativo = p.ativo ?? true;
    }
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    // start loading
    try {
      final lista = await CategoriaService().listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() {
        _categorias = lista;
        if (_selectedCategoriaId == null && _categorias.isNotEmpty) {
          _selectedCategoriaId = _categorias.first.id;
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar categorias: $e')));
    } finally {
      // finished loading
    }
  }

  void _openCategoriaSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (c) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Escolher categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_categorias.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('Sem categorias'))
              else
                ..._categorias.map((categ) {
                  final selected = categ.id == _selectedCategoriaId;
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(categ.nome),
                    subtitle: categ.descricao != null ? Text(categ.descricao!) : null,
                    trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      setState(() => _selectedCategoriaId = categ.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  bool _validateStep() {
    if (_step == 0) {
      if (_nome.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome do produto')));
        return false;
      }
      return true;
    }
    if (_step == 1) {
      final preco = double.tryParse(_preco.text.replaceAll(',', '.')) ?? -1;
      if (preco < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um preço válido')));
        return false;
      }
      if (_selectedTipo == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o tipo do produto')));
        return false;
      }
      if (_selectedSetor == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione o setor de produção')));
        return false;
      }
      if (_selectedCategoriaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a categoria')));
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> _next() async {
    if (!_validateStep()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await _submit();
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final nome = _nome.text.trim();
    final descricao = _descricao.text.trim();
    final preco = double.tryParse(_preco.text.replaceAll(',', '.')) ?? 0.0;
    final payload = {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipoProduto': _selectedTipo ?? '',
      'setorProducao': _selectedSetor ?? '',
      'categoriaId': _selectedCategoriaId ?? 0,
    };

    try {
      if (widget.produto?.id != null) {
        payload['ativo'] = _ativo;
        await _service.editarProduto(widget.produto!.id!, payload);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto atualizado')));
      } else {
        await _service.criarProduto(payload);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto criado')));
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _preco.dispose();
    super.dispose();
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nome,
          decoration: const InputDecoration(labelText: 'Nome do produto *'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descricao,
          decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildTipoCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _tipoOptions.map((opt) {
        final selected = _selectedTipo == opt['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTipo = opt['value']),
          child: Container(
            width: (MediaQuery.of(context).size.width - 64) / 2,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? Colors.orange.shade50 : Colors.white,
              border: Border.all(color: selected ? Colors.orange : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected ? [BoxShadow(color: Color(0x1AFF9800), blurRadius: 6)] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(opt['label']!, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.orange : Colors.black)),
                const SizedBox(height: 6),
                Text(opt['desc']!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSetorCards() {
    return Column(
      children: _setorOptions.map((opt) {
        final selected = _selectedSetor == opt['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedSetor = opt['value']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: selected ? Colors.orange : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: selected ? Colors.orange : Colors.grey.shade200,
                  child: Text(opt['label']![0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label']!, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.orange : Colors.black)),
                      const SizedBox(height: 4),
                      Text(opt['desc']!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                Radio<String>(value: opt['value']!, groupValue: _selectedSetor, onChanged: (v) => setState(() => _selectedSetor = v)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _preco,
          decoration: const InputDecoration(labelText: 'Preço *', prefixText: 'R\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _openCategoriaSelector,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Categoria *'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_categorias.firstWhere((c) => c.id == _selectedCategoriaId, orElse: () => Categoria(id: 0, nome: 'Selecione')).nome)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Tipo do produto *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildTipoCards(),
        const SizedBox(height: 18),
        const Text('Setor de produção *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSetorCards(),
      ],
    );
  }

  Widget _buildSummary() {
    final categoriaName = _categorias.firstWhere((c) => c.id == _selectedCategoriaId, orElse: () => Categoria(id: 0, nome: '-')).nome;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RESUMO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Nome'), Text(_nome.text)]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Preço'), Text('R\$ ${double.tryParse(_preco.text.replaceAll(',', '.'))?.toStringAsFixed(2) ?? '0.00'}')]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Categoria'), Text(categoriaName)]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tipo'), Text(_selectedTipo ?? '-')]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Setor'), Text(_selectedSetor ?? '-')]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.produto?.id != null;
    final stepWidgets = [_buildStep1(), _buildStep2(), _buildSummary()];

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar produto' : 'Novo produto')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              // progress indicator
              LinearProgressIndicator(value: (_step + 1) / 3),
              const SizedBox(height: 12),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        stepWidgets[_step],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              // buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _step == 0 ? () => Navigator.pop(context) : _prev,
                      child: Text(_step == 0 ? 'Cancelar' : 'Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _next,
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_step == 2 ? (isEdit ? 'Salvar produto' : 'Cadastrar produto') : 'Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
