import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

final _fundoCampoMesa = Color.alphaBlend(
  AppTema.fundo.withValues(alpha: 0.30),
  AppTema.cartao,
);

final _sombraCampoMesa = BoxShadow(
  color: AppTema.primariaEscura.withValues(alpha: 0.07),
  blurRadius: 12,
  offset: const Offset(0, 4),
);

class MesaFormularioPagina extends StatefulWidget {
  const MesaFormularioPagina({
    super.key,
    required this.areas,
    required this.idAreaInicial,
    this.mesa,
  });

  final List<AreaRestaurante> areas;
  final String idAreaInicial;
  final MesaRestaurante? mesa;

  bool get ehEdicao => mesa != null;

  @override
  State<MesaFormularioPagina> createState() => _MesaFormularioPaginaState();
}

class _MesaFormularioPaginaState extends State<MesaFormularioPagina> {
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

  bool get _temComandaAtiva => widget.mesa?.idComandaAtiva != null;
  bool get _estaUnida => widget.mesa?.estaUnida ?? false;

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
              widget.ehEdicao ? 'Editar mesa' : 'Nova mesa',
              style: const TextStyle(
                color: AppTema.textoEscuro,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Cadastro · Organização do ambiente',
              style: TextStyle(color: AppTema.textoSecundario, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: _chaveFormulario,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PreviaEdicaoMesa(
                            formato: _formatoSelecionado,
                            largura: _larguraSelecionada,
                            altura: _alturaSelecionada,
                            rotulo: _controleCodigo.text.trim().isEmpty
                                ? 'Mesa'
                                : _controleCodigo.text.trim(),
                          ),
                          const SizedBox(height: 22),
                          const AppRotulo('Código da mesa *'),
                          const SizedBox(height: 6),
                          AppCampoTexto(
                            controle: _controleCodigo,
                            dica: 'Ex.: Mesa 08',
                            tamanhoMax: 40,
                            aoMudar: (_) => setState(() {}),
                            validador: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Informe um código para a mesa';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          const AppRotulo('Área *'),
                          const SizedBox(height: 6),
                          _construirSeletorArea(),
                          if (_estaUnida || _temComandaAtiva) ...[
                            const SizedBox(height: 10),
                            AppDica(
                              _estaUnida
                                  ? 'Separe o grupo antes de mover esta mesa para outra área.'
                                  : 'Encerre a comanda antes de mover esta mesa para outra área.',
                              emoji: 'ℹ️',
                            ),
                          ],
                          const SizedBox(height: 18),
                          const AppRotulo('Formato *'),
                          const SizedBox(height: 8),
                          _construirOpcoesFormato(),
                          const SizedBox(height: 18),
                          _construirLinhaCapacidade(),
                          const SizedBox(height: 14),
                          _construirLinhaDimensoes(),
                          const SizedBox(height: 12),
                          _construirOpcoesTamanho(),
                          const SizedBox(height: 18),
                          const AppDica(
                            'As dimensões alteram apenas a representação visual da mesa no mapa.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
              iconeConfirmar: const Icon(Icons.chevron_right_rounded, size: 18),
              aoCancelar: () => Navigator.pop(context),
              aoConfirmar: _salvar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirSeletorArea() {
    final podeAlterar = !_estaUnida && !_temComandaAtiva;
    final areaSelecionada = _buscarAreaSelecionada();

    return InkWell(
      onTap: podeAlterar ? _abrirSeletorArea : null,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: podeAlterar ? _fundoCampoMesa : AppTema.fundoDica,
          border: Border.all(color: AppTema.bordaCampo),
          borderRadius: BorderRadius.circular(16),
          boxShadow: podeAlterar ? [_sombraCampoMesa] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTema.fundoDica,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppTema.primaria,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                areaSelecionada?.nome ?? 'Selecione uma área',
                style: TextStyle(
                  color: areaSelecionada == null
                      ? AppTema.textoSecundario
                      : AppTema.textoEscuro,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTema.primariaEscura,
            ),
          ],
        ),
      ),
    );
  }

  AreaRestaurante? _buscarAreaSelecionada() {
    for (final area in widget.areas) {
      if (area.id == _idAreaSelecionada) return area;
    }
    return null;
  }

  Future<void> _abrirSeletorArea() async {
    final idArea = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTema.fundo.withValues(alpha: 0),
      barrierColor: AppTema.textoEscuro.withValues(alpha: 0.32),
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (contextoModal) => FractionallySizedBox(
        heightFactor: 0.58,
        child: _SeletorAreaMesa(
          areas: widget.areas,
          idAreaSelecionada: _idAreaSelecionada,
          aoSelecionar: (id) => Navigator.pop(contextoModal, id),
          aoFechar: () => Navigator.pop(contextoModal),
        ),
      ),
    );

    if (idArea == null || !mounted) return;
    setState(() => _idAreaSelecionada = idArea);
  }

