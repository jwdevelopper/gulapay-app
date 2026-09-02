import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class PainelEditorMesa extends StatefulWidget {
  const PainelEditorMesa({
    super.key,
    required this.areas,
    required this.idAreaInicial,
    this.mesa,
  });

  final List<AreaRestaurante> areas;
  final String idAreaInicial;
  final MesaRestaurante? mesa;

  @override
  State<PainelEditorMesa> createState() => _PainelEditorMesaState();
}

class _PainelEditorMesaState extends State<PainelEditorMesa> {
  final _chaveFormulario = GlobalKey<FormState>();

  late final TextEditingController _controleCodigo;
  late final TextEditingController _controleCadeiras;
  late final TextEditingController _controleLargura;
  late final TextEditingController _controleAltura;
  late final TextEditingController _controlePessoasSentadas;

  late String _idAreaSelecionada;
  late FormatoMesa _formatoSelecionado;
  late double _larguraSelecionada;
  late double _alturaSelecionada;

  @override
  void initState() {
    super.initState();
    final mesa = widget.mesa;
    _controleCodigo = TextEditingController(text: mesa?.codigo ?? '');
    _controleCadeiras = TextEditingController(
      text: (mesa?.quantidadeCadeiras ?? 4).toString(),
    );
    _controleLargura = TextEditingController(
      text: (mesa?.width ?? 112).toStringAsFixed(0),
    );
    _controleAltura = TextEditingController(
      text: (mesa?.height ?? 84).toStringAsFixed(0),
    );
    _controlePessoasSentadas = TextEditingController(
      text: mesa?.pessoasSentadas?.toString() ?? '',
    );
    _idAreaSelecionada = mesa?.idArea ?? widget.idAreaInicial;
    _formatoSelecionado = mesa?.formato ?? FormatoMesa.retangular;
    _larguraSelecionada = mesa?.width ?? 112;
    _alturaSelecionada = mesa?.height ?? 84;
  }

