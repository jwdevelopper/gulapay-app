import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/produto/dto/filtro_produtos.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/dto/rotulos_produto.dart';
import 'package:my_app_teste/modules/produto/page/produto_form_page.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import 'package:my_app_teste/modules/produto/widgets/produtos_widgets.dart';

/// Vitrine de produtos, com busca, chips de categoria, filtro avançado e
/// ordenação.
///
/// Cuida apenas de estado, carga e navegação: o recorte e a ordenação vivem
/// em [FiltroProdutos], e as traduções, ícones e cores em [RotulosProduto].
///
/// Só a categoria é filtrada pelo backend (`GET /produtos?categoriaId=X`);
/// o resto é peneirado em memória.
class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final _service = ProdutoService();
  final _busca = TextEditingController();

  List<Produto> _produtos = [];
  List<Categoria> _categorias = [];
  FiltroProdutos _filtro = const FiltroProdutos();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregarCategorias() async {
    try {
      final lista = await CategoriaService().listar(apenasAtivos: true);
      if (mounted) setState(() => _categorias = lista);
    } catch (_) {
      // A vitrine continua utilizável sem os chips de categoria.
    }
  }

  Future<void> _carregar({bool mostrarCarregando = true}) async {
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await _service.listar(
        apenasAtivos: true,
        categoriaId: _filtro.categoriaId,
      );
      if (mounted) {
        setState(() {
          _produtos = lista
              .map((item) => Produto.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar os produtos.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recarregarTudo() async {
    await _carregarCategorias();
    await _carregar(mostrarCarregando: false);
  }

  /// Nome da categoria de um produto. A busca livre também procura por ele,
  /// e o `Produto` só guarda o id.
  String _nomeCategoria(int? categoriaId) => _categorias
      .firstWhere(
        (c) => c.id == categoriaId,
        orElse: () => Categoria(id: 0, nome: ''),
      )
      .nome;

  List<Produto> get _filtrados =>
      _filtro.aplicar(_produtos, nomeCategoria: _nomeCategoria);

  // ---------------------------------------------------------------------
  // Filtros
  // ---------------------------------------------------------------------

  /// Aplica um filtro novo. [recarregar] é necessário quando a categoria
  /// muda — ela é o único critério que o backend resolve.
  void _aplicarFiltro(FiltroProdutos novo, {bool recarregar = false}) {
    setState(() => _filtro = novo);
    if (recarregar) _carregar();
  }

  void _limparTudo() {
    _busca.clear();
    _aplicarFiltro(const FiltroProdutos(), recarregar: true);
  }

  void _selecionarCategoria(Categoria categoria) {
    final jaSelecionada = _filtro.categoriaId == categoria.id;
    _aplicarFiltro(
      jaSelecionada
          ? _filtro.copiarCom(limparCategoria: true)
          : _filtro.copiarCom(categoriaId: categoria.id),
      recarregar: true,
    );
  }

  Future<void> _abrirOrdenacao() async {
    final escolhida = await ProdutoSortSheet.mostrar(
      context,
      selecionada: _filtro.ordenacao,
    );
    if (escolhida != null && escolhida != _filtro.ordenacao) {
      _aplicarFiltro(_filtro.copiarCom(ordenacao: escolhida));
    }
  }

  Future<void> _abrirFiltroAvancado() async {
    final novo = await ProdutoFilterSheet.show(
      context,
      categorias: _categorias,
      filtroInicial: _filtro,
      nomeCategoria: _nomeCategoria,
    );
    if (novo == null) return;
    _aplicarFiltro(novo, recarregar: novo.categoriaId != _filtro.categoriaId);
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({Produto? produto}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProdutoFormPage(produto: produto)),
    );
    if (salvou == true) await _carregar();
  }

  /// Confirma e exclui. Devolve `true` quando o card pode sair da lista — o
  /// `Dismissible` usa esse retorno para concluir a animação.
  Future<bool> _confirmarEExcluir(Produto produto) async {
    final confirmou = await AppDialogoConfirmacao.exclusao(
      context,
      titulo: 'Excluir produto',
      mensagem: 'Deseja realmente excluir "${produto.nome}"?',
    );
    if (confirmou != true || produto.id == null) return false;

    try {
      await _service.excluirProduto(produto.id!);
      if (!mounted) return false;
      setState(() => _produtos.removeWhere((p) => p.id == produto.id));
      _avisar('Produto "${produto.nome}" excluído.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao excluir: ${e.message}');
      return false;
    } catch (e) {
      _avisar('Erro ao excluir: $e');
      return false;
    }
  }

  void _avisar(String mensagem, {bool sucesso = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? AppTema.sucesso : AppTema.erro,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    floatingActionButton: FloatingActionButton(
      onPressed: _abrirFormulario,
      backgroundColor: AppTema.primaria,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          AppCampoBusca(
            controle: _busca,
            dica: 'Buscar produto…',
            margemHorizontal: 16,
            aoMudar: (valor) => _aplicarFiltro(_filtro.copiarCom(busca: valor)),
          ),
          const SizedBox(height: 10),
          ProdutoCategoryChips(
            categorias: _categorias,
            selectedCategoriaId: _filtro.categoriaId,
            iconForCategoryName: RotulosProduto.iconeDaCategoria,
            onClearCategory: () => _aplicarFiltro(
              _filtro.copiarCom(limparCategoria: true),
              recarregar: true,
            ),
            onSelectCategory: _selecionarCategoria,
          ),
          ProdutoResultsHeader(
            resultCount: _filtrados.length,
            sortLabel: _filtro.ordenacao.rotulo,
            onSortTap: _abrirOrdenacao,
            onFilterTap: _abrirFiltroAvancado,
            onClearFiltersTap: _limparTudo,
            hasActiveFilter: _filtro.temFiltroAvancado,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTema.primaria,
              onRefresh: _recarregarTudo,
              child: _lista(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _lista() {
    if (_carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 96),
        children: const [SizedBox(height: 120), AppCarregando()],
      );
    }
    if (_erro != null) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.cloud_off_rounded,
          titulo: 'Não foi possível carregar',
          mensagem: _erro!,
          rotuloBotao: 'Tentar novamente',
          iconeBotao: Icons.refresh_rounded,
          aoTocarBotao: _carregar,
        ),
      );
    }
    if (_produtos.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.dinner_dining_rounded,
          titulo: 'Sem produtos por aqui',
          mensagem:
              'Cadastre seu primeiro produto para começar a montar o '
              'cardápio.',
          rotuloBotao: 'Cadastrar produto',
          aoTocarBotao: _abrirFormulario,
        ),
      );
    }

    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Nenhum produto encontrado',
          mensagem:
              'Tente um termo diferente ou limpe os filtros para ver todos '
              'os itens.',
          rotuloBotao: 'Limpar filtros',
          iconeBotao: Icons.filter_alt_off_rounded,
          secundario: true,
          aoTocarBotao: _limparTudo,
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _cartao(filtrados[i]),
    );
  }

  Widget _cartao(Produto produto) {
    final nomeCategoria = _nomeCategoria(produto.categoriaId);
    final descricao = (produto.descricao ?? '').trim();
    return ProdutoCard(
      produto: produto,
      subtitle: [
        if (nomeCategoria.isNotEmpty) nomeCategoria,
        if (descricao.isNotEmpty) descricao,
      ].join(' • '),
      categoriaNome: nomeCategoria,
      icon: RotulosProduto.iconeDoProduto(produto, nomeCategoria),
      accentColor: RotulosProduto.corDestaque(produto, nomeCategoria),
      sectorLabel: RotulosProduto.setor(produto.setorProducao).toUpperCase(),
      sectorColor: RotulosProduto.corSetor(produto.setorProducao),
      priceText: RotulosProduto.preco(produto.preco),
      onTap: () => _abrirFormulario(produto: produto),
      onEdit: () => _abrirFormulario(produto: produto),
      onConfirmDelete: () => _confirmarEExcluir(produto),
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 38, 16, 96),
    children: [filho],
  );
}
