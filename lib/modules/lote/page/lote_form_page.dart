import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_create_request.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_update.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_insumo_seletor.dart';
import 'package:my_app_teste/modules/insumo/components/unidade_medida_mock.dart';

class LoteFormPage extends StatefulWidget {
  /// Quando informado, a tela entra em modo de edição (PUT /lotes/{id}).
  final LoteResponse? lote;

  /// Insumo já selecionado na origem (ex.: vindo da LotesPage), usado como
  /// valor inicial na criação.
  final InsumoResponse? insumoInicial;

  const LoteFormPage({super.key, this.lote, this.insumoInicial});

  bool get ehEdicao => lote != null;

  @override
  State<LoteFormPage> createState() => _LoteFormPageState();
}

class _LoteFormPageState extends State<LoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final LoteService _service = LoteService();
  final UnidadeMedidaServiceMock _unidadeService = UnidadeMedidaServiceMock();

  final TextEditingController _codigo = TextEditingController();
  final TextEditingController _quantidade = TextEditingController();
  final TextEditingController _custo = TextEditingController();

  InsumoResponse? _insumo;
  DateTime? _validade;
  bool _ativo = true;

  List<UnidadeMedidaMock> _unidades = [];
  UnidadeMedidaMock? _unidadeSelecionada;
  bool _carregandoUnidades = false;

  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final lote = widget.lote;
    if (lote != null) {
      _codigo.text = lote.codigo ?? '';
      _quantidade.text =
          LoteFormatadores.formatarQuantidade(lote.quantidadeInicial);
      _custo.text = lote.custoUnitario == null
          ? ''
          : lote.custoUnitario!.toStringAsFixed(2).replaceAll('.', ',');
      _validade = LoteFormatadores.parseData(lote.validade);
      _ativo = lote.ativo ?? true;
    } else {
      _insumo = widget.insumoInicial;
      _carregarUnidades();
    }
  }

  @override
  void dispose() {
    _codigo.dispose();
    _quantidade.dispose();
    _custo.dispose();
    super.dispose();
  }

  Future<void> _carregarUnidades() async {
    setState(() => _carregandoUnidades = true);
    try {
      final lista = await _unidadeService.listar();
      if (!mounted) return;
      setState(() {
        _unidades = lista;
        _unidadeSelecionada = _unidadePadraoDoInsumo();
      });
    } catch (_) {
      // Sem unidades a tela ainda abre; o usuário verá o erro ao salvar.
    } finally {
      if (mounted) setState(() => _carregandoUnidades = false);
    }
  }

  UnidadeMedidaMock? _unidadePadraoDoInsumo() {
    final id = _insumo?.unidadePadraoId;
    if (id == null) return _unidadeSelecionada;
    for (final u in _unidades) {
      if (u.id == id) return u;
    }
    return _unidadeSelecionada;
  }

  Future<void> _selecionarInsumo() async {
    final insumo = await LoteInsumoSeletor.abrir(context);
    if (insumo == null) return;
    setState(() {
      _insumo = insumo;
      _unidadeSelecionada = _unidadePadraoDoInsumo();
    });
  }

  Future<void> _selecionarValidade() async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _validade ?? hoje,
      firstDate: DateTime(hoje.year - 5),
      lastDate: DateTime(hoje.year + 10),
      helpText: 'Selecione a validade',
    );
    if (selecionada == null) return;
    setState(() => _validade = selecionada);
  }

  String _isoDe(DateTime data) {
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '${data.year}-$mes-$dia';
  }

  double? _parseNumero(String texto) {
    final limpo = texto.trim().replaceAll('.', '').replaceAll(',', '.');
    if (limpo.isEmpty) return null;
    return double.tryParse(limpo);
  }

  String? _validar() {
    if (!widget.ehEdicao && _insumo?.id == null) {
      return 'Selecione o insumo.';
    }
    if (_validade == null) {
      return 'Informe a validade.';
    }
    if (!widget.ehEdicao) {
      final qtd = _parseNumero(_quantidade.text);
      if (qtd == null || qtd <= 0) {
        return 'A quantidade inicial deve ser maior que zero.';
      }
      if (_unidadeSelecionada?.id == null) {
        return 'Selecione a unidade.';
      }
      final custo = _parseNumero(_custo.text);
      if (custo == null || custo < 0) {
        return 'O custo unitário deve ser maior ou igual a zero.';
      }
    }
    return null;
  }

  Future<void> _salvar() async {
    final erroValidacao = _validar();
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      if (widget.ehEdicao) {
        await _service.atualizar(
          widget.lote!.id!,
          LoteUpdate(
            codigo: _codigo.text.trim().isEmpty ? null : _codigo.text.trim(),
            validade: _isoDe(_validade!),
            ativo: _ativo,
          ),
        );
      } else {
        await _service.criar(
          LoteCreateRequest(
            insumoId: _insumo!.id,
            codigo: _codigo.text.trim().isEmpty ? null : _codigo.text.trim(),
            validade: _isoDe(_validade!),
            quantidadeInicial: _parseNumero(_quantidade.text),
            unidadeId: _unidadeSelecionada!.id,
            custoUnitario: _parseNumero(_custo.text),
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.ehEdicao ? 'Lote atualizado.' : 'Lote criado.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
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
        iconTheme: const IconThemeData(color: AppTema.primariaEscura),
        title: Text(
          widget.ehEdicao ? 'Editar lote' : 'Novo lote',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTema.textoEscuro,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const AppDica(
              'Para registrar uma compra real, prefira Movimentação de Estoque. '
              'Este cadastro é indicado para inventário inicial ou correção administrativa.',
            ),
            const SizedBox(height: 16),
            _campoInsumo(),
            const SizedBox(height: 16),
            _campoValidade(),
            const SizedBox(height: 16),
            _campoCodigo(),
            const SizedBox(height: 16),
            if (!widget.ehEdicao) ...[
              _campoQuantidade(),
              const SizedBox(height: 16),
              _campoUnidade(),
              const SizedBox(height: 16),
              _campoCusto(),
            ] else
              _resumoSomenteLeitura(),
            if (widget.ehEdicao) ...[
              const SizedBox(height: 16),
              _campoAtivo(),
            ],
            if (_erro != null) ...[
              const SizedBox(height: 16),
              _mensagemErro(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: AppBarraAcoes(
        textoConfirmar: widget.ehEdicao ? 'Salvar' : 'Criar lote',
        carregando: _salvando,
        aoCancelar: () => Navigator.pop(context, false),
        aoConfirmar: _salvar,
      ),
    );
  }

  Widget _campoInsumo() {
    final nome = widget.ehEdicao
        ? (widget.lote?.insumoNome ?? '—')
        : (_insumo?.nome ?? 'Selecionar insumo');
    final unidade = widget.ehEdicao
        ? (widget.lote?.unidadePadraoSimbolo)
        : (_insumo?.unidadePadraoSimbolo ?? _insumo?.unidadePadrao);
    final selecionado = widget.ehEdicao || _insumo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Insumo'),
        const SizedBox(height: 6),
        Opacity(
          opacity: widget.ehEdicao ? 0.7 : 1,
          child: InkWell(
            onTap: widget.ehEdicao ? null : _selecionarInsumo,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTema.cartao,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTema.bordaCampo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      color: AppTema.primariaEscura, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selecionado
                                ? AppTema.textoEscuro
                                : const Color(0xFFB7A98A),
                          ),
                        ),
                        if (unidade != null && unidade.isNotEmpty)
                          Text(
                            'Unidade base: $unidade',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTema.textoSecundario,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!widget.ehEdicao)
                    const Icon(Icons.chevron_right,
                        color: AppTema.textoSecundario),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoValidade() {
    final texto = _validade == null
        ? 'Selecionar data'
        : LoteFormatadores.formatarData(_isoDe(_validade!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Validade'),
        const SizedBox(height: 6),
        InkWell(
          onTap: _selecionarValidade,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppTema.cartao,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTema.bordaCampo),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppTema.primariaEscura, size: 18),
                const SizedBox(width: 10),
                Text(
                  texto,
                  style: TextStyle(
                    color: _validade == null
                        ? const Color(0xFFB7A98A)
                        : AppTema.textoEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoCodigo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Código', opcional: true),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: _codigo,
          dica: 'Ex.: L0241',
          tamanhoMax: 60,
        ),
      ],
    );
  }

  Widget _campoQuantidade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Quantidade inicial'),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: _quantidade,
          dica: 'Ex.: 5,0',
          tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          formatadores: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
        ),
      ],
    );
  }

  Widget _campoUnidade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Unidade'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTema.cartao,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTema.bordaCampo),
          ),
          child: _carregandoUnidades
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTema.primaria),
                      ),
                      SizedBox(width: 12),
                      Text('Carregando unidades…',
                          style: TextStyle(color: AppTema.textoSecundario)),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<UnidadeMedidaMock>(
                    isExpanded: true,
                    value: _unidadeSelecionada,
                    hint: const Text('Selecione a unidade',
                        style: TextStyle(color: Color(0xFFB7A98A))),
                    items: _unidades
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              '${u.nome} (${u.simbolo})',
                              style:
                                  const TextStyle(color: AppTema.textoEscuro),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (u) =>
                        setState(() => _unidadeSelecionada = u),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _campoCusto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotulo('Custo unitário'),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: _custo,
          dica: 'Ex.: 7,40',
          tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          formatadores: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          prefixo: const Padding(
            padding: EdgeInsets.only(left: 14, right: 4),
            child: Align(
              widthFactor: 1,
              child: Text('R\$',
                  style: TextStyle(
                      color: AppTema.textoSecundario,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  /// Em edição, quantidade/unidade/custo não são editáveis (LoteUpdate só
  /// aceita código, validade e ativo). Mostramos os valores apenas para
  /// referência. O saldo restante nunca é editado diretamente.
  Widget _resumoSomenteLeitura() {
    final lote = widget.lote!;
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    final sufixoCusto = simbolo.isNotEmpty ? ' / $simbolo' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTema.fundoDica,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _linhaResumo('Quantidade inicial',
              '${LoteFormatadores.formatarQuantidade(lote.quantidadeInicial)} $simbolo'.trim()),
          const Divider(height: 1, color: AppTema.bordaCampo),
          _linhaResumo('Saldo restante',
              '${LoteFormatadores.formatarQuantidade(lote.quantidadeRestante)} $simbolo'.trim()),
          const Divider(height: 1, color: AppTema.bordaCampo),
          _linhaResumo('Custo unitário',
              '${LoteFormatadores.formatarMoeda(lote.custoUnitario)}$sufixoCusto'),
        ],
      ),
    );
  }

  Widget _linhaResumo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo,
              style: const TextStyle(
                  color: AppTema.textoSecundario,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          Text(valor,
              style: const TextStyle(
                  color: AppTema.primariaEscura,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _campoAtivo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTema.cartao,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppTema.primaria,
        title: const Text('Lote ativo',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppTema.textoEscuro)),
        subtitle: const Text('Lotes inativos não participam das saídas FEFO.',
            style: TextStyle(color: AppTema.textoSecundario, fontSize: 12)),
        value: _ativo,
        onChanged: (v) => setState(() => _ativo = v),
      ),
    );
  }

  Widget _mensagemErro() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E3DF),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
            left: BorderSide(color: Color(0xFFC0392B), width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _erro!,
              style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
