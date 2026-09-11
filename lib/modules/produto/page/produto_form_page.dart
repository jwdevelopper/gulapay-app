import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_cabecalho_wizard.dart';
import 'package:my_app_teste/core/widgets/app_rodape_wizard.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:my_app_teste/modules/produto/widgets/form/etapa_identidade.dart';
import 'package:my_app_teste/modules/produto/widgets/form/etapa_preco.dart';
import 'package:my_app_teste/modules/produto/widgets/form/etapa_producao.dart';
import 'package:my_app_teste/modules/produto/widgets/form/seletor_categoria.dart';

/// Cadastro e edição de produto, em 3 etapas.
///
/// Esta classe cuida apenas de estado, navegação entre etapas e envio. A
/// aparência de cada etapa vive em `widgets/form/` e as regras de campo
/// obrigatório em [ValidadorProduto].
class ProdutoFormPage extends StatefulWidget {
  /// Produto em edição. Quando `null`, o formulário é de criação.
  final Produto? produto;

  const ProdutoFormPage({super.key, this.produto});

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  static const _totalEtapas = 3;

  final _service = ProdutoService();
  final _categoriaService = CategoriaService();

  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();

  List<Categoria> _categorias = [];
  int? _categoriaId;
  String? _tipo;
  String? _setor;
  bool _ativo = true;

  int _etapa = 0;
  bool _salvando = false;
  ResultadoValidacaoProduto _validacao = const ResultadoValidacaoProduto.ok();

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    if (produto != null) {
      _nome.text = produto.nome;
      _descricao.text = produto.descricao ?? '';
      _preco.text = _precoParaTexto(produto.preco);
      _tipo = produto.tipoProduto;
      _setor = produto.setorProducao;
      _categoriaId = produto.categoriaId;
      _ativo = produto.ativo ?? true;
    }
    _carregarCategorias();
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _preco.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  bool get _ehEdicao => widget.produto?.id != null;

  DadosProduto get _dados => DadosProduto(
    nome: _nome.text,
    descricao: _descricao.text,
    preco: _preco.text,
    categoriaId: _categoriaId,
    tipo: _tipo,
    setor: _setor,
    ativo: _ativo,
  );

  Categoria? get _categoria {
    if (_categoriaId == null) return null;
    for (final categoria in _categorias) {
      if (categoria.id == _categoriaId) return categoria;
    }
    return null;
  }

  static String _precoParaTexto(double? preco) =>
      preco == null ? '' : preco.toStringAsFixed(2).replaceAll('.', ',');

  Future<void> _carregarCategorias() async {
    try {
      final lista = await _categoriaService.listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() => _categorias = lista);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categorias: $e')),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Validação e navegação
  // ---------------------------------------------------------------------

  /// Limpa a marcação de um campo assim que o usuário o corrige.
  void _limparErro(CampoProduto campo) {
    if (!_validacao.erroEm(campo)) return;
    setState(() => _validacao = _validacao.sem(campo));
  }

  Future<void> _avancar() async {
    final resultado = ValidadorProduto.validarEtapa(_etapa, _dados);
    setState(() => _validacao = resultado);
    if (!resultado.valido) return;

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
      _validacao = const ResultadoValidacaoProduto.ok();
    });
  }

  Future<void> _enviar() async {
    setState(() => _salvando = true);
    try {
      final payload = _dados.paraPayload(paraEdicao: _ehEdicao);
      if (_ehEdicao) {
        await _service.editarProduto(widget.produto!.id!, payload);
      } else {
        await _service.criarProduto(payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_ehEdicao ? 'Produto atualizado' : 'Produto criado'),
        ),
      );
      Navigator.pop(context, true);
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

  void _abrirSelecaoCategoria() {
    abrirSelecaoCategoria(
      context,
      categorias: _categorias,
      categoriaSelecionadaId: _categoriaId,
      aoSelecionar: (categoria) {
        setState(() => _categoriaId = categoria.id);
        _limparErro(CampoProduto.categoria);
      },
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  String get _rotuloEtapa {
    switch (_etapa) {
      case 0:
        return 'Identidade';
      case 1:
        return 'Preço & categoria';
      default:
        return 'Produção';
    }
  }

  Widget _corpoDaEtapa() {
    switch (_etapa) {
      case 0:
        return EtapaIdentidade(
          controladorNome: _nome,
          controladorDescricao: _descricao,
          validacao: _validacao,
          // O contador de caracteres depende do texto, então redesenha a
          // cada tecla — daí o setState mesmo sem erro a limpar.
          aoAlterarNome: (_) {
            setState(() {});
            _limparErro(CampoProduto.nome);
          },
          aoAlterarDescricao: (_) => setState(() {}),
        );
      case 1:
        return EtapaPreco(
          controladorPreco: _preco,
          categoria: _categoria,
          validacao: _validacao,
          aoAlterarPreco: (_) => _limparErro(CampoProduto.preco),
          aoAbrirCategoria: _abrirSelecaoCategoria,
        );
      default:
        return EtapaProducao(
          dados: _dados,
          nomeCategoria: _categoria?.nome ?? '-',
          validacao: _validacao,
          aoSelecionarTipo: (valor) {
            setState(() => _tipo = valor);
            _limparErro(CampoProduto.tipo);
          },
          aoSelecionarSetor: (valor) {
            setState(() => _setor = valor);
            _limparErro(CampoProduto.setor);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimaEtapa = _etapa == _totalEtapas - 1;
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Column(
          children: [
            AppCabecalhoWizard(
              titulo: _ehEdicao ? 'Editar produto' : 'Novo produto',
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
                  ? (_ehEdicao ? 'Salvar alterações' : 'Cadastrar produto')
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
