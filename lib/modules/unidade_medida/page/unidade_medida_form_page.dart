import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import '../dto/unidade_medida_create_request.dart';
import '../dto/unidade_medida_response.dart';
import '../dto/unidade_medida_update_request.dart';
import '../service/unidade_medida_service.dart';

class UnidadeMedidaFormPage extends StatefulWidget {
  final UnidadeMedidaResponse? unidade;

  const UnidadeMedidaFormPage({super.key, this.unidade});

  bool get ehEdicao => unidade != null;

  @override
  State<UnidadeMedidaFormPage> createState() =>
      _UnidadeMedidaFormPageState();
}

class _UnidadeMedidaFormPageState extends State<UnidadeMedidaFormPage> {
  static const int _limiteNome = 60;
  static const int _limiteSimbolo = 8;

  /// Unidades básicas recomendadas pela documentação — usadas como
  /// atalho no cadastro de novas unidades.
  static const List<_SugestaoUnidade> _sugestoes = [
    _SugestaoUnidade(
        nome: 'Grama', simbolo: 'g', tipo: 'MASSA', fator: 1),
    _SugestaoUnidade(
        nome: 'Quilograma', simbolo: 'kg', tipo: 'MASSA', fator: 1000),
    _SugestaoUnidade(
        nome: 'Mililitro', simbolo: 'mL', tipo: 'VOLUME', fator: 1),
    _SugestaoUnidade(
        nome: 'Litro', simbolo: 'L', tipo: 'VOLUME', fator: 1000),
    _SugestaoUnidade(
        nome: 'Unidade', simbolo: 'un', tipo: 'UNIDADE', fator: 1),
    _SugestaoUnidade(
        nome: 'Dúzia', simbolo: 'dz', tipo: 'UNIDADE', fator: 12),
  ];

  final _chaveFormulario = GlobalKey<FormState>();
  final _controleNome = TextEditingController();
  final _controleSimbolo = TextEditingController();
  final _controleFator = TextEditingController();
  String? _tipoSelecionado;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final u = widget.unidade;
    if (u != null) {
      _controleNome.text = u.nome ?? '';
      _controleSimbolo.text = u.simbolo ?? '';
      _tipoSelecionado = u.tipoMedida;
      if (u.fatorParaBase != null) {
        final f = u.fatorParaBase!;
        _controleFator.text = f == f.truncateToDouble()
            ? f.toInt().toString()
            : f.toString();
      }
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleSimbolo.dispose();
    _controleFator.dispose();
    super.dispose();
  }

  Color _tipoColor(String tipo) {
    switch (tipo) {
      case 'MASSA':
        return AppTema.primaria;
      case 'VOLUME':
        return const Color(0xFF5B8FD4);
      case 'UNIDADE':
        return const Color(0xFF4CAF50);
      default:
        return AppTema.primariaEscura;
    }
  }

  IconData _tipoIconData(String tipo) {
    switch (tipo) {
      case 'MASSA':
        return Icons.monitor_weight_outlined;
      case 'VOLUME':
        return Icons.water_drop_outlined;
      case 'UNIDADE':
        return Icons.tag;
      default:
        return Icons.straighten;
    }
  }

