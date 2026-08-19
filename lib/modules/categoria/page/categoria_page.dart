import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_form_page.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_card.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_dialogo_status.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_filtros.dart';

class CategoriaPage extends StatefulWidget {
  const CategoriaPage({super.key});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  final _servico = CategoriaService();
  final _controleBusca = TextEditingController();

  List<Categoria> _todas = [];
  bool _carregando = true;
  String _filtroStatus = 'TODAS';
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _controleBusca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final categorias = await _servico.listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() => _todas = categorias);
    } on ApiError catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao listar: ${erro.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Categoria> get _filtradas {
    final termo = _busca.trim().toLowerCase();
    return _todas.where((categoria) {
      final ativa = categoria.ativo ?? true;
      final correspondeAoStatus =
          _filtroStatus == 'TODAS' ||
          (_filtroStatus == 'ATIVAS' && ativa) ||
          (_filtroStatus == 'INATIVAS' && !ativa);
      final correspondeABusca =
          termo.isEmpty ||
          categoria.nome.toLowerCase().contains(termo) ||
          (categoria.descricao ?? '').toLowerCase().contains(termo);
      return correspondeAoStatus && correspondeABusca;
    }).toList();
  }

  Future<bool> _confirmarEAlternarStatus(Categoria categoria) async {
    final inativar = categoria.ativo ?? true;
    final confirmou = await confirmarMudancaStatusCategoria(
      context,
      categoria,
      inativar: inativar,
    );
    if (!confirmou) return false;

    return _alternarStatus(categoria, inativar);
  }

  Future<bool> _alternarStatus(Categoria categoria, bool inativar) async {
    if (categoria.id == null) return false;

    try {
      if (inativar) {
        await _servico.inativar(categoria.id!);
      } else {
        await _servico.ativar(categoria);
      }
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            inativar
                ? 'Categoria "${categoria.nome}" inativada.'
                : 'Categoria "${categoria.nome}" reativada.',
          ),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } on ApiError catch (erro) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${erro.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> _abrirFormulario({Categoria? categoria}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriaFormPage(categoria: categoria),
      ),
    );
    if (salvou != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          categoria == null
              ? 'Categoria cadastrada com sucesso!'
              : 'Categoria atualizada com sucesso!',
        ),
        backgroundColor: const Color(0xFF2E8B57),
      ),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CategoriaFiltros(
              controleBusca: _controleBusca,
              filtroStatus: _filtroStatus,
              aoMudarBusca: (busca) => setState(() => _busca = busca),
              aoMudarStatus: (status) => setState(() => _filtroStatus = status),
            ),
            Expanded(child: _construirConteudo()),
          ],
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppTema.primaria),
      );
    }

    if (_filtradas.isEmpty) {
      return AppEstadoVazio(
        icone: Icons.category_outlined,
        mensagem: _busca.isEmpty && _filtroStatus == 'TODAS'
            ? 'Nenhuma categoria cadastrada'
            : 'Nenhum resultado para a busca',
      );
    }

    return RefreshIndicator(
      color: AppTema.primaria,
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _filtradas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final categoria = _filtradas[index];
          return CategoriaCard(
            categoria: categoria,
            aoAbrir: () => _abrirFormulario(categoria: categoria),
            aoAlternarStatus: () => _confirmarEAlternarStatus(categoria),
            aoStatusAlterado: () => _carregar(),
          );
        },
      ),
    );
  }
}
