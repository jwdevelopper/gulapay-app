import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';

class ProdutoFormPage extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormPage({super.key, this.produto});

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ChoiceOption {
  final String label;
  final String description;
  final String value;
  final IconData icon;

  const _ChoiceOption({
    required this.label,
    required this.description,
    required this.value,
    required this.icon,
  });
}

class _WarmPalette {
  static const background = Color(0xFFFCF6EC);
  static const surface = Color(0xFFFFF9F1);
  static const surfaceAlt = Color(0xFFFFFDF9);
  static const primary = Color(0xFFF07330);
  static const primaryPressed = Color(0xFFE85F1E);
  static const primarySoft = Color(0xFFF8C39C);
  static const text = Color(0xFF3D261A);
  static const textMuted = Color(0xFFA06E4E);
  static const border = Color(0xFFE8D8C2);
  static const borderSoft = Color(0xFFF0E3D0);
  static const inputFill = Color(0xFFFFF4E8);
  static const warningBg = Color(0xFFFCEEDC);
  static const warningBorder = Color(0xFFE9C48D);
  static const error = Color(0xFFD96A4A);
  static const shadow = Color(0x1A9C5A1E);
}

const List<_ChoiceOption> _tipoOptions = [
  _ChoiceOption(
    label: 'Unitário',
    description: 'Produto vendido por unidade',
    value: 'UNITARIO',
    icon: Icons.inventory_2_rounded,
  ),
  _ChoiceOption(
    label: 'Composto',
    description: 'Produto composto por insumos',
    value: 'COMPOSTO',
    icon: Icons.layers_rounded,
  ),
  _ChoiceOption(
    label: 'Combo',
    description: 'Conjunto de itens',
    value: 'COMBO',
    icon: Icons.local_offer_rounded,
  ),
];

