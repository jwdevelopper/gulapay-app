import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/tipo_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';
import 'package:my_app_teste/core/widgets/app_cabecalho_wizard.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/etapa_insumo_quantidade.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/etapa_lote_detalhes.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/etapa_tipo.dart';
import 'package:my_app_teste/core/widgets/app_rodape_wizard.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/seletor_insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/seletor_unidade.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/tela_sucesso.dart';

/// Formulário de nova movimentação de estoque, em 3 etapas.
///
/// Esta classe cuida apenas de estado, navegação entre etapas e envio. A
/// aparência de cada etapa vive em `widgets/form/` e as regras de campo
/// obrigatório em [ValidadorMovimentacao].
class MovimentacaoFormPage extends StatefulWidget {
  const MovimentacaoFormPage({super.key});

  @override
  State<MovimentacaoFormPage> createState() => _MovimentacaoFormPageState();
}

class _MovimentacaoFormPageState extends State<MovimentacaoFormPage> {
  static const _totalEtapas = 3;

  final _service = MovimentacaoEstoqueService();

  final _quantidade = TextEditingController();
  final _custoUnitario = TextEditingController();
  final _codigoLote = TextEditingController();
  final _justificativa = TextEditingController();

  List<Insumo> _insumos = [];
  List<Lote> _lotes = [];
  List<UnidadeMedida> _unidades = [];

  String? _tipo;
  Insumo? _insumo;
  Lote? _lote;
  UnidadeMedida? _unidade;
  DateTime? _validade;

  int _etapa = 0;
  bool _salvando = false;
  bool _sucesso = false;
  ResultadoValidacao _validacao = const ResultadoValidacao.ok();

