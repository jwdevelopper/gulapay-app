import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_interruptor.dart';
import 'package:my_app_teste/core/widgets/app_campo_seletor.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_data.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/validacao_lote.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/widgets/form/campos_lote.dart';
import 'package:my_app_teste/modules/unidade_medida/widgets/campo_unidade.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_insumo_seletor.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/unidade_medida/service/unidade_medida_service.dart';

/// Cadastro e edição de lote.
///
/// Cuida de estado, carga das unidades e envio. As regras de preenchimento
/// vivem em [ValidadorLote] e o que a tela mostra em
/// `widgets/form/campos_lote.dart`.
///
/// Os dois modos diferem bastante: criar pede insumo, quantidade, unidade e
/// custo; editar só permite código, validade e `ativo`, porque é só isso
/// que o `PUT /lotes/{id}` aceita.
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
  final _service = LoteService();
  final _codigo = TextEditingController();
  final _quantidade = TextEditingController();
  final _custo = TextEditingController();

  DadosLote _dados = const DadosLote();
  List<UnidadeMedidaResponse> _unidades = [];
  bool _carregandoUnidades = false;
  bool _salvando = false;
  String? _erro;

  /// Falha ao buscar as unidades. Fica separada de [_erro] porque tem uma
  /// saída própria — o botão de recarregar dentro do campo.
  String? _erroUnidades;

  @override
  void initState() {
    super.initState();
    final lote = widget.lote;
    if (lote != null) {
      _codigo.text = lote.codigo ?? '';
      _dados = DadosLote(
        ehEdicao: true,
        validade: DateTime.tryParse(lote.validade ?? ''),
        ativo: lote.ativo ?? true,
      );
    } else {
      _dados = DadosLote(insumo: widget.insumoInicial);
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

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregarUnidades() async {
    setState(() {
      _carregandoUnidades = true;
      _erroUnidades = null;
    });
    try {
      final lista = await listarUnidadesMedida();
      if (!mounted) return;
      setState(() {
        _unidades = lista.where((u) => u.ativo != false).toList();
        _dados = _dados.copiarCom(unidadeId: _unidadePadraoDoInsumo());
      });
    } catch (_) {
      if (mounted) {
        setState(() => _erroUnidades = 'Falha ao carregar as unidades.');
      }
    } finally {
      if (mounted) setState(() => _carregandoUnidades = false);
    }
  }

  /// A unidade padrão do insumo escolhido, quando ela existe na lista.
  /// Poupa um toque no caso comum — o lote costuma entrar na mesma unidade
  /// em que o insumo é estocado.
  int? _unidadePadraoDoInsumo() {
    final id = _dados.insumo?.unidadePadraoId;
    if (id == null) return _dados.unidadeId;
    return _unidades.any((u) => u.id == id) ? id : _dados.unidadeId;
  }

  void _atualizar(DadosLote novo) {
    setState(() {
      _dados = novo;
      _erro = null;
    });
  }

  Future<void> _selecionarInsumo() async {
    final insumo = await LoteInsumoSeletor.abrir(context);
    if (insumo == null || !mounted) return;
    setState(() {
      _dados = _dados.copiarCom(insumo: insumo);
      _dados = _dados.copiarCom(unidadeId: _unidadePadraoDoInsumo());
      _erro = null;
    });
  }

  Future<void> _selecionarValidade() async {
    final data = await abrirSeletorData(
      context,
      dataInicial: _dados.validade,
      textoAjuda: 'Selecione a validade',
    );
    if (data != null && mounted) _atualizar(_dados.copiarCom(validade: data));
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  /// Junta o que está nos controllers ao que está em [_dados] — os campos
  /// de texto não disparam `setState` a cada tecla.
  DadosLote get _dadosCompletos => _dados.copiarCom(
    codigo: _codigo.text,
    quantidade: _quantidade.text,
    custo: _custo.text,
  );

  Future<void> _salvar() async {
    final dados = _dadosCompletos;
    final erroValidacao = ValidadorLote.validar(dados);
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
        await _service.atualizar(widget.lote!.id!, dados.paraEdicao());
      } else {
        await _service.criar(dados.paraCriacao());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.ehEdicao ? 'Lote atualizado.' : 'Lote criado.'),
          backgroundColor: AppTema.sucesso,
        ),
      );
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    appBar: AppBar(
      backgroundColor: AppTema.fundo,
      foregroundColor: AppTema.texto,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTema.primariaEscura),
      title: Text(
        widget.ehEdicao ? 'Editar lote' : 'Novo lote',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTema.texto,
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const AppDica(
          'Para registrar uma compra real, prefira Movimentação de Estoque. '
          'Este cadastro é indicado para inventário inicial ou correção '
          'administrativa.',
        ),
        const SizedBox(height: 16),
        _campoInsumo(),
        const SizedBox(height: 16),
        _campoValidade(),
        const SizedBox(height: 16),
        _campoCodigo(),
        const SizedBox(height: 16),
        if (widget.ehEdicao) ...[
          ResumoLoteImutavel(lote: widget.lote!),
          const SizedBox(height: 16),
          AppCampoInterruptor(
            titulo: 'Lote ativo',
            descricao: 'Lotes inativos não participam das saídas FEFO.',
            valor: _dados.ativo,
            aoMudar: (v) => _atualizar(_dados.copiarCom(ativo: v)),
          ),
        ] else ...[
          _campoQuantidade(),
          const SizedBox(height: 16),
          CampoUnidadeMedida(
            unidades: _unidades,
            selecionadaId: _dados.unidadeId,
            carregando: _carregandoUnidades,
            erro: _erroUnidades,
            aoRecarregar: _carregarUnidades,
            aoSelecionar: (id) => _atualizar(_dados.copiarCom(unidadeId: id)),
            rotulo: 'Unidade',
          ),
          const SizedBox(height: 16),
          _campoCusto(),
        ],
        if (_erro != null) ...[
          const SizedBox(height: 16),
          AppCartaoAviso.erro(_erro),
        ],
      ],
    ),
    bottomNavigationBar: AppBarraAcoes(
      textoConfirmar: widget.ehEdicao ? 'Salvar' : 'Criar lote',
      carregando: _salvando,
      aoCancelar: () => Navigator.pop(context, false),
      aoConfirmar: _salvar,
    ),
  );

  /// Em edição o insumo é fixo — o vínculo lote↔insumo não muda.
  Widget _campoInsumo() => AppCampoSeletor(
    rotulo: 'Insumo',
    obrigatorio: !widget.ehEdicao,
    valor: widget.ehEdicao
        ? (widget.lote?.insumoNome ?? '—')
        : (_dados.insumo?.nome ?? ''),
    detalhe: _unidadeBaseDoInsumo,
    dica: 'Selecionar insumo',
    icone: Icons.inventory_2_outlined,
    aoTocar: widget.ehEdicao ? null : _selecionarInsumo,
  );

  String? get _unidadeBaseDoInsumo {
    final simbolo = widget.ehEdicao
        ? widget.lote?.unidadePadraoSimbolo
        : (_dados.insumo?.unidadePadraoSimbolo ?? _dados.insumo?.unidadePadrao);
    return (simbolo ?? '').isEmpty ? null : 'Unidade base: $simbolo';
  }

  Widget _campoValidade() => AppCampoSeletor(
    rotulo: 'Validade',
    obrigatorio: true,
    valor: _dados.validade == null ? '' : formatarDataBr(_dados.validade!),
    dica: 'Selecionar data',
    icone: Icons.calendar_today_outlined,
    aoTocar: _selecionarValidade,
  );

  Widget _campoCodigo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppRotulo('Código', opcional: true),
      const SizedBox(height: 6),
      AppCampoTexto(controle: _codigo, dica: 'Ex.: L0241', tamanhoMax: 60),
    ],
  );

  Widget _campoQuantidade() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppRotulo('Quantidade inicial'),
      const SizedBox(height: 6),
      AppCampoTexto(
        controle: _quantidade,
        dica: 'Ex.: 5,0',
        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
        formatadores: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      ),
    ],
  );

  Widget _campoCusto() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppRotulo('Custo unitário'),
      const SizedBox(height: 6),
      AppCampoTexto(
        controle: _custo,
        dica: 'Ex.: 7,40',
        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
        formatadores: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        prefixo: const Padding(
          padding: EdgeInsets.only(left: 14, right: 4),
          child: Align(
            widthFactor: 1,
            child: Text(
              r'R$',
              style: TextStyle(
                color: AppTema.textoSecundario,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