const List<_ChoiceOption> _setorOptions = [
  _ChoiceOption(
    label: 'Cozinha',
    description: 'Pratos quentes, pré-preparo',
    value: 'COZINHA',
    icon: Icons.dining_rounded,
  ),
  _ChoiceOption(
    label: 'Bar',
    description: 'Bebidas, drinks, vinhos',
    value: 'BAR',
    icon: Icons.wine_bar_rounded,
  ),
  _ChoiceOption(
    label: 'Balcão',
    description: 'Atendimento no balcão',
    value: 'BALCAO',
    icon: Icons.storefront_rounded,
  ),
];

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  final ProdutoService _service = ProdutoService();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();

  List<Categoria> _categorias = [];
  int? _selectedCategoriaId;
  String? _selectedTipo;
  String? _selectedSetor;
  bool _ativo = true;
  bool _saving = false;
  int _step = 0;

  bool _nomeError = false;
  bool _precoError = false;
  bool _categoriaError = false;
  bool _tipoError = false;
  bool _setorError = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    if (produto != null) {
      _nome.text = produto.nome;
      _descricao.text = produto.descricao ?? '';
      _preco.text = _formatInputPrice(produto.preco);
      _selectedTipo = produto.tipoProduto;
      _selectedSetor = produto.setorProducao;
      _selectedCategoriaId = produto.categoriaId;
      _ativo = produto.ativo ?? true;
    }
    _loadCategorias();
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _preco.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.produto?.id != null;

  String get _stepLabel {
    switch (_step) {
      case 0:
        return 'Identidade';
      case 1:
        return 'Preço & categoria';
      default:
        return 'Produção';
    }
  }

  Categoria? get _selectedCategoria {
    if (_selectedCategoriaId == null) {
      return null;
    }
    for (final categoria in _categorias) {
      if (categoria.id == _selectedCategoriaId) {
        return categoria;
      }
    }
    return null;
  }

  String get _selectedCategoriaLabel =>
      _selectedCategoria?.nome ?? 'Selecione a categoria';

  Future<void> _loadCategorias() async {
    try {
      final lista = await CategoriaService().listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() {
        _categorias = lista;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  String _formatInputPrice(double? price) {
    if (price == null) return '';
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _parsePrice() {
    return double.tryParse(
          _preco.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
  }

  String _formatCurrency(double? value) {
    final formatted = (value ?? 0).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  void _clearValidationState() {
    _nomeError = false;
    _precoError = false;
    _categoriaError = false;
    _tipoError = false;
    _setorError = false;
    _validationMessage = null;
  }

  String _pluralMessage(int count) {
    return count == 1
        ? '1 campo obrigatório precisa ser preenchido antes de continuar.'
        : '$count campos obrigatórios precisam ser preenchidos antes de continuar.';
  }

  bool _validateStep() {
    setState(_clearValidationState);

    if (_step == 0) {
      if (_nome.text.trim().isEmpty) {
        setState(() {
          _nomeError = true;
          _validationMessage = _pluralMessage(1);
        });
        return false;
      }
      return true;
    }

    if (_step == 1) {
      var errorCount = 0;
      if (_parsePrice() <= 0) {
        _precoError = true;
        errorCount++;
      }
      if (_selectedCategoriaId == null) {
        _categoriaError = true;
        errorCount++;
      }
      if (errorCount > 0) {
        setState(() {
          _validationMessage = _pluralMessage(errorCount);
        });
        return false;
      }
      return true;
    }

    var errorCount = 0;
    if (_selectedTipo == null) {
      _tipoError = true;
      errorCount++;
    }
    if (_selectedSetor == null) {
      _setorError = true;
      errorCount++;
    }
    if (errorCount > 0) {
      setState(() {
        _validationMessage = _pluralMessage(errorCount);
      });
      return false;
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
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final payload = {
      'nome': _nome.text.trim(),
      'descricao': _descricao.text.trim(),
      'preco': _parsePrice(),
      'tipoProduto': _selectedTipo ?? '',
      'setorProducao': _selectedSetor ?? '',
      'categoriaId': _selectedCategoriaId ?? 0,
    };

    try {
      if (_isEdit) {
        payload['ativo'] = _ativo;
        await _service.editarProduto(widget.produto!.id!, payload);
      } else {
        await _service.criarProduto(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Produto atualizado' : 'Produto criado'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openCategoriaSelector() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Container(
            decoration: const BoxDecoration(
              color: _WarmPalette.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _WarmPalette.borderSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Escolher categoria',
                            style: TextStyle(
                              color: _WarmPalette.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                          color: _WarmPalette.text,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _categorias.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 42,
                                    color: _WarmPalette.textMuted,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Sem categorias',
                                    style: TextStyle(
                                      color: _WarmPalette.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _categorias.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final categoria = _categorias[index];
                                final selected =
                                    categoria.id == _selectedCategoriaId;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoriaId = categoria.id;
                                      _categoriaError = false;
                                      _validationMessage = null;
                                    });
                                    Navigator.pop(sheetContext);
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? _WarmPalette.warningBg
                                          : _WarmPalette.surfaceAlt,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: selected
                                            ? _WarmPalette.primary
                                            : _WarmPalette.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? _WarmPalette.primary
                                                : _WarmPalette.inputFill,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            _iconForCategory(categoria.nome),
                                            color: selected
                                                ? Colors.white
                                                : _WarmPalette.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categoria.nome,
                                                style: const TextStyle(
                                                  color: _WarmPalette.text,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if ((categoria.descricao ?? '')
                                                  .trim()
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  categoria.descricao!.trim(),
                                                  style: const TextStyle(
                                                    color:
                                                        _WarmPalette.textMuted,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (selected)
                                          const Icon(
                                            Icons.check_rounded,
                                            color: _WarmPalette.primary,
                                          )
                                        else
                                          const SizedBox(width: 18),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('beb')) return Icons.local_bar_rounded;
    if (lower.contains('sob')) return Icons.cake_rounded;
    if (lower.contains('entr')) return Icons.ramen_dining_rounded;
    if (lower.contains('por')) return Icons.fastfood_rounded;
    return Icons.restaurant_rounded;
  }

  String _friendlyType(String? value) {
    switch (value) {
      case 'UNITARIO':
        return 'Unitário';
      case 'COMPOSTO':
        return 'Composto';
      case 'COMBO':
        return 'Combo';
      default:
        return '-';
    }
  }

  String _friendlySetor(String? value) {
    switch (value) {
      case 'COZINHA':
        return 'Cozinha';
      case 'BAR':
        return 'Bar';
      case 'BALCAO':
        return 'Balcão';
      case 'CAIXA':
        return 'Caixa';
      default:
        return '-';
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              if (_step == 0) {
                Navigator.pop(context);
              } else {
                _prev();
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Editar produto' : 'Novo produto',
                  style: const TextStyle(
                    color: _WarmPalette.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Etapa ${_step + 1} de 3 • $_stepLabel',
                  style: const TextStyle(
                    color: _WarmPalette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= _step;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
              decoration: BoxDecoration(
                color: active ? _WarmPalette.primary : _WarmPalette.borderSoft,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputLabel(String label, {String? counter}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _WarmPalette.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (counter != null)
          Text(
            counter,
            style: const TextStyle(
              color: _WarmPalette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool error = false,
    bool price = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _WarmPalette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: error ? _WarmPalette.error : _WarmPalette.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F9C5A1E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _WarmPalette.text,
          fontSize: price ? 28 : 15,
          fontWeight: price ? FontWeight.w700 : FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _WarmPalette.textMuted),
          prefixText: price ? 'R\$ ' : null,
          prefixStyle: const TextStyle(
            color: _WarmPalette.textMuted,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: price ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_validationMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _WarmPalette.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _WarmPalette.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.warning_amber_rounded,
              color: _WarmPalette.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _validationMessage!,
              style: const TextStyle(
                color: _WarmPalette.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _WarmPalette.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _WarmPalette.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: _WarmPalette.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _WarmPalette.text,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(
          'Nome do produto *',
          counter: '${_nome.text.length}/120',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nome,
          hint: 'Ex.: Picanha na chapa',
          onChanged: (_) {
            if (_nomeError || _validationMessage != null) {
              setState(() {
                _nomeError = false;
                _validationMessage = null;
              });
            } else {
              setState(() {});
            }
          },
          error: _nomeError,
        ),
        if (_nomeError) ...[
          const SizedBox(height: 6),
          const Text(
            'Informe o nome do produto.',
            style: TextStyle(
              color: _WarmPalette.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildInputLabel(
          'Descrição opcional',
          counter: '${_descricao.text.length}/500',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descricao,
          hint: 'Detalhes, ingredientes, acompanhamentos...',
          onChanged: (_) => setState(() {}),
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Use um nome curto e claro. A descrição aparece no cardápio digital pro cliente.',
        ),
        const SizedBox(height: 16),
        _buildErrorBanner(),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final hasSelection = _selectedCategoriaId != null;
    return InkWell(
      onTap: _openCategoriaSelector,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _WarmPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _categoriaError ? _WarmPalette.error : _WarmPalette.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F9C5A1E),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasSelection
                    ? _WarmPalette.primary
                    : _WarmPalette.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconForCategory(_selectedCategoriaLabel),
                color: hasSelection ? Colors.white : _WarmPalette.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoria *',
                    style: TextStyle(
                      color: _WarmPalette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCategoriaLabel,
                    style: TextStyle(
                      color: hasSelection
                          ? _WarmPalette.text
                          : _WarmPalette.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _WarmPalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preço de venda *',
          style: TextStyle(
            color: _WarmPalette.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _preco,
          hint: '89,00',
          onChanged: (_) {
            if (_precoError || _validationMessage != null) {
              setState(() {
                _precoError = false;
                _validationMessage = null;
              });
            } else {
              setState(() {});
            }
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          price: true,
          error: _precoError,
        ),
        if (_precoError) ...[
          const SizedBox(height: 6),
          const Text(
            'Informe um preço válido.',
            style: TextStyle(
              color: _WarmPalette.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildCategorySelector(),
        if (_categoriaError) ...[
          const SizedBox(height: 6),
          const Text(
            'Selecione uma categoria.',
            style: TextStyle(
              color: _WarmPalette.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildInfoCard(
          'Margem típica de pratos principais: 60–70%. Ajuste o preço de acordo com seu posicionamento.',
        ),
        const SizedBox(height: 16),
        _buildErrorBanner(),
      ],
    );
  }

  Widget _buildTypeOption(_ChoiceOption option) {
    final selected = _selectedTipo == option.value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTipo = option.value;
          _tipoError = false;
          _validationMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _WarmPalette.warningBg : _WarmPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _WarmPalette.primary : _WarmPalette.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? _WarmPalette.primary
                        : _WarmPalette.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color: selected ? Colors.white : _WarmPalette.primary,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _WarmPalette.primary,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              option.label,
              style: const TextStyle(
                color: _WarmPalette.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.description,
              style: const TextStyle(
                color: _WarmPalette.textMuted,
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: _tipoOptions.map(_buildTypeOption).toList(),
    );
  }

  Widget _buildSectorOption(_ChoiceOption option) {
    final selected = _selectedSetor == option.value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSetor = option.value;
          _setorError = false;
          _validationMessage = null;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _WarmPalette.warningBg : _WarmPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _WarmPalette.primary : _WarmPalette.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? _WarmPalette.primary : _WarmPalette.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                color: selected ? Colors.white : _WarmPalette.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      color: _WarmPalette.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: _WarmPalette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _WarmPalette.primary,
                size: 18,
              )
            else
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: _WarmPalette.border,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final categoriaName = _selectedCategoria?.nome ?? '-';
    final priceValue = _parsePrice();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _WarmPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _WarmPalette.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: _WarmPalette.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO',
            style: TextStyle(
              color: _WarmPalette.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Nome',
            value: _nome.text.trim().isEmpty ? '-' : _nome.text.trim(),
          ),
          const Divider(height: 18, color: _WarmPalette.borderSoft),
          _SummaryRow(
            label: 'Preço',
            value: _formatCurrency(priceValue > 0 ? priceValue : null),
          ),
          const Divider(height: 18, color: _WarmPalette.borderSoft),
          _SummaryRow(label: 'Categoria', value: categoriaName),
          const Divider(height: 18, color: _WarmPalette.borderSoft),
          _SummaryRow(label: 'Tipo', value: _friendlyType(_selectedTipo)),
          const Divider(height: 18, color: _WarmPalette.borderSoft),
          _SummaryRow(label: 'Setor', value: _friendlySetor(_selectedSetor)),
        ],
      ),
    );
  }

  Widget _buildProductionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo do produto *',
          style: TextStyle(
            color: _WarmPalette.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _buildTypeGrid(),
        if (_tipoError) ...[
          const SizedBox(height: 6),
          const Text(
            'Selecione um tipo de produto.',
            style: TextStyle(
              color: _WarmPalette.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Text(
          'Setor de produção *',
          style: TextStyle(
            color: _WarmPalette.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Column(children: _setorOptions.map(_buildSectorOption).toList()),
        if (_setorError) ...[
          const SizedBox(height: 6),
          const Text(
            'Selecione o setor de produção.',
            style: TextStyle(
              color: _WarmPalette.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildSummary(),
        const SizedBox(height: 16),
        _buildErrorBanner(),
      ],
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildIdentityStep();
      case 1:
        return _buildPriceStep();
      default:
        return _buildProductionStep();
    }
  }

  Widget _buildBottomButtons() {
    final leftLabel = _step == 0 ? 'Cancelar' : 'Voltar';
    final rightLabel = _step == 2
        ? (_isEdit ? 'Salvar produto' : 'Cadastrar produto')
        : 'Continuar';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _step == 0 ? () => Navigator.pop(context) : _prev,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _WarmPalette.text,
                  backgroundColor: _WarmPalette.surfaceAlt,
                  side: const BorderSide(color: _WarmPalette.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(leftLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _WarmPalette.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _WarmPalette.primarySoft.withOpacity(
                    0.55,
                  ),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                  elevation: 4,
                  shadowColor: _WarmPalette.primaryPressed.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(rightLabel),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _WarmPalette.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _buildStepBody(),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _WarmPalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _WarmPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _WarmPalette.border),
          ),
          child: Icon(icon, color: _WarmPalette.text, size: 22),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _WarmPalette.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _WarmPalette.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