  @override
  void dispose() {
    _controleCodigo.dispose();
    _controleCadeiras.dispose();
    _controleLargura.dispose();
    _controleAltura.dispose();
    _controlePessoasSentadas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final mesa = widget.mesa;
    final temComandaAtiva = mesa?.idComandaAtiva != null;
    final estaUnida = mesa?.estaUnida ?? false;

    return Container(
      decoration: const BoxDecoration(
        color: GulaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _chaveFormulario,
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
                widget.mesa == null ? 'Nova mesa' : 'Editar mesa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Defina ambiente, formato, capacidade e tamanho visual.',
                style: TextStyle(color: GulaColors.textMuted),
              ),
              const SizedBox(height: 20),
              Center(
                child: _PreviaEdicaoMesa(
                  formato: _formatoSelecionado,
                  width: _larguraSelecionada,
                  height: _alturaSelecionada,
                  rotulo: _controleCodigo.text.trim().isEmpty
                      ? 'Mesa'
                      : _controleCodigo.text.trim(),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _controleCodigo,
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
                initialValue: _idAreaSelecionada,
                decoration: InputDecoration(
                  labelText: 'Area',
                  helperText: estaUnida
                      ? 'Separe o grupo para mover de area.'
                      : temComandaAtiva
                      ? 'Encerre a comanda para mover de area.'
                      : null,
                ),
                items: widget.areas
                    .map(
                      (area) => DropdownMenuItem<String>(
                        value: area.id,
                        child: Text(area.nome),
                      ),
                    )
                    .toList(),
                onChanged: estaUnida || temComandaAtiva
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _idAreaSelecionada = value;
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
                children: FormatoMesa.values
                    .map(
                      (formato) => ChoiceChip(
                        selected: _formatoSelecionado == formato,
                        label: Text(_rotuloFormato(formato)),
                        avatar: Icon(_iconeFormato(formato), size: 16),
                        onSelected: (_) {
                          setState(() {
                            _formatoSelecionado = formato;
                            _aplicarDimensoesFormato(formato);
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
                      controller: _controleCadeiras,
                      decoration: const InputDecoration(labelText: 'Cadeiras'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validarNumeroPositivo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _controlePessoasSentadas,
                      decoration: const InputDecoration(
                        labelText: 'Pessoas sentadas',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        return _validarNumeroPositivo(value);
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
                      controller: _controleLargura,
                      decoration: const InputDecoration(labelText: 'Largura'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final next = double.tryParse(value);
                        if (next == null) {
                          return;
                        }
                        setState(() {
                          _larguraSelecionada = next;
                        });
                      },
                      validator: _validarNumeroPositivo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _controleAltura,
                      decoration: const InputDecoration(labelText: 'Altura'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        final next = double.tryParse(value);
                        if (next == null) {
                          return;
                        }
                        setState(() {
                          _alturaSelecionada = next;
                        });
                      },
                      validator: _validarNumeroPositivo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OpcaoPredefinida(
                    rotulo: 'Compacta',
                    aoTocar: () => _definirDimensoes(88, 74),
                  ),
                  _OpcaoPredefinida(
                    rotulo: 'Padrao',
                    aoTocar: () => _definirDimensoes(112, 84),
                  ),
                  _OpcaoPredefinida(
                    rotulo: 'Grande',
                    aoTocar: () => _definirDimensoes(148, 92),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  child: const Text('Salvar mesa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validarNumeroPositivo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio.';
    }
    final number = num.tryParse(value);
    if (number == null || number <= 0) {
      return 'Informe um valor valido.';
    }
    return null;
  }

  void _salvar() {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    final pessoasSentadas = _controlePessoasSentadas.text.trim().isEmpty
        ? null
        : int.tryParse(_controlePessoasSentadas.text.trim());
    final quantidadeCadeiras = int.parse(_controleCadeiras.text.trim());
    final width = double.parse(_controleLargura.text.trim());
    final height = double.parse(_controleAltura.text.trim());

    if (pessoasSentadas != null && pessoasSentadas > quantidadeCadeiras) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pessoas sentadas nao podem passar da capacidade.'),
        ),
      );
      return;
    }
    if (widget.mesa?.idComandaAtiva != null && (pessoasSentadas ?? 0) < 1) {
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
      RascunhoMesa(
        id: widget.mesa?.id,
        codigo: _controleCodigo.text.trim(),
        idArea: _idAreaSelecionada,
        formato: _formatoSelecionado,
        quantidadeCadeiras: quantidadeCadeiras,
        width: width,
        height: height,
        pessoasSentadas: pessoasSentadas,
      ),
    );
  }

  void _aplicarDimensoesFormato(FormatoMesa formato) {
    switch (formato) {
      case FormatoMesa.redonda:
      case FormatoMesa.quadrada:
        _definirDimensoes(92, 92, notificar: false);
        break;
      case FormatoMesa.retangular:
        _definirDimensoes(124, 84, notificar: false);
        break;
      case FormatoMesa.oval:
        _definirDimensoes(132, 82, notificar: false);
        break;
    }
  }

  void _definirDimensoes(double width, double height, {bool notificar = true}) {
    _larguraSelecionada = width;
    _alturaSelecionada = height;
    _controleLargura.text = width.toStringAsFixed(0);
    _controleAltura.text = height.toStringAsFixed(0);
    if (notificar) {
      setState(() {});
    }
  }

  String _rotuloFormato(FormatoMesa formato) {
    switch (formato) {
      case FormatoMesa.redonda:
        return 'Redonda';
      case FormatoMesa.quadrada:
        return 'Quadrada';
      case FormatoMesa.retangular:
        return 'Retangular';
      case FormatoMesa.oval:
        return 'Oval';
    }
  }

  IconData _iconeFormato(FormatoMesa formato) {
    switch (formato) {
      case FormatoMesa.redonda:
        return Icons.circle_outlined;
      case FormatoMesa.quadrada:
        return Icons.crop_square_rounded;
      case FormatoMesa.retangular:
        return Icons.rectangle_outlined;
      case FormatoMesa.oval:
        return Icons.radio_button_unchecked_rounded;
    }
  }
}

class _PreviaEdicaoMesa extends StatelessWidget {
  const _PreviaEdicaoMesa({
    required this.formato,
    required this.width,
    required this.height,
    required this.rotulo,
  });

  final FormatoMesa formato;
  final double width;
  final double height;
  final String rotulo;

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
          shape: formato == FormatoMesa.redonda
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: formato == FormatoMesa.redonda
              ? null
              : BorderRadius.circular(formato == FormatoMesa.oval ? 999 : 18),
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
          rotulo,
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

class _OpcaoPredefinida extends StatelessWidget {
  const _OpcaoPredefinida({required this.rotulo, required this.aoTocar});

  final String rotulo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.straighten_rounded, size: 16),
      label: Text(rotulo),
      onPressed: aoTocar,
    );
  }
}
