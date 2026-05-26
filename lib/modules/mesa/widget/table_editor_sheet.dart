import 'package:flutter/material.dart';
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
                'Defina area, formato, capacidade e dimensoes sem sair do mapa.',
                style: TextStyle(color: GulaColors.textMuted),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Codigo da mesa'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um codigo para a mesa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedAreaId,
                decoration: const InputDecoration(labelText: 'Area'),
                items: widget.areas
                    .map(
                      (area) => DropdownMenuItem<String>(
                        value: area.id,
                        child: Text(area.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedAreaId = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<TableShape>(
                value: _selectedShape,
                decoration: const InputDecoration(labelText: 'Formato'),
                items: TableShape.values
                    .map(
                      (shape) => DropdownMenuItem<TableShape>(
                        value: shape,
                        child: Text(_shapeLabel(shape)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedShape = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chairsController,
                      decoration: const InputDecoration(labelText: 'Cadeiras'),
                      keyboardType: TextInputType.number,
                      validator: _validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _seatedController,
                      decoration: const InputDecoration(labelText: 'Pessoas sentadas'),
                      keyboardType: TextInputType.number,
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
                      validator: _validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Altura'),
                      keyboardType: TextInputType.number,
                      validator: _validatePositiveNumber,
                    ),
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

    Navigator.pop(
      context,
      TableDraft(
        id: widget.table?.id,
        code: _codeController.text.trim(),
        areaId: _selectedAreaId,
        shape: _selectedShape,
        chairsCount: int.parse(_chairsController.text.trim()),
        width: double.parse(_widthController.text.trim()),
        height: double.parse(_heightController.text.trim()),
        seatedPeople: seatedPeople,
      ),
    );
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
}
