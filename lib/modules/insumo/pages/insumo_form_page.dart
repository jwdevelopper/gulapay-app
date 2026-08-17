import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';
import 'package:my_app_teste/modules/insumo/components/unidade_medida_mock.dart';

class InsumoFormPage extends StatefulWidget {
  /// Quando null, é cadastro. Quando preenchido, é edição.
  final InsumoResponse? insumo;

  const InsumoFormPage({super.key, this.insumo});

  @override
  State<InsumoFormPage> createState() => _InsumoFormPageState();
}

class _InsumoFormPageState extends State<InsumoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _insumoService = InsumoService();
  final _unidadeService = UnidadeMedidaServiceMock();

  late final TextEditingController _nomeController;
  late final TextEditingController _estoqueMinimoController;

  // Estado das unidades
  List<UnidadeMedidaMock> _unidades = [];
  bool _loadingUnidades = true;
  String? _erroCarregarUnidades;

  // Campos do form
  int? _unidadePadraoId;
  bool _ativo = true;

  // Estado de salvamento
  bool _saving = false;

  bool get _isEditing => widget.insumo != null;

  @override
  void initState() {
    super.initState();
    final insumo = widget.insumo;

    _nomeController = TextEditingController(text: insumo?.nome ?? '');
    _estoqueMinimoController = TextEditingController(
      text: insumo?.estoqueMinimo != null
          ? _formatNumeroParaInput(insumo!.estoqueMinimo!)
          : '',
    );
    _unidadePadraoId = insumo?.unidadePadraoId;
    _ativo = insumo?.ativo ?? true;

    _carregarUnidades();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _estoqueMinimoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Carregamento de unidades
  // ---------------------------------------------------------------------------

  Future<void> _carregarUnidades() async {
    if (mounted) {
      setState(() {
        _loadingUnidades = true;
        _erroCarregarUnidades = null;
      });
    }
    try {
      final lista = await _unidadeService.listar();
      if (!mounted) return;
      setState(() {
        _unidades = lista;
        _loadingUnidades = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroCarregarUnidades = e.toString();
        _loadingUnidades = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatNumeroParaInput(double valor) {
    var s = valor.toStringAsFixed(3);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s.replaceAll('.', ',');
  }

  double? _parseEstoqueMinimo(String texto) {
    final limpo = texto.trim().replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    return double.tryParse(limpo);
  }

  // ---------------------------------------------------------------------------
  // Validações
  // ---------------------------------------------------------------------------

  String? _validarNome(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe o nome do insumo';
    if (v.length < 2) return 'Nome deve ter no mínimo 2 caracteres';
    if (v.length > 120) return 'Nome deve ter no máximo 120 caracteres';
    return null;
  }

  String? _validarUnidade(int? value) {
    if (value == null) return 'Selecione uma unidade de medida';
    return null;
  }

  String? _validarEstoqueMinimo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe o estoque mínimo';
    final parsed = _parseEstoqueMinimo(v);
    if (parsed == null) return 'Valor inválido';
    if (parsed < 0) return 'Não pode ser negativo';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _salvar() async {
    if (_loadingUnidades || _erroCarregarUnidades != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aguarde as unidades carregarem para salvar.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final nome = _nomeController.text.trim();
      final estoqueMinimo = _parseEstoqueMinimo(_estoqueMinimoController.text)!;

      if (_isEditing) {
        final request = InsumoUpdate(
          nome: nome,
          unidadePadraoId: _unidadePadraoId,
          estoqueMinimo: estoqueMinimo,
          ativo: _ativo,
        );
        await _insumoService.atualizar(widget.insumo!.id!, request);
      } else {
        final request = InsumoCreateRequest(
          nome: nome,
          unidadePadraoId: _unidadePadraoId,
          estoqueMinimo: estoqueMinimo,
        );
        await _insumoService.criar(request);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Insumo atualizado com sucesso.'
                : 'Insumo cadastrado com sucesso.',
          ),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar insumo' : 'Novo insumo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildNomeField(),
              const SizedBox(height: 16),
              _buildUnidadeSection(),
              const SizedBox(height: 16),
              _buildEstoqueMinimoField(),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                _buildAtivoSwitch(),
              ],
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      enabled: !_saving,
      maxLength: 120,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Nome',
        hintText: 'Ex: Tomate italiano',
        border: OutlineInputBorder(),
      ),
      validator: _validarNome,
    );
  }

  /// Renderiza um de três estados: carregando, erro, ou o dropdown pronto.
  Widget _buildUnidadeSection() {
    if (_loadingUnidades) {
      return _buildUnidadeLoading();
    }
    if (_erroCarregarUnidades != null) {
      return _buildUnidadeErro();
    }
    return _buildUnidadeDropdown();
  }

  Widget _buildUnidadeLoading() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Unidade de medida',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Carregando unidades...'),
        ],
      ),
    );
  }

  Widget _buildUnidadeErro() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Unidade de medida',
        border: const OutlineInputBorder(),
        errorText: 'Não foi possível carregar as unidades',
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Tente novamente para listar as unidades.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton.icon(
            onPressed: _carregarUnidades,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadeDropdown() {
    // Se o insumo veio com uma unidade que não está na lista atual (caso raro),
    // o initialValue ainda funciona, mas o dropdown não exibe o item — limpa
    // pra evitar warning de "value not in items".
    final initialValid = _unidades.any((u) => u.id == _unidadePadraoId);
    final initial = initialValid ? _unidadePadraoId : null;

    return DropdownButtonFormField<int>(
      initialValue: initial,
      decoration: const InputDecoration(
        labelText: 'Unidade de medida',
        border: OutlineInputBorder(),
      ),
      items: _unidades.map((unidade) {
        return DropdownMenuItem<int>(
          value: unidade.id,
          child: Text('${unidade.nome} (${unidade.simbolo})'),
        );
      }).toList(),
      onChanged: _saving
          ? null
          : (value) => setState(() => _unidadePadraoId = value),
      validator: _validarUnidade,
    );
  }

  Widget _buildEstoqueMinimoField() {
    return TextFormField(
      controller: _estoqueMinimoController,
      enabled: !_saving,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      decoration: const InputDecoration(
        labelText: 'Estoque mínimo',
        hintText: 'Ex: 0,5',
        helperText: 'Quantidade na unidade selecionada',
        border: OutlineInputBorder(),
      ),
      validator: _validarEstoqueMinimo,
    );
  }

  Widget _buildAtivoSwitch() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SwitchListTile(
        title: const Text('Ativo'),
        subtitle: Text(
          _ativo
              ? 'Este insumo está ativo e disponível.'
              : 'Este insumo está inativo (não aparece em listagens normais).',
        ),
        value: _ativo,
        onChanged: _saving ? null : (v) => setState(() => _ativo = v),
      ),
    );
  }

  Widget _buildSaveButton() {
    final podeSalvar = !_saving &&
        !_loadingUnidades &&
        _erroCarregarUnidades == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: podeSalvar ? _salvar : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(_isEditing ? 'Salvar alterações' : 'Cadastrar insumo'),
      ),
    );
  }
}