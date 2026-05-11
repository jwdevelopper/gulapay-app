import 'package:flutter/material.dart';
import 'package:my_app_teste/model/categoria_dto.dart';
import 'package:my_app_teste/pages/categorias/categoria_form_page.dart';
import 'package:my_app_teste/services/categoria_service.dart';

enum _FiltroStatus { todas, ativas, inativas }

class CategoriaListaPage extends StatefulWidget {
  const CategoriaListaPage({super.key});

  @override
  State<CategoriaListaPage> createState() => _CategoriaListaPageState();
}

class _CategoriaListaPageState extends State<CategoriaListaPage> {
  static const Color _corFundo = Color(0xFFFCF8F2);
  static const Color _corLaranja = Color(0xFFF25D27);
  static const Color _corTextoEscuro = Color(0xFF4A342E);
  static const Color _corTextoClaro = Color(0xFF8D7A74);

  final CategoriaService _categoriaService = CategoriaService();
  final TextEditingController _buscaController = TextEditingController();

  late Future<List<CategoriaDto>> _categoriasFuture;
  String _termoBusca = '';
  _FiltroStatus _filtro = _FiltroStatus.todas;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _carregarCategorias() {
    setState(() {
      _categoriasFuture = _categoriaService.listarCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFiltroChips(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _corLaranja,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: _navegarParaCadastro,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: FutureBuilder<List<CategoriaDto>>(
        future: _categoriasFuture,
        builder: (context, snapshot) {
          final total = _contagemValida(snapshot);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorias',
                style: TextStyle(
                  color: _corTextoEscuro,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                total != null
                    ? '$total ${total == 1 ? 'categoria' : 'categorias'}'
                    : 'Comece a cadastrar',
                style: TextStyle(color: _corTextoClaro, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }

  int? _contagemValida(AsyncSnapshot<List<CategoriaDto>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) return null;
    final lista = snapshot.data ?? [];
    if (lista.isEmpty || lista.first.nome == 'Erro') return null;
    return lista.length;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _buscaController,
          onChanged: (value) => setState(() => _termoBusca = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Buscar categoria...',
            hintStyle: TextStyle(color: _corTextoClaro),
            prefixIcon: Icon(Icons.search, color: _corTextoClaro),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          _buildChip('Todas', _FiltroStatus.todas, Icons.list_rounded),
          const SizedBox(width: 8),
          _buildChip('Ativas', _FiltroStatus.ativas, Icons.check_circle_outline),
          const SizedBox(width: 8),
          _buildChip('Inativas', _FiltroStatus.inativas, Icons.pause_circle_outline),
        ],
      ),
    );
  }

  Widget _buildChip(String label, _FiltroStatus status, IconData icone) {
    final selecionado = _filtro == status;
    return GestureDetector(
      onTap: () => setState(() => _filtro = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? _corLaranja : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 16,
              color: selecionado ? Colors.white : _corTextoClaro,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selecionado ? Colors.white : _corTextoEscuro,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<List<CategoriaDto>>(
      future: _categoriasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _corLaranja));
        }

        if (snapshot.hasError) {
          return _buildEstadoVazio(
            mensagem: 'Não foi possível carregar as categorias.',
            mostrarBotao: false,
          );
        }

        final categorias = snapshot.data ?? [];

        if (categorias.isNotEmpty && categorias.first.nome == 'Erro') {
          return _buildEstadoVazio(
            mensagem: categorias.first.message ?? 'Erro desconhecido.',
            mostrarBotao: false,
          );
        }

        final filtradas = _aplicarFiltros(categorias);

        if (filtradas.isEmpty) {
          return _buildEstadoVazio(
            mensagem: _mensagemEstadoVazio(categorias.isEmpty),
            mostrarBotao: categorias.isEmpty,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                '${filtradas.length} ${filtradas.length == 1 ? 'categoria' : 'categorias'}',
                style: TextStyle(color: _corTextoClaro, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildCategoriaCard(filtradas[index]),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  List<CategoriaDto> _aplicarFiltros(List<CategoriaDto> categorias) {
    Iterable<CategoriaDto> resultado = categorias;

    if (_filtro == _FiltroStatus.ativas) {
      resultado = resultado.where((c) => c.ativo ?? true);
    } else if (_filtro == _FiltroStatus.inativas) {
      resultado = resultado.where((c) => !(c.ativo ?? true));
    }

    if (_termoBusca.isNotEmpty) {
      resultado = resultado.where((c) => c.nome.toLowerCase().contains(_termoBusca));
    }

    return resultado.toList();
  }

  String _mensagemEstadoVazio(bool listaTotalVazia) {
    if (listaTotalVazia) {
      return 'Cadastre sua primeira categoria\npara organizar o cardápio.';
    }
    if (_termoBusca.isNotEmpty) {
      return 'Nenhuma categoria encontrada\npara "$_termoBusca".';
    }
    switch (_filtro) {
      case _FiltroStatus.ativas:
        return 'Nenhuma categoria ativa\nno momento.';
      case _FiltroStatus.inativas:
        return 'Nenhuma categoria inativa\nno momento.';
      case _FiltroStatus.todas:
        return 'Nenhuma categoria encontrada.';
    }
  }

  Widget _buildEstadoVazio({
    required String mensagem,
    required bool mostrarBotao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: _corTextoClaro.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem categorias por aqui',
                    style: TextStyle(
                      color: _corTextoEscuro,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensagem,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _corTextoClaro, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (mostrarBotao) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navegarParaCadastro,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Cadastrar categoria',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _corLaranja,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaCard(CategoriaDto categoria) {
    final bool ativo = categoria.ativo ?? true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _corFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: ativo ? _corLaranja : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria.nome,
                  style: TextStyle(
                    color: ativo ? _corTextoEscuro : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categoria.descricao ?? 'Sem descrição',
                  style: TextStyle(color: _corTextoClaro, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!ativo)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'INATIVA',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildMenuAcoes(categoria),
        ],
      ),
    );
  }

  Widget _buildMenuAcoes(CategoriaDto categoria) {
    final bool ativo = categoria.ativo ?? true;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: _corTextoClaro),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (acao) {
        switch (acao) {
          case 'editar':
            _navegarParaEdicao(categoria);
            break;
          case 'status':
            _alternarStatus(categoria);
            break;
          case 'excluir':
            _confirmarExclusao(categoria);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: _corTextoEscuro),
              const SizedBox(width: 10),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(
                ativo ? Icons.pause_circle_outline : Icons.play_circle_outline,
                size: 18,
                color: _corTextoEscuro,
              ),
              const SizedBox(width: 10),
              Text(ativo ? 'Desativar' : 'Ativar'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'excluir',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: Colors.red),
              SizedBox(width: 10),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navegarParaCadastro() async {
    final recarregar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CategoriaFormPage()),
    );
    if (recarregar == true) _carregarCategorias();
  }

  Future<void> _navegarParaEdicao(CategoriaDto categoria) async {
    final recarregar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriaFormPage(categoria: categoria),
      ),
    );
    if (recarregar == true) _carregarCategorias();
  }

  Future<void> _alternarStatus(CategoriaDto categoria) async {
    final bool ativandoAgora = !(categoria.ativo ?? true);
    final resultado = await _categoriaService.alternarStatus(categoria.id!);

    if (!mounted) return;

    if (resultado.nome == 'Erro') {
      _mostrarSnack(resultado.message ?? 'Não foi possível alterar o status.', erro: true);
      return;
    }

    _mostrarSnack(
      ativandoAgora
          ? 'Categoria "${categoria.nome}" ativada.'
          : 'Categoria "${categoria.nome}" desativada.',
    );
    _carregarCategorias();
  }

  Future<void> _confirmarExclusao(CategoriaDto categoria) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            const SizedBox(width: 10),
            const Text('Excluir categoria?'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir "${categoria.nome}"? '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: _corTextoEscuro)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    await _executarExclusao(categoria);
  }

  Future<void> _executarExclusao(CategoriaDto categoria) async {
    final resultado = await _categoriaService.excluirCategoria(categoria.id!);

    if (!mounted) return;

    if (resultado.nome == 'Erro') {
      _mostrarDialogErroExclusao(resultado.message ?? 'Não foi possível excluir.');
      return;
    }

    _mostrarSnack('Categoria "${categoria.nome}" excluída.');
    _carregarCategorias();
  }

  void _mostrarDialogErroExclusao(String mensagem) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red.shade400),
            const SizedBox(width: 10),
            const Expanded(child: Text('Exclusão bloqueada')),
          ],
        ),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _corLaranja),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _mostrarSnack(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }
}