  Widget _construirOpcoesFormato() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraOpcao = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FormatoMesa.values
              .map(
                (formato) => SizedBox(
                  width: larguraOpcao,
                  child: _OpcaoFormato(
                    rotulo: _rotuloFormato(formato),
                    icone: _iconeFormato(formato),
                    selecionada: _formatoSelecionado == formato,
                    aoTocar: () {
                      setState(() {
                        _formatoSelecionado = formato;
                        _aplicarDimensoesFormato(formato);
                      });
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _construirLinhaCapacidade() {
    return _construirCamposResponsivos(
      primeiro: _CampoNumericoMesa(
        rotulo: 'Cadeiras *',
        dica: 'Ex.: 4',
        controle: _controleCadeiras,
        validador: _validarNumeroPositivo,
      ),
      segundo: _CampoNumericoMesa(
        rotulo: 'Pessoas sentadas',
        dica: 'Opcional',
        controle: _controlePessoasSentadas,
        validador: (valor) {
          if (valor == null || valor.trim().isEmpty) return null;
          return _validarNumeroPositivo(valor);
        },
      ),
    );
  }

  Widget _construirLinhaDimensoes() {
    return _construirCamposResponsivos(
      primeiro: _CampoNumericoMesa(
        rotulo: 'Largura *',
        dica: 'Ex.: 112',
        controle: _controleLargura,
        validador: _validarNumeroPositivo,
        aoMudar: (valor) {
          final largura = double.tryParse(valor);
          if (largura == null) return;
          setState(() => _larguraSelecionada = largura);
        },
      ),
      segundo: _CampoNumericoMesa(
        rotulo: 'Altura *',
        dica: 'Ex.: 84',
        controle: _controleAltura,
        validador: _validarNumeroPositivo,
        aoMudar: (valor) {
          final altura = double.tryParse(valor);
          if (altura == null) return;
          setState(() => _alturaSelecionada = altura);
        },
      ),
    );
  }

  Widget _construirCamposResponsivos({
    required Widget primeiro,
    required Widget segundo,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 440) {
          return Column(
            children: [primeiro, const SizedBox(height: 14), segundo],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primeiro),
            const SizedBox(width: 12),
            Expanded(child: segundo),
          ],
        );
      },
    );
  }

  Widget _construirOpcoesTamanho() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _OpcaoPredefinida(
          rotulo: 'Compacta',
          selecionada: _dimensoesSao(88, 74),
          aoTocar: () => _definirDimensoes(88, 74),
        ),
        _OpcaoPredefinida(
          rotulo: 'Padrão',
          selecionada: _dimensoesSao(112, 84),
          aoTocar: () => _definirDimensoes(112, 84),
        ),
        _OpcaoPredefinida(
          rotulo: 'Grande',
          selecionada: _dimensoesSao(148, 92),
          aoTocar: () => _definirDimensoes(148, 92),
        ),
      ],
    );
  }

  bool _dimensoesSao(double largura, double altura) {
    return _larguraSelecionada == largura && _alturaSelecionada == altura;
  }

  String? _validarNumeroPositivo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    final numero = num.tryParse(valor);
    if (numero == null || numero <= 0) {
      return 'Informe um valor válido';
    }
    return null;
  }

  void _salvar() {
    if (!_chaveFormulario.currentState!.validate()) return;

    if (_idAreaSelecionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma área para a mesa.')),
      );
      return;
    }

    final pessoasSentadas = _controlePessoasSentadas.text.trim().isEmpty
        ? null
        : int.tryParse(_controlePessoasSentadas.text.trim());
    final quantidadeCadeiras = int.parse(_controleCadeiras.text.trim());

    if (pessoasSentadas != null && pessoasSentadas > quantidadeCadeiras) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A quantidade de pessoas excede a capacidade da mesa.'),
        ),
      );
      return;
    }
    if (_temComandaAtiva && (pessoasSentadas ?? 0) < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Uma mesa com comanda ativa precisa manter pessoas sentadas.',
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
        width: double.parse(_controleLargura.text.trim()),
        height: double.parse(_controleAltura.text.trim()),
        pessoasSentadas: pessoasSentadas,
      ),
    );
  }

  void _aplicarDimensoesFormato(FormatoMesa formato) {
    switch (formato) {
      case FormatoMesa.redonda:
      case FormatoMesa.quadrada:
        _definirDimensoes(92, 92, notificar: false);
      case FormatoMesa.retangular:
        _definirDimensoes(124, 84, notificar: false);
      case FormatoMesa.oval:
        _definirDimensoes(132, 82, notificar: false);
    }
  }

  void _definirDimensoes(
    double largura,
    double altura, {
    bool notificar = true,
  }) {
    _larguraSelecionada = largura;
    _alturaSelecionada = altura;
    _controleLargura.text = largura.toStringAsFixed(0);
    _controleAltura.text = altura.toStringAsFixed(0);
    if (notificar) setState(() {});
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

class _CampoNumericoMesa extends StatelessWidget {
  const _CampoNumericoMesa({
    required this.rotulo,
    required this.dica,
    required this.controle,
    required this.validador,
    this.aoMudar,
  });

  final String rotulo;
  final String dica;
  final TextEditingController controle;
  final String? Function(String?) validador;
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRotulo(rotulo),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: controle,
          dica: dica,
          tipoTeclado: TextInputType.number,
          formatadores: [FilteringTextInputFormatter.digitsOnly],
          validador: validador,
          aoMudar: aoMudar,
        ),
      ],
    );
  }
}

