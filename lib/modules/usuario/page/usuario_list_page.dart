import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_form_page.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';

class UsuarioListaPagina extends StatefulWidget {
  const UsuarioListaPagina({super.key});

  @override
  State<UsuarioListaPagina> createState() => _UsuarioListaPaginaState();
}

class _UsuarioListaPaginaState extends State<UsuarioListaPagina> {
  final _servico = UsuarioServico();
  final _controleBusca = TextEditingController();

  List<UsuarioResposta> _todos = [];
  bool _carregando = true;
  bool _autorizado = false;
  String _filtroPerfil = 'TODOS';
  String _busca = '';

  static const _perfis = <String>['TODOS', 'ADMINISTRADOR', 'CAIXA', 'GARCOM'];

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final ehAdmin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() => _autorizado = ehAdmin);
    if (ehAdmin) {
      await _carregar();
    } else {
      setState(() => _carregando = false);
    }
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await _servico.listar();
      if (!mounted) return;
      setState(() => _todos = lista);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao listar: ${e.message}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<UsuarioResposta> get _filtrados {
    final termo = _busca.trim().toLowerCase();
    return _todos.where((u) {
      final casaPerfil = _filtroPerfil == 'TODOS' || u.perfil == _filtroPerfil;
      final casaBusca = termo.isEmpty ||
          (u.nome ?? '').toLowerCase().contains(termo) ||
          (u.login ?? '').toLowerCase().contains(termo);
      return casaPerfil && casaBusca;
    }).toList();
  }

  Future<bool> _confirmarExclusao(UsuarioResposta u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation,
                color: AppTema.primaria, size: 20),
            SizedBox(width: 10),
            Text('Excluir usuário',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.textoEscuro)),
          ],
        ),
        content: Text(
          'Deseja realmente excluir "${u.nome ?? u.login}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: AppTema.textoEscuro),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
                foregroundColor: AppTema.textoSecundario),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _excluir(UsuarioResposta u) async {
    if (u.id == null) return false;
    try {
      await _servico.deletar(u.id!);
      if (!mounted) return false;
      setState(() => _todos.removeWhere((x) => x.id == u.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário "${u.nome ?? u.login}" excluído.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } on ApiError catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> _abrirFormulario({UsuarioResposta? usuario}) async {
    final criado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => UsuarioFormularioPagina(usuario: usuario),
      ),
    );
    if (criado == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Usuário cadastrado com sucesso!'),
            backgroundColor: Color(0xFF2E8B57)),
      );
      _carregar();
    }
  }

  @override
  void dispose() {
    _controleBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_autorizado && !_carregando) {
      return const Scaffold(
        backgroundColor: AppTema.fundo,
        body: Padding(
          padding: EdgeInsets.all(24),
          child: AppEstadoVazio(
            icone: Icons.lock,
            mensagem:
                'Acesso restrito.\nApenas usuários ADMINISTRADOR podem gerenciar usuários.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _construirBuscaEFiltro(),
          Expanded(
            child: _carregando
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTema.primaria))
                : _filtrados.isEmpty
                    ? AppEstadoVazio(
                        icone: Icons.people_outline,
                        mensagem: _busca.isEmpty && _filtroPerfil == 'TODOS'
                            ? 'Nenhum usuário cadastrado'
                            : 'Nenhum resultado para a busca',
                      )
                    : RefreshIndicator(
                        color: AppTema.primaria,
                        onRefresh: _carregar,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _construirCartao(_filtrados[i]),
                        ),
                      ),
          ),
        ],
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
            dica: 'Buscar por nome ou login...',
            aoMudar: (v) => setState(() => _busca = v),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _perfis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = _perfis[i];
                final selecionado = _filtroPerfil == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _filtroPerfil = p),
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

  Widget _construirCartao(UsuarioResposta u) {
    return Dismissible(
      key: ValueKey('usuario_${u.id ?? u.login}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Excluir',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            SizedBox(width: 8),
            FaIcon(FontAwesomeIcons.trashCan, color: Colors.white, size: 20),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final confirmou = await _confirmarExclusao(u);
        if (!confirmou) return false;
        return await _excluir(u);
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _abrirFormulario(usuario: u),
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
                    ((u.nome?.trim().isNotEmpty ?? false)
                            ? u.nome!.trim().characters.first
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
                        u.nome ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTema.textoEscuro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('@${u.login ?? '-'}',
                          style: const TextStyle(
                              color: AppTema.textoSecundario, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          AppTag(u.perfil ?? '-'),
                          if (u.ativo == false) ...[
                            const SizedBox(width: 6),
                            AppTag(
                              'Inativo',
                              fundo: Colors.red.shade100,
                              cor: Colors.red.shade800,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const FaIcon(FontAwesomeIcons.chevronRight,
                    size: 14, color: AppTema.primariaEscura),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
