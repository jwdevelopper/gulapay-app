import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class TableEditorSheet extends StatefulWidget {
  const TableEditorSheet({
    super.key,
    required this.areas,
    required this.initialAreaId,
    this.table,
  });

  final List<RestaurantArea> areas;
  final String initialAreaId;
  final RestaurantTable? table;

  @override
  State<TableEditorSheet> createState() => _TableEditorSheetState();
}

class _TableEditorSheetState extends State<TableEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _chairsController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _seatedController;

  late String _selectedAreaId;
  late TableShape _selectedShape;
  late double _selectedWidth;
  late double _selectedHeight;

  @override
  void initState() {
    super.initState();
    final table = widget.table;
    _codeController = TextEditingController(text: table?.code ?? '');
    _chairsController = TextEditingController(
      text: (table?.chairsCount ?? 4).toString(),
    );
    _widthController = TextEditingController(
      text: (table?.width ?? 112).toStringAsFixed(0),
    );
    _heightController = TextEditingController(
      text: (table?.height ?? 84).toStringAsFixed(0),
    );
    _seatedController = TextEditingController(
      text: table?.seatedPeople?.toString() ?? '',
    );
    _selectedAreaId = table?.areaId ?? widget.initialAreaId;
    _selectedShape = table?.shape ?? TableShape.rectangular;
    _selectedWidth = table?.width ?? 112;
    _selectedHeight = table?.height ?? 84;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _chairsController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _seatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final table = widget.table;
    final hasActiveOrder = table?.activeOrderId != null;
    final isJoined = table?.isJoined ?? false;

    return Container(
      decoration: const BoxDecoration(
        color: GulaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: GulaColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                widget.table == null ? 'Nova mesa' : 'Editar mesa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Defina ambiente, formato, capacidade e tamanho visual.',
                style: TextStyle(color: GulaColors.textMuted),
              ),
              const SizedBox(height: 20),
              Center(
                child: _TableEditPreview(
                  shape: _selectedShape,
                  width: _selectedWidth,
                  height: _selectedHeight,
                  label: _codeController.text.trim().isEmpty
                      ? 'Mesa'
                      : _codeController.text.trim(),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Codigo da mesa'),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um codigo para a mesa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedAreaId,
                decoration: InputDecoration(
                  labelText: 'Area',
                  helperText: isJoined
                      ? 'Separe o grupo para mover de area.'
                      : hasActiveOrder
                      ? 'Encerre a comanda para mover de area.'
                      : null,
                ),
                items: widget.areas
                    .map(
                      (area) => DropdownMenuItem<String>(
                        value: area.id,
                        child: Text(area.name),
                      ),
                    )
                    .toList(),
                onChanged: isJoined || hasActiveOrder
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedAreaId = value;
                        });
                      },
              ),
              const SizedBox(height: 14),
              const Text(
                'Formato',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TableShape.values
                    .map(
                      (shape) => ChoiceChip(
                        selected: _selectedShape == shape,
                        label: Text(_shapeLabel(shape)),
                        avatar: Icon(_shapeIcon(shape), size: 16),
                        onSelected: (_) {
                          setState(() {
                            _selectedShape = shape;
                            _applyShapePreset(shape);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chairsController,
                      decoration: const InputDecoration(labelText: 'Cadeiras'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _seatedController,
                      decoration: const InputDecoration(
                        labelText: 'Pessoas sentadas',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        return _validatePositiveNumber(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(labelText: 'Largura'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final next = double.tryParse(value);
                        if (next == null) {
                          return;
                        }
                        setState(() {
                          _selectedWidth = next;
                        });
                      },
                      validator: _validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Altura'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final next = double.tryParse(value);
                        if (next == null) {
                          return;
                        }
                        setState(() {
                          _selectedHeight = next;
                        });
                      },
                      validator: _validatePositiveNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetChip(
                    label: 'Compacta',
                    onTap: () => _setDimensions(88, 74),
                  ),
                  _PresetChip(
                    label: 'Padrao',
                    onTap: () => _setDimensions(112, 84),
                  ),
                  _PresetChip(
                    label: 'Grande',
                    onTap: () => _setDimensions(148, 92),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Salvar mesa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio.';
    }
    final number = num.tryParse(value);
    if (number == null || number <= 0) {
      return 'Informe um valor valido.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final seatedPeople = _seatedController.text.trim().isEmpty
        ? null
        : int.tryParse(_seatedController.text.trim());
    final chairsCount = int.parse(_chairsController.text.trim());
    final width = double.parse(_widthController.text.trim());
    final height = double.parse(_heightController.text.trim());

    if (seatedPeople != null && seatedPeople > chairsCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pessoas sentadas nao podem passar da capacidade.'),
        ),
      );
      return;
    }
    if (widget.table?.activeOrderId != null && (seatedPeople ?? 0) < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mesa com comanda ativa precisa manter pessoas sentadas.',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      TableDraft(
        id: widget.table?.id,
        code: _codeController.text.trim(),
        areaId: _selectedAreaId,
        shape: _selectedShape,
        chairsCount: chairsCount,
        width: width,
        height: height,
        seatedPeople: seatedPeople,
      ),
    );
  }

  void _applyShapePreset(TableShape shape) {
    switch (shape) {
      case TableShape.round:
      case TableShape.square:
        _setDimensions(92, 92, notify: false);
        break;
      case TableShape.rectangular:
        _setDimensions(124, 84, notify: false);
        break;
      case TableShape.oval:
        _setDimensions(132, 82, notify: false);
        break;
    }
  }

  void _setDimensions(double width, double height, {bool notify = true}) {
    _selectedWidth = width;
    _selectedHeight = height;
    _widthController.text = width.toStringAsFixed(0);
    _heightController.text = height.toStringAsFixed(0);
    if (notify) {
      setState(() {});
    }
  }

  String _shapeLabel(TableShape shape) {
    switch (shape) {
      case TableShape.round:
        return 'Redonda';
      case TableShape.square:
        return 'Quadrada';
      case TableShape.rectangular:
        return 'Retangular';
      case TableShape.oval:
        return 'Oval';
    }
  }

  IconData _shapeIcon(TableShape shape) {
    switch (shape) {
      case TableShape.round:
        return Icons.circle_outlined;
      case TableShape.square:
        return Icons.crop_square_rounded;
      case TableShape.rectangular:
        return Icons.rectangle_outlined;
      case TableShape.oval:
        return Icons.radio_button_unchecked_rounded;
    }
  }
}

class _TableEditPreview extends StatelessWidget {
  const _TableEditPreview({
    required this.shape,
    required this.width,
    required this.height,
    required this.label,
  });

  final TableShape shape;
  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    final previewWidth = width.clamp(72, 156).toDouble();
    final previewHeight = height.clamp(56, 112).toDouble();

    return Container(
      width: 210,
      height: 138,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GulaColors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GulaColors.border),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: previewWidth,
        height: previewHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: GulaColors.free,
          shape: shape == TableShape.round
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: shape == TableShape.round
              ? null
              : BorderRadius.circular(shape == TableShape.oval ? 999 : 18),
          border: Border.all(color: GulaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: GulaColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.straighten_rounded, size: 16),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
