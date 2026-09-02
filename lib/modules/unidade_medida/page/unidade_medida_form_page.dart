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

  /// Unidades básicas cobradas pela documentação. A seleção define
  /// simultaneamente o símbolo enviado à API e o tipo (MASSA / VOLUME /
  /// UNIDADE) — que fica implícito na escolha.
  static const List<_UnidadeBase> _bases = [
    _UnidadeBase(
        nome: 'Grama', simbolo: 'g', tipo: 'MASSA', fator: 1),
    _UnidadeBase(
        nome: 'Quilograma', simbolo: 'kg', tipo: 'MASSA', fator: 1000),
    _UnidadeBase(
        nome: 'Mililitro', simbolo: 'mL', tipo: 'VOLUME', fator: 1),
    _UnidadeBase(
        nome: 'Litro', simbolo: 'L', tipo: 'VOLUME', fator: 1000),
    _UnidadeBase(
        nome: 'Unidade', simbolo: 'un', tipo: 'UNIDADE', fator: 1),
    _UnidadeBase(
        nome: 'Dúzia', simbolo: 'dz', tipo: 'UNIDADE', fator: 12),
  ];

  final _chaveFormulario = GlobalKey<FormState>();
  final _controleNome = TextEditingController();
  final _controleFator = TextEditingController();

  /// Base selecionada. Guarda o símbolo e o tipo internamente — o
  /// usuário não vê mais esses campos separados.
  _UnidadeBase? _baseSelecionada;

  /// Fallback: quando a unidade em edição foi cadastrada antes desta
  /// tela (ex.: `csp`, `cx`) e não bate com nenhuma das 6 bases atuais.
  /// Nesse caso guardamos o símbolo/tipo originais e mostramos como
  /// "customizada" (bloqueada).
  String? _simboloLegado;
  String? _tipoLegado;

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final u = widget.unidade;
    if (u == null) return;

    _controleNome.text = u.nome ?? '';
    if (u.fatorParaBase != null) {
      final f = u.fatorParaBase!;
      _controleFator.text = f == f.truncateToDouble()
          ? f.toInt().toString()
          : f.toString();
    }
    // Tenta casar o símbolo original com uma das bases conhecidas.
    _baseSelecionada = _bases.firstWhere(
      (b) => b.simbolo == u.simbolo,
      orElse: () => const _UnidadeBase(
          nome: '', simbolo: '', tipo: '', fator: 0),
    );
    if (_baseSelecionada!.simbolo.isEmpty) {
      _baseSelecionada = null;
      _simboloLegado = u.simbolo;
      _tipoLegado = u.tipoMedida;
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
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

  void _selecionarBase(_UnidadeBase base) {
    setState(() {
      _baseSelecionada = base;
      // Só sobrescreve o nome se o usuário ainda não digitou nada ou
      // se o valor atual corresponde ao nome de outra base — evita
      // apagar o que ele estava editando.
      final nomeAtual = _controleNome.text.trim();
      final nomeVazio = nomeAtual.isEmpty;
      final nomeEraDeOutraBase =
          _bases.any((b) => b.nome == nomeAtual);
      if (nomeVazio || nomeEraDeOutraBase) {
        _controleNome.text = base.nome;
      }
      _controleFator.text = base.fator == base.fator.truncate()
          ? base.fator.toInt().toString()
          : base.fator.toString();
    });
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    if (_baseSelecionada == null && _simboloLegado == null) {
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
        // Símbolo e tipo continuam bloqueados após o cadastro — mandamos
        // os valores originais da unidade.
        final dto = UnidadeMedidaUpdateRequest(
          nome: _controleNome.text.trim(),
          simbolo: widget.unidade!.simbolo ?? '',
          ativo: widget.unidade!.ativo ?? true,
        );
        await editarUnidadeMedida(widget.unidade!.id!, dto);
      } else {
        final base = _baseSelecionada!;
        final fatorTexto =
            _controleFator.text.trim().replaceAll(',', '.');
        final fator = double.tryParse(fatorTexto) ?? base.fator;
        final dto = UnidadeMedidaCreateRequest(
          nome: _controleNome.text.trim(),
          simbolo: base.simbolo,
          tipoMedida: base.tipo,
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
                          opacity: widget.ehEdicao ? 0.6 : 1.0,
                          child: _construirGradeBases(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppTema.bordaCampo),
                      const SizedBox(height: 12),
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
                            : 'Escolha a base (g/kg/mL/L/un/dz), dê um nome à sua unidade e informe o fator. Ex.: 1 kg = 1000 g → fator 1000. Use 1 para uma unidade base.',
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

  Widget _construirGradeBases() {
    // Se estamos editando uma unidade legada (símbolo fora das 6 bases),
    // mostramos um card "customizado" no lugar da grade, indicando o
    // símbolo/tipo originais.
    if (widget.ehEdicao && _simboloLegado != null) {
      final cor = _tipoColor(_tipoLegado ?? '');
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(_tipoIconData(_tipoLegado ?? ''), color: cor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _simboloLegado!,
                    style: TextStyle(
                      color: cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unidade customizada · ${_tipoNome(_tipoLegado ?? '')}',
                    style: const TextStyle(
                        color: AppTema.textoSecundario, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Layout responsivo: 3 colunas por padrão. Cada card mostra
        // o símbolo em destaque e o nome abaixo.
        const colunas = 3;
        const espaco = 8.0;
        final larguraCard =
            (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: _bases.map((base) {
            final selecionado =
                _baseSelecionada?.simbolo == base.simbolo;
            final cor = _tipoColor(base.tipo);
            return SizedBox(
              width: larguraCard,
              child: GestureDetector(
                onTap: () => _selecionarBase(base),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selecionado ? cor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionado ? cor : AppTema.bordaCampo,
                      width: selecionado ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tipoIconData(base.tipo),
                        color: selecionado ? Colors.white : cor,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        base.simbolo,
                        style: TextStyle(
                          color: selecionado
                              ? Colors.white
                              : AppTema.textoEscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        base.nome,
                        style: TextStyle(
                          color: selecionado
                              ? Colors.white
                              : AppTema.textoSecundario,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _UnidadeBase {
  final String nome;
  final String simbolo;
  final String tipo;
  final double fator;

  const _UnidadeBase({
    required this.nome,
    required this.simbolo,
    required this.tipo,
    required this.fator,
  });
}
