import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_form_page.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';

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

  static const _statusOpcoes = <String>['TODAS', 'ATIVAS', 'INATIVAS'];

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
      final lista = await _servico.listar(apenasAtivos: false);
      if (!mounted) return;
      setState(() => _todas = lista);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao listar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Categoria> get _filtradas {
    final termo = _busca.trim().toLowerCase();
    return _todas.where((c) {
      final ativa = c.ativo ?? true;
      final casaStatus =
          _filtroStatus == 'TODAS' ||
          (_filtroStatus == 'ATIVAS' && ativa) ||
          (_filtroStatus == 'INATIVAS' && !ativa);
      final casaBusca =
          termo.isEmpty ||
          c.nome.toLowerCase().contains(termo) ||
          (c.descricao ?? '').toLowerCase().contains(termo);
      return casaStatus && casaBusca;
    }).toList();
  }

  Future<bool> _confirmarMudancaStatus(Categoria c, bool inativar) async {
    final acao = inativar ? 'Inativar' : 'Reativar';
    final cor = inativar ? Colors.red.shade600 : const Color(0xFF2E8B57);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: AppTema.primaria,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              '$acao categoria',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
          ],
        ),
        content: Text(
          inativar
              ? 'Deseja inativar "${c.nome}"? A categoria poderá ser reativada depois pelo filtro "INATIVAS".'
              : 'Deseja reativar "${c.nome}"?',
          style: const TextStyle(color: AppTema.textoEscuro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppTema.textoSecundario,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(acao),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _alternarStatus(Categoria c, bool inativar) async {
    if (c.id == null) return false;
    try {
      if (inativar) {
        await _servico.inativar(c.id!);
        if (!mounted) return false;
        setState(() {
          final idx = _todas.indexWhere((x) => x.id == c.id);
          if (idx != -1) _todas[idx].ativo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "${c.nome}" inativada.'),
            backgroundColor: const Color(0xFF2E8B57),
          ),
        );
      } else {
        final atualizada = await _servico.ativar(c);
        if (!mounted) return false;
        setState(() {
          final idx = _todas.indexWhere((x) => x.id == c.id);
          if (idx != -1) _todas[idx].ativo = atualizada.ativo ?? true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "${c.nome}" reativada.'),
            backgroundColor: const Color(0xFF2E8B57),
          ),
        );
      }
      return true;
    } on ApiError catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.message}'),
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
    if (salvou == true) {
      if (!mounted) return;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            _construirBuscaEFiltro(),
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTema.primaria),
                    )
                  : _filtradas.isEmpty
                  ? AppEstadoVazio(
                      icone: Icons.category_outlined,
                      mensagem: _busca.isEmpty && _filtroStatus == 'TODAS'
                          ? 'Nenhuma categoria cadastrada'
                          : 'Nenhum resultado para a busca',
                    )
                  : RefreshIndicator(
                      color: AppTema.primaria,
                      onRefresh: _carregar,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: _filtradas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _construirCartao(_filtradas[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirBuscaEFiltro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AppCampoBusca(
            controle: _controleBusca,
            dica: 'Buscar por nome ou descrição...',
            aoMudar: (v) => setState(() => _busca = v),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOpcoes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _statusOpcoes[i];
                final selecionado = _filtroStatus == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _filtroStatus = s),
                  selectedColor: AppTema.primaria,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selecionado ? Colors.white : AppTema.textoEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(color: AppTema.bordaCampo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartao(Categoria c) {
    final ativa = c.ativo ?? true;
    final corFundoSwipe = ativa ? Colors.red.shade600 : const Color(0xFF2E8B57);
    final textoSwipe = ativa ? 'Inativar' : 'Reativar';
    final iconeSwipe = ativa
        ? FontAwesomeIcons.ban
        : FontAwesomeIcons.arrowRotateLeft;

    return Dismissible(
      key: ValueKey('categoria_${c.id ?? c.nome}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: corFundoSwipe,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              textoSwipe,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(iconeSwipe, color: Colors.white, size: 18),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final inativar = ativa;
        final confirmou = await _confirmarMudancaStatus(c, inativar);
        if (!confirmou) return false;
        await _alternarStatus(c, inativar);
        return false;
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _abrirFormulario(categoria: c),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTema.bordaCampo),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTema.fundoDica,
                  child: Text(
                    (c.nome.trim().isNotEmpty
                            ? c.nome.trim().characters.first
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTema.primaria,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTema.textoEscuro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (c.descricao?.trim().isNotEmpty ?? false)
                            ? c.descricao!
                            : 'Sem descrição',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTema.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      if (!ativa) ...[
                        const SizedBox(height: 6),
                        AppTag(
                          'Inativa',
                          fundo: Colors.red.shade100,
                          cor: Colors.red.shade800,
                        ),
                      ],
                    ],
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: AppTema.primariaEscura,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