class _SeletorAreaMesa extends StatelessWidget {
  const _SeletorAreaMesa({
    required this.areas,
    required this.idAreaSelecionada,
    required this.aoSelecionar,
    required this.aoFechar,
  });

  final List<AreaRestaurante> areas;
  final String idAreaSelecionada;
  final ValueChanged<String> aoSelecionar;
  final VoidCallback aoFechar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTema.fundo,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
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
                  color: AppTema.bordaCampo,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escolha a área',
                        style: TextStyle(
                          color: AppTema.textoEscuro,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Defina onde a mesa ficará no mapa.',
                        style: TextStyle(
                          color: AppTema.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar seleção',
                  onPressed: aoFechar,
                  icon: const Icon(Icons.close_rounded),
                  color: AppTema.textoEscuro,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: areas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma área disponível.',
                        style: TextStyle(color: AppTema.textoSecundario),
                      ),
                    )
                  : ListView.separated(
                      itemCount: areas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, indice) {
                        final area = areas[indice];
                        final selecionada = area.id == idAreaSelecionada;
                        return _OpcaoAreaMesa(
                          area: area,
                          selecionada: selecionada,
                          aoTocar: () => aoSelecionar(area.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoAreaMesa extends StatelessWidget {
  const _OpcaoAreaMesa({
    required this.area,
    required this.selecionada,
    required this.aoTocar,
  });

  final AreaRestaurante area;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selecionada
              ? AppTema.primaria.withValues(alpha: 0.12)
              : _fundoCampoMesa,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selecionada ? AppTema.primaria : AppTema.bordaCampo,
            width: selecionada ? 1.5 : 1,
          ),
          boxShadow: selecionada ? null : [_sombraCampoMesa],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selecionada ? AppTema.primaria : AppTema.fundoDica,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.table_restaurant_outlined,
                color: selecionada ? AppTema.cartao : AppTema.primaria,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    area.nome,
                    style: const TextStyle(
                      color: AppTema.textoEscuro,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatarTipoArea(area.tipo),
                    style: const TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selecionada)
              const Icon(Icons.check_rounded, color: AppTema.primaria),
          ],
        ),
      ),
    );
  }

  String _formatarTipoArea(String tipo) {
    if (tipo.isEmpty) return 'Ambiente do restaurante';
    return '${tipo[0].toUpperCase()}${tipo.substring(1).toLowerCase()}';
  }
}