  String _tipoNome(String tipo) {
    switch (tipo) {
      case 'MASSA':
        return 'Massa';
      case 'VOLUME':
        return 'Volume';
      case 'UNIDADE':
        return 'Unidade';
      default:
        return tipo;
    }
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    if (_tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de medida.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      if (widget.ehEdicao) {
        final dto = UnidadeMedidaUpdateRequest(
          nome: _controleNome.text.trim(),
          simbolo: _controleSimbolo.text.trim(),
          ativo: widget.unidade!.ativo ?? true,
        );
        await editarUnidadeMedida(widget.unidade!.id!, dto);
      } else {
        final fatorTexto =
            _controleFator.text.trim().replaceAll(',', '.');
        final fator = double.tryParse(fatorTexto) ?? 1.0;
        final dto = UnidadeMedidaCreateRequest(
          nome: _controleNome.text.trim(),
          simbolo: _controleSimbolo.text.trim(),
          tipoMedida: _tipoSelecionado!,
          fatorParaBase: fator,
        );
        await criarUnidadeMedida(dto);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.ehEdicao ? 'Editar unidade' : 'Nova unidade',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            Text(
              widget.ehEdicao
                  ? 'Unidade de Medida · Edição'
                  : 'Unidade de Medida · Nova',
              style: const TextStyle(
                  fontSize: 12, color: AppTema.textoSecundario),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.ehEdicao) ...[
                        _construirSugestoesRapidas(),
                        const SizedBox(height: 18),
                      ],
                      AppRotulo(
                        'Nome *',
                        contador:
                            '${_controleNome.text.length}/$_limiteNome',
                      ),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleNome,
                        dica: 'Ex.: Quilograma',
                        tamanhoMax: _limiteNome,
                        aoMudar: (_) => setState(() {}),
                        validador: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome';
                          if (t.length < 2) return 'Mínimo de 2 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppRotulo(
                        'Símbolo *',
                        contador:
                            '${_controleSimbolo.text.length}/$_limiteSimbolo',
                      ),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleSimbolo,
                        dica: 'Ex.: kg, mL, csp',
                        tamanhoMax: _limiteSimbolo,
                        aoMudar: (_) => setState(() {}),
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o símbolo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppTema.bordaCampo),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.straighten,
                              size: 16, color: AppTema.primariaEscura),
                          const SizedBox(width: 8),
                          const Text(
                            'Tipo de medida *',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTema.textoEscuro),
                          ),
                          if (widget.ehEdicao) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.lock_outline,
                                size: 14,
                                color: AppTema.textoSecundario),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      IgnorePointer(
                        ignoring: widget.ehEdicao,
                        child: Opacity(
                          opacity: widget.ehEdicao ? 0.5 : 1.0,
                          child: Row(
                            children: ['MASSA', 'VOLUME', 'UNIDADE']
                                .map((tipo) {
                              final selecionado =
                                  _tipoSelecionado == tipo;
                              final cor = _tipoColor(tipo);
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _tipoSelecionado = tipo),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: selecionado
                                          ? cor
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selecionado
                                            ? cor
                                            : AppTema.bordaCampo,
                                        width: selecionado ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _tipoIconData(tipo),
                                          color: selecionado
                                              ? Colors.white
                                              : cor,
                                          size: 22,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _tipoNome(tipo),
                                          style: TextStyle(
                                            color: selecionado
                                                ? Colors.white
                                                : AppTema.textoEscuro,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppTema.bordaCampo),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calculate_outlined,
                              size: 16, color: AppTema.primariaEscura),
                          const SizedBox(width: 8),
                          const Text(
                            'Fator para a base *',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTema.textoEscuro),
                          ),
                          if (widget.ehEdicao) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.lock_outline,
                                size: 14,
                                color: AppTema.textoSecundario),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      IgnorePointer(
                        ignoring: widget.ehEdicao,
                        child: Opacity(
                          opacity: widget.ehEdicao ? 0.5 : 1.0,
                          child: AppCampoTexto(
                            controle: _controleFator,
                            dica: 'Ex.: 1000',
                            tipoTeclado:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            formatadores: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]')),
                            ],
                            habilitado: !widget.ehEdicao,
                            validador: widget.ehEdicao
                                ? null
                                : (v) {
                                    final t =
                                        v?.trim().replaceAll(',', '.') ??
                                            '';
                                    if (t.isEmpty) {
                                      return 'Informe o fator';
                                    }
                                    final n = double.tryParse(t);
                                    if (n == null || n <= 0) {
                                      return 'Fator deve ser maior que zero';
                                    }
                                    return null;
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppDica(
                        widget.ehEdicao
                            ? 'Tipo e fator são fixos após o cadastro. Para alterar, inative esta unidade e crie uma nova.'
                            : 'Quanto 1 unidade desta equivale à unidade base? Ex.: 1 kg = 1000 g → fator 1000. Use 1 para definir uma nova unidade base.',
                        emoji: widget.ehEdicao ? '🔒' : '💡',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
              iconeConfirmar:
                  const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              carregando: _carregando,
              aoCancelar: () => Navigator.pop(context),
              aoConfirmar: _salvar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSugestoesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.bolt_outlined,
                size: 16, color: AppTema.primariaEscura),
            SizedBox(width: 8),
            Text(
              'Sugestões rápidas',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTema.textoEscuro),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sugestoes.map((s) {
            final cor = _tipoColor(s.tipo);
            return ActionChip(
              onPressed: () => _aplicarSugestao(s),
              backgroundColor: Colors.white,
              side: BorderSide(color: cor.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_tipoIconData(s.tipo), size: 14, color: cor),
                  const SizedBox(width: 6),
                  Text(
                    '${s.simbolo} · ${s.nome}',
                    style: TextStyle(
                      color: AppTema.textoEscuro,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        const Text(
          'Toque em uma sugestão para preencher os campos automaticamente.',
          style:
              TextStyle(color: AppTema.textoSecundario, fontSize: 12),
        ),
      ],
    );
  }

  void _aplicarSugestao(_SugestaoUnidade s) {
    setState(() {
      _controleNome.text = s.nome;
      _controleSimbolo.text = s.simbolo;
      _tipoSelecionado = s.tipo;
      _controleFator.text = s.fator == s.fator.truncate()
          ? s.fator.toInt().toString()
          : s.fator.toString();
    });
  }
}

class _SugestaoUnidade {
  final String nome;
  final String simbolo;
  final String tipo;
  final double fator;

  const _SugestaoUnidade({
    required this.nome,
    required this.simbolo,
    required this.tipo,
    required this.fator,
  });
}
