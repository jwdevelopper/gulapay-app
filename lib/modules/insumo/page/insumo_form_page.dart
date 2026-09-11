import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_interruptor.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/dto/validacao_insumo.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';
import 'package:my_app_teste/modules/unidade_medida/service/unidade_medida_service.dart';
import 'package:my_app_teste/modules/unidade_medida/widgets/campo_unidade.dart';

/// Cadastro e edição de insumo.
///
/// Cuida de estado, carga das unidades e envio; as regras de preenchimento
/// vivem em [ValidadorInsumo].
///
/// A unidade padrão é a decisão mais pesada da tela: ela define em que
/// unidade o saldo é guardado e serve de base para converter toda entrada e
/// saída (seção 4.5.1). Por isso o campo tem estado próprio de carga e de
/// erro, em vez de um dropdown que apareceria vazio.
class InsumoFormPage extends StatefulWidget {
  /// Quando nulo, é cadastro. Quando preenchido, é edição.
  final InsumoResponse? insumo;

  const InsumoFormPage({super.key, this.insumo});

  bool get ehEdicao => insumo != null;

  @override
  State<InsumoFormPage> createState() => _InsumoFormPageState();
}

class _InsumoFormPageState extends State<InsumoFormPage> {
  final _service = InsumoService();
  final _nome = TextEditingController();
  final _estoqueMinimo = TextEditingController();

  DadosInsumo _dados = const DadosInsumo();
  List<UnidadeMedidaResponse> _unidades = [];
  bool _carregandoUnidades = true;
  String? _erroUnidades;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final insumo = widget.insumo;
    _nome.text = insumo?.nome ?? '';
    _estoqueMinimo.text = insumo?.estoqueMinimo == null
        ? ''
        : formatarNumeroBr(insumo!.estoqueMinimo, casas: null);
    _dados = DadosInsumo(
      unidadePadraoId: insumo?.unidadePadraoId,
      ativo: insumo?.ativo ?? true,
    );
    _carregarUnidades();
  }

  @override
  void dispose() {
    _nome.dispose();
    _estoqueMinimo.dispose();
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
      setState(() => _unidades = lista.where((u) => u.ativo != false).toList());
    } catch (_) {
      if (mounted) {
        setState(() => _erroUnidades = 'Falha ao carregar as unidades.');
      }
    } finally {
      if (mounted) setState(() => _carregandoUnidades = false);
    }
  }

  /// Junta o que está nos controllers ao que está em [_dados].
  DadosInsumo get _dadosCompletos =>
      _dados.copiarCom(nome: _nome.text, estoqueMinimo: _estoqueMinimo.text);

  Future<void> _salvar() async {
    if (_carregandoUnidades || _erroUnidades != null) {
      setState(() => _erro = 'Aguarde as unidades carregarem para salvar.');
      return;
    }

    final dados = _dadosCompletos;
    final erroValidacao = ValidadorInsumo.validar(dados);
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
        await _service.atualizar(widget.insumo!.id!, dados.paraEdicao());
      } else {
        await _service.criar(dados.paraCriacao());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.ehEdicao ? 'Insumo atualizado.' : 'Insumo cadastrado.',
          ),
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
        widget.ehEdicao ? 'Editar insumo' : 'Novo insumo',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTema.texto,
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _campoNome(),
          const SizedBox(height: 16),
          CampoUnidadeMedida(
            unidades: _unidades,
            selecionadaId: _dados.unidadePadraoId,
            carregando: _carregandoUnidades,
            erro: _erroUnidades,
            aoRecarregar: _carregarUnidades,
            aoSelecionar: (id) => setState(() {
              _dados = _dados.copiarCom(unidadePadraoId: id);
              _erro = null;
            }),
          ),
          const SizedBox(height: 16),
          _campoEstoqueMinimo(),
          if (widget.ehEdicao) ...[
            const SizedBox(height: 16),
            AppCampoInterruptor(
              titulo: 'Insumo ativo',
              descricao:
                  'Insumos inativos não aparecem nas listagens nem podem '
                  'receber movimentação.',
              valor: _dados.ativo,
              aoMudar: (v) =>
                  setState(() => _dados = _dados.copiarCom(ativo: v)),
            ),
          ],
          if (_erro != null) ...[
            const SizedBox(height: 16),
            AppCartaoAviso.erro(_erro),
          ],
        ],
      ),
    ),
    bottomNavigationBar: AppBarraAcoes(
      textoConfirmar: widget.ehEdicao ? 'Salvar' : 'Cadastrar insumo',
      carregando: _salvando,
      aoCancelar: () => Navigator.pop(context, false),
      aoConfirmar: _salvar,
    ),
  );

  Widget _campoNome() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppRotulo('Nome'),
      const SizedBox(height: 6),
      AppCampoTexto(
        controle: _nome,
        dica: 'Ex.: Tomate italiano',
        tamanhoMax: ValidadorInsumo.nomeTamanhoMaximo,
      ),
    ],
  );

  Widget _campoEstoqueMinimo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppRotulo('Estoque mínimo'),
      const SizedBox(height: 6),
      AppCampoTexto(
        controle: _estoqueMinimo,
        dica: 'Ex.: 0,5',
        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
        formatadores: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      ),
      const SizedBox(height: 6),
      const Text(
        'Quantidade na unidade selecionada. Abaixo dela o insumo entra no '
        'alerta de estoque baixo.',
        style: TextStyle(color: AppTema.textoSecundario, fontSize: 12),
      ),
    ],
  );
}