class _PreviaEdicaoMesa extends StatelessWidget {
  const _PreviaEdicaoMesa({
    required this.formato,
    required this.largura,
    required this.altura,
    required this.rotulo,
  });

  final FormatoMesa formato;
  final double largura;
  final double altura;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final larguraPrevia = largura.clamp(72, 156).toDouble();
    final alturaPrevia = altura.clamp(56, 112).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _fundoCampoMesa,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppTema.primariaEscura,
              ),
              SizedBox(width: 8),
              Text(
                'Prévia no mapa',
                style: TextStyle(
                  color: AppTema.textoEscuro,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 116,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (filho, animacao) {
                  return FadeTransition(
                    opacity: animacao,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.96,
                        end: 1,
                      ).animate(animacao),
                      child: filho,
                    ),
                  );
                },
                child: AnimatedContainer(
                  key: ValueKey(formato),
                  duration: const Duration(milliseconds: 180),
                  width: larguraPrevia,
                  height: alturaPrevia,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTema.primaria.withValues(alpha: 0.24),
                    shape: formato == FormatoMesa.redonda
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: formato == FormatoMesa.redonda
                        ? null
                        : BorderRadius.circular(
                            formato == FormatoMesa.oval ? 999 : 18,
                          ),
                    border: Border.all(
                      color: AppTema.primaria.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      rotulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTema.textoEscuro,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoFormato extends StatelessWidget {
  const _OpcaoFormato({
    required this.rotulo,
    required this.icone,
    required this.selecionada,
    required this.aoTocar,
  });

  final String rotulo;
  final IconData icone;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selecionada
              ? AppTema.primaria.withValues(alpha: 0.14)
              : _fundoCampoMesa,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionada ? AppTema.primaria : AppTema.bordaCampo,
            width: selecionada ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 18,
              color: selecionada ? AppTema.primaria : AppTema.primariaEscura,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rotulo,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTema.textoEscuro,
                  fontWeight: selecionada ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selecionada)
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppTema.primaria,
              ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoPredefinida extends StatelessWidget {
  const _OpcaoPredefinida({
    required this.rotulo,
    required this.selecionada,
    required this.aoTocar,
  });

  final String rotulo;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selecionada,
      avatar: Icon(
        Icons.straighten_rounded,
        size: 16,
        color: selecionada ? AppTema.primaria : AppTema.primariaEscura,
      ),
      label: Text(rotulo),
      labelStyle: TextStyle(
        color: AppTema.textoEscuro,
        fontWeight: selecionada ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: _fundoCampoMesa,
      selectedColor: AppTema.primaria.withValues(alpha: 0.14),
      side: BorderSide(
        color: selecionada ? AppTema.primaria : AppTema.bordaCampo,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (_) => aoTocar(),
    );
  }
}
