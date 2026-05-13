import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/produto/models/produto_list_filter.dart';

import 'produtos_palette.dart';

class ProdutoFilterSheet extends StatefulWidget {
  final List<Categoria> categorias;
  final ProdutoListFilter initialFilter;
  final IconData Function(String name) iconForCategoryName;
  final String Function(int? categoriaId) categoryNameBuilder;

  const ProdutoFilterSheet({
    super.key,
    required this.categorias,
    required this.initialFilter,
    required this.iconForCategoryName,
    required this.categoryNameBuilder,
  });

  static Future<ProdutoListFilter?> show(
    BuildContext context, {
    required List<Categoria> categorias,
    required ProdutoListFilter initialFilter,
    required IconData Function(String name) iconForCategoryName,
    required String Function(int? categoriaId) categoryNameBuilder,
  }) {
    return showModalBottomSheet<ProdutoListFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ProdutoFilterSheet(
          categorias: categorias,
          initialFilter: initialFilter,
          iconForCategoryName: iconForCategoryName,
          categoryNameBuilder: categoryNameBuilder,
        );
      },
    );
  }

  @override
  State<ProdutoFilterSheet> createState() => _ProdutoFilterSheetState();
}

class _ProdutoFilterSheetState extends State<ProdutoFilterSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _descricaoController;

  String? _selectedCategoria;
  String? _selectedSector;
  String? _selectedTipo;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialFilter.precoMin?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.initialFilter.precoMax?.toString() ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.initialFilter.descricao,
    );
    _selectedCategoria = widget.initialFilter.categoriaId?.toString();
    _selectedSector = widget.initialFilter.setorProducao;
    _selectedTipo = widget.initialFilter.tipoProduto;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ProdutoCategoryPickerSheet(
          categorias: widget.categorias,
          selectedCategoria: _selectedCategoria,
          iconForCategoryName: widget.iconForCategoryName,
        );
      },
    );

    if (picked != null || picked != _selectedCategoria) {
      setState(() => _selectedCategoria = picked);
    }
  }

  void _apply() {
    Navigator.pop(
      context,
      ProdutoListFilter(
        categoriaId: _selectedCategoria != null
            ? int.tryParse(_selectedCategoria!)
            : null,
        precoMin: double.tryParse(_minController.text.replaceAll(',', '.')),
        precoMax: double.tryParse(_maxController.text.replaceAll(',', '.')),
        descricao: _descricaoController.text.trim(),
        tipoProduto: _selectedTipo,
        setorProducao: _selectedSector,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriaSelecionada = _selectedCategoria != null
        ? widget.categoryNameBuilder(int.tryParse(_selectedCategoria!))
        : 'Todas';

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        decoration: const BoxDecoration(
          color: ProdutosPalette.surface,
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
                      color: ProdutosPalette.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filtrar produtos',
                        style: TextStyle(
                          color: ProdutosPalette.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: ProdutosPalette.text,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Categoria',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickCategory,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ProdutosPalette.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ProdutosPalette.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _selectedCategoria != null
                                      ? ProdutosPalette.primary
                                      : ProdutosPalette.inputFill,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  widget.iconForCategoryName(
                                    categoriaSelecionada,
                                  ),
                                  color: _selectedCategoria != null
                                      ? Colors.white
                                      : ProdutosPalette.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Categoria',
                                      style: TextStyle(
                                        color: ProdutosPalette.text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      categoriaSelecionada,
                                      style: TextStyle(
                                        color: _selectedCategoria != null
                                            ? ProdutosPalette.text
                                            : ProdutosPalette.textMuted,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: ProdutosPalette.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Preco (R\$)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput(
                              controller: _minController,
                              hintText: 'Min',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInput(
                              controller: _maxController,
                              hintText: 'Max',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Descricao',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _descricaoController,
                        hintText: 'Termo presente na descricao',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tipo do produto',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.25,
                        children: ['UNITARIO', 'COMPOSTO', 'COMBO'].map((tipo) {
                          final selected = _selectedTipo == tipo;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTipo = selected ? null : tipo;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? ProdutosPalette.warningBg
                                    : ProdutosPalette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? ProdutosPalette.primary
                                      : ProdutosPalette.border,
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
                                              ? ProdutosPalette.primary
                                              : ProdutosPalette.inputFill,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          _iconForTipo(tipo),
                                          color: selected
                                              ? Colors.white
                                              : ProdutosPalette.primary,
                                          size: 18,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (selected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: ProdutosPalette.primary,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _labelForTipo(tipo),
                                    style: const TextStyle(
                                      color: ProdutosPalette.text,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Setor de producao',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: ['COZINHA', 'BAR', 'BALCAO', 'CAIXA'].map((
                          setor,
                        ) {
                          final selected = _selectedSector == setor;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSector = selected ? null : setor;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? ProdutosPalette.warningBg
                                    : ProdutosPalette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? ProdutosPalette.primary
                                      : ProdutosPalette.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? ProdutosPalette.primary
                                          : ProdutosPalette.inputFill,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _iconForSetor(setor),
                                      color: selected
                                          ? Colors.white
                                          : ProdutosPalette.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _labelForSetor(setor),
                                      style: const TextStyle(
                                        color: ProdutosPalette.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: selected
                                        ? ProdutosPalette.primary
                                        : ProdutosPalette.border,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ProdutosPalette.text,
                            backgroundColor: ProdutosPalette.surfaceAlt,
                            side: const BorderSide(
                              color: ProdutosPalette.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ProdutosPalette.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: ProdutosPalette.primarySoft
                                .withValues(alpha: 0.55),
                            disabledForegroundColor: Colors.white.withValues(
                              alpha: 0.8,
                            ),
                            elevation: 4,
                            shadowColor: ProdutosPalette.primaryPressed
                                .withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Filtrar'),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded, size: 18),
                            ],
                          ),
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
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ProdutosPalette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProdutosPalette.border),
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: ProdutosPalette.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: ProdutosPalette.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 12 : 14,
          ),
        ),
      ),
    );
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'UNITARIO':
        return Icons.inventory_2_rounded;
      case 'COMPOSTO':
        return Icons.layers_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  String _labelForTipo(String tipo) {
    switch (tipo) {
      case 'UNITARIO':
        return 'Unitario';
      case 'COMPOSTO':
        return 'Composto';
      default:
        return 'Combo';
    }
  }

  IconData _iconForSetor(String setor) {
    switch (setor) {
      case 'COZINHA':
        return Icons.dining_rounded;
      case 'BAR':
        return Icons.wine_bar_rounded;
      case 'BALCAO':
        return Icons.storefront_rounded;
      default:
        return Icons.point_of_sale_rounded;
    }
  }

  String _labelForSetor(String setor) {
    switch (setor) {
      case 'COZINHA':
        return 'Cozinha';
      case 'BAR':
        return 'Bar';
      case 'BALCAO':
        return 'Balcao';
      default:
        return 'Caixa';
    }
  }
}

class _ProdutoCategoryPickerSheet extends StatelessWidget {
  final List<Categoria> categorias;
  final String? selectedCategoria;
  final IconData Function(String name) iconForCategoryName;

  const _ProdutoCategoryPickerSheet({
    required this.categorias,
    required this.selectedCategoria,
    required this.iconForCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: Container(
        decoration: const BoxDecoration(
          color: ProdutosPalette.surface,
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
                      color: ProdutosPalette.borderSoft,
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
                          color: ProdutosPalette.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: ProdutosPalette.text,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: categorias.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 42,
                                color: ProdutosPalette.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Sem categorias',
                                style: TextStyle(
                                  color: ProdutosPalette.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: categorias.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildOption(
                                context,
                                label: 'Todas',
                                icon: Icons.grid_view_rounded,
                                selected: selectedCategoria == null,
                                onTap: () => Navigator.pop(context, null),
                              );
                            }

                            final categoria = categorias[index - 1];
                            final selected =
                                selectedCategoria != null &&
                                int.tryParse(selectedCategoria!) ==
                                    categoria.id;

                            return _buildOption(
                              context,
                              label: categoria.nome,
                              icon: iconForCategoryName(categoria.nome),
                              selected: selected,
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  categoria.id?.toString(),
                                );
                              },
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
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? ProdutosPalette.warningBg
              : ProdutosPalette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? ProdutosPalette.primary : ProdutosPalette.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? ProdutosPalette.primary
                    : ProdutosPalette.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : ProdutosPalette.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: ProdutosPalette.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, color: ProdutosPalette.primary)
            else
              const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