  @override
  void initState() {
    super.initState();
    _carregarInsumos();
    _carregarUnidades();
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _custoUnitario.dispose();
    _codigoLote.dispose();
    _justificativa.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  DadosMovimentacao get _dados => DadosMovimentacao(
    tipo: _tipo,
    insumo: _insumo,
    unidade: _unidade,
    lote: _lote,
    quantidade: _quantidade.text,
    validade: _validade,
    custoUnitario: _custoUnitario.text,
    codigoLote: _codigoLote.text,
    justificativa: _justificativa.text,
    possuiLotes: _lotes.isNotEmpty,
  );

  Future<void> _carregarInsumos() async {
    try {
      final lista = await _service.listarInsumos(apenasAtivos: false);
      if (!mounted) return;
      setState(
        () => _insumos = lista
            .map((e) => Insumo.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e) {
      _avisarFalhaDeCarga('insumos', e);
    }
  }

  Future<void> _carregarUnidades() async {
    try {
      final lista = await _service.listarUnidades();
      if (!mounted) return;
      setState(
        () => _unidades = lista
            .map(
              (e) =>
                  UnidadeMedida.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList(),
      );
    } catch (e) {
      _avisarFalhaDeCarga('unidades de medida', e);
    }
  }

  Future<void> _carregarLotes(int insumoId) async {
    try {
      final lista = await _service.listarLotes(insumoId);
      if (!mounted) return;
      setState(
        () => _lotes = lista
            .map((e) => Lote.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e) {
      _avisarFalhaDeCarga('lotes', e);
    }
  }

  /// Antes as três cargas usavam `catch (_) {}` — a lista ficava vazia sem
  /// explicação quando a API falhava.
  void _avisarFalhaDeCarga(String recurso, Object erro) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Não foi possível carregar $recurso: $erro')),
    );
  }

  /// Unidades com o mesmo tipo de medida do insumo escolhido.
  List<UnidadeMedida> get _unidadesCompativeis {
    final padraoId = _insumo?.unidadePadraoId;
    if (padraoId == null) return _unidades;
    String? tipoMedida;
    for (final u in _unidades) {
      if (u.id == padraoId) {
        tipoMedida = u.tipoMedida;
        break;
      }
    }
    if (tipoMedida == null) return _unidades;
    return _unidades.where((u) => u.tipoMedida == tipoMedida).toList();
  }

  // ---------------------------------------------------------------------
  // Validação e navegação
  // ---------------------------------------------------------------------

  /// Limpa a marcação de um campo assim que o usuário o corrige.
  void _limparErro(CampoMovimentacao campo) {
    if (!_validacao.erroEm(campo)) return;
    setState(() => _validacao = _validacao.sem(campo));
  }

  Future<void> _avancar() async {
    final resultado = ValidadorMovimentacao.validarEtapa(_etapa, _dados);
    setState(() => _validacao = resultado);
    if (!resultado.valido) return;

    if (_etapa == 1 && _insumo?.id != null) {
      await _carregarLotes(_insumo!.id!);
    }
    if (_etapa < _totalEtapas - 1) {
      setState(() => _etapa++);
      return;
    }
    await _enviar();
  }

  void _voltar() {
    if (_etapa == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _etapa--;
      _validacao = const ResultadoValidacao.ok();
    });
  }

  Future<void> _enviar() async {
    setState(() => _salvando = true);
    try {
      await _service.criarMovimentacao(_dados.paraPayload());
      if (!mounted) return;
      setState(() => _sucesso = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // ---------------------------------------------------------------------
  // Seleções
  // ---------------------------------------------------------------------

  void _abrirSelecaoInsumo() {
    abrirSelecaoInsumo(
      context,
      insumos: _insumos,
      selecionado: _insumo,
      aoSelecionar: (insumo) {
        setState(() {
          _insumo = insumo;
          _lote = null;
          // Pré-seleciona a unidade padrão do insumo.
          for (final u in _unidades) {
            if (u.id == insumo.unidadePadraoId) {
              _unidade = u;
              break;
            }
          }
        });
        _limparErro(CampoMovimentacao.insumo);
      },
    );
  }

  void _abrirSelecaoUnidade() {
    if (_insumo == null) {
      setState(
        () => _validacao = const ResultadoValidacao(
          camposComErro: {CampoMovimentacao.insumo},
          mensagem: 'Selecione o insumo antes da unidade.',
        ),
      );
      return;
    }
    abrirSelecaoUnidade(
      context,
      unidades: _unidadesCompativeis,
      selecionada: _unidade,
      nomeInsumo: _insumo!.nome,
      simboloInsumo: _insumo!.unidadePadraoSimbolo ?? '-',
      aoSelecionar: (unidade) {
        setState(() => _unidade = unidade);
        _limparErro(CampoMovimentacao.unidade);
      },
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  String get _rotuloEtapa {
    switch (_etapa) {
      case 0:
        return 'Tipo';
      case 1:
        return 'Insumo & quantidade';
      default:
        return 'Lote & detalhes';
    }
  }

  String get _titulo =>
      _etapa == 0 ? 'Nova movimentação' : rotuloTipoMovimentacao(_tipo);

  Widget _corpoDaEtapa() {
    switch (_etapa) {
      case 0:
        return EtapaTipo(
          tipoSelecionado: _tipo,
          validacao: _validacao,
          aoSelecionar: (valor) {
            setState(() {
              _tipo = valor;
              _lote = null;
            });
            _limparErro(CampoMovimentacao.tipo);
          },
        );
      case 1:
        return EtapaInsumoQuantidade(
          insumo: _insumo,
          unidade: _unidade,
          controladorQuantidade: _quantidade,
          validacao: _validacao,
          aoAbrirInsumo: _abrirSelecaoInsumo,
          aoAbrirUnidade: _abrirSelecaoUnidade,
          aoAlterarQuantidade: (_) => _limparErro(CampoMovimentacao.quantidade),
        );
      default:
        return EtapaLoteDetalhes(
          dados: _dados,
          lotes: _lotes,
          validacao: _validacao,
          controladorCusto: _custoUnitario,
          controladorCodigoLote: _codigoLote,
          controladorJustificativa: _justificativa,
          aoSelecionarValidade: (data) {
            setState(() => _validade = data);
            _limparErro(CampoMovimentacao.validade);
          },
          aoSelecionarLote: (lote) {
            setState(() => _lote = lote);
            _limparErro(CampoMovimentacao.lote);
          },
          aoEditarCampo: _limparErro,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sucesso) {
      return TelaSucessoMovimentacao(
        dados: _dados,
        aoConcluir: () => Navigator.pop(context, true),
      );
    }

    final ultimaEtapa = _etapa == _totalEtapas - 1;
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Column(
          children: [
            AppCabecalhoWizard(
              titulo: _titulo,
              etapa: _etapa,
              totalEtapas: _totalEtapas,
              rotuloEtapa: _rotuloEtapa,
              aoVoltar: _voltar,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _corpoDaEtapa(),
              ),
            ),
            AppRodapeWizard(
              rotuloEsquerda: _etapa == 0 ? 'Cancelar' : 'Voltar',
              rotuloDireita: ultimaEtapa
                  ? (_dados.ehEntrada ? 'Registrar entrada' : 'Registrar saída')
                  : 'Continuar',
              iconeDireita: ultimaEtapa
                  ? Icons.check_rounded
                  : Icons.chevron_right_rounded,
              carregando: _salvando,
              aoVoltar: _voltar,
              aoAvancar: _avancar,
            ),
          ],
        ),
      ),
    );
  }
}
