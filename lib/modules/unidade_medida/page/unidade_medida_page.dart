import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import '../dto/unidade_medida_response.dart';
import '../service/unidade_medida_service.dart';
import 'unidade_medida_form_page.dart';
import 'package:my_app_teste/core/widgets/app_menu_acoes.dart';
import 'package:my_app_teste/core/widgets/app_cartao_deslizavel.dart';

class UnidadeMedidaPage extends StatefulWidget {
  const UnidadeMedidaPage({super.key});

  @override
  State<UnidadeMedidaPage> createState() => _UnidadeMedidaPageState();
}

class _UnidadeMedidaPageState extends State<UnidadeMedidaPage> {
  final _controleBusca = TextEditingController();
  List<UnidadeMedidaResponse> _todos = [];
  bool _carregando = true;
  String _busca = '';
  String _filtroStatus = 'TODOS';
  String _filtroTipo = 'TODOS';

  static const _statusOpcoes = ['TODOS', 'ATIVOS', 'INATIVOS'];
  static const _tipoOpcoes = ['TODOS', 'MASSA', 'VOLUME', 'UNIDADE'];

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
      final lista = await listarUnidadesMedida();
      if (!mounted) return;
      setState(() => _todos = lista);
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

  List<UnidadeMedidaResponse> get _filtrados {
    final termo = _busca.trim().toLowerCase();
    return _todos.where((u) {
      final passaStatus = _filtroStatus == 'TODOS' ||
          (_filtroStatus == 'ATIVOS' && (u.ativo ?? true)) ||
          (_filtroStatus == 'INATIVOS' && !(u.ativo ?? true));
      final passaTipo = _filtroTipo == 'TODOS' || u.tipoMedida == _filtroTipo;
      final passaBusca = termo.isEmpty ||
          (u.nome ?? '').toLowerCase().contains(termo) ||
          (u.simbolo ?? '').toLowerCase().contains(termo);
      return passaStatus && passaTipo && passaBusca;
    }).toList();
  }

  Color _tipoColor(String? tipo) {
    switch (tipo) {
      case 'MASSA':
        return AppTema.primaria;
      case 'VOLUME':
        return const Color(0xFF5B8FD4);
      case 'UNIDADE':
        return const Color(0xFF4CAF50);
      default:
        return AppTema.primariaEscura;
    }
  }

  String _tipoNome(String? tipo) {
    switch (tipo) {
      case 'MASSA':
        return 'Massa';
      case 'VOLUME':
        return 'Volume';
      case 'UNIDADE':
        return 'Unidade';
      case 'TODOS':
        return 'Todos';
      default:
        return tipo ?? '—';
    }
  }

  double _simboloFontSize(String? simbolo) {
    final len = simbolo?.length ?? 1;
    if (len <= 2) return 16;
    if (len <= 4) return 13;
    return 10;
  }

  String _formatFator(double? fator) {
    if (fator == null) return '?';
    if (fator == fator.truncateToDouble()) return fator.toInt().toString();
    return fator.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  Future<void> _abrirFormulario({UnidadeMedidaResponse? unidade}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => UnidadeMedidaFormPage(unidade: unidade)),
    );
    if (resultado == true && mounted) _carregar();
  }

  Future<bool> _confirmarInativacao(UnidadeMedidaResponse u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation,
                color: AppTema.primaria, size: 20),
            SizedBox(width: 10),
            Text('Inativar unidade',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.textoEscuro)),
          ],
        ),
        content: Text(
          'Deseja inativar "${u.nome ?? 'esta unidade'}" (${u.simbolo ?? ''})? '
          'Ela deixará de aparecer como opção em novos cadastros.',
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
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _confirmarReativacao(UnidadeMedidaResponse u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.circleCheck,
                color: AppTema.primaria, size: 20),
            SizedBox(width: 10),
            Text('Ativar unidade',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.textoEscuro)),
          ],
        ),
        content: Text(
          'Deseja reativar "${u.nome ?? 'esta unidade'}" (${u.simbolo ?? ''})?',
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
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _confirmarMudancaStatus(UnidadeMedidaResponse u, bool isAtivo) async {
    if (isAtivo) {
      return _confirmarInativacao(u);
    } else {
      return _confirmarReativacao(u);
    }
  }

  Future<bool> _inativar(UnidadeMedidaResponse u) async {
    if (u.id == null) return false;
    try {
      await inativarUnidadeMedida(u.id!);
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${u.nome ?? u.simbolo}" inativada.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } on ApiError catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao inativar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _reativar(UnidadeMedidaResponse u) async {
    if (u.id == null) return false;
    try {
      await reativarUnidadeMedida(u.id!, u);
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${u.nome ?? u.simbolo}" reativada.'),
          backgroundColor: const Color(0xFF2E8B57),
        ),
      );
      return true;
    } on ApiError catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reativar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _alternarStatus(UnidadeMedidaResponse u, bool isAtivo) async {
    if (isAtivo) {
      return _inativar(u);
    } else {
      return _reativar(u);
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
      body: Column(
        children: [
          _construirFiltros(),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: AppTema.primaria))
                : _filtrados.isEmpty
                    ? AppEstadoVazio(
                        icone: Icons.straighten,
                        mensagem: _busca.isEmpty &&
                                _filtroStatus == 'TODOS' &&
                                _filtroTipo == 'TODOS'
                            ? 'Nenhuma unidade cadastrada'
                            : 'Nenhum resultado para os filtros',
                      )
                    : RefreshIndicator(
                        color: AppTema.primaria,
                        onRefresh: _carregar,
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _construirCartao(_filtrados[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _construirFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AppCampoBusca(
            controle: _controleBusca,
            dica: 'Buscar por nome ou símbolo...',
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
                final opcao = _statusOpcoes[i];
                final selecionado = _filtroStatus == opcao;
                return ChoiceChip(
                  label: Text(opcao),
                  selected: selecionado,
                  onSelected: (_) =>
                      setState(() => _filtroStatus = opcao),
                  selectedColor: AppTema.primaria,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        selecionado ? Colors.white : AppTema.textoEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(color: AppTema.bordaCampo),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tipoOpcoes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final opcao = _tipoOpcoes[i];
                final selecionado = _filtroTipo == opcao;
                final cor = opcao == 'TODOS'
                    ? AppTema.primaria
                    : _tipoColor(opcao);
                return ChoiceChip(
                  label: Text(_tipoNome(opcao)),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _filtroTipo = opcao),
                  selectedColor: cor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        selecionado ? Colors.white : AppTema.textoEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                      color:
                          selecionado ? cor : AppTema.bordaCampo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartao(UnidadeMedidaResponse u) {
    final isAtivo = u.ativo ?? true;
    final tipoColor = _tipoColor(u.tipoMedida);
    final isBase = (u.fatorParaBase ?? 0) == 1.0;

    final card = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirFormulario(unidade: u),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTema.bordaCampo,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTema.fundoDica,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  (u.nome!.trim().isNotEmpty
                          ? u.nome!.trim().characters.first
                          : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.primaria,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nome!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTema.textoEscuro,
                      ),
                    ),

                    if (!isAtivo) ...[
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

              const SizedBox(width: 8),

              AppMenuAcoes(
                onEditar: () => _abrirFormulario(unidade: u),
                onExcluir: () async {
                  final confirmou = await _confirmarMudancaStatus(u, isAtivo);

                  if (!confirmou) return;

                  final sucesso = await _alternarStatus(u, isAtivo);

                  if (sucesso && mounted) {
                    await _carregar();
                  }
                },
                rotuloEditar: 'Editar',
                rotuloExcluir: isAtivo ? 'Inativar' : 'Reativar',
                tooltip: 'Ações de Unidade de Medida',
              ),
            ],
          ),
        ),
      ),
    );

    if (!isAtivo) {
      return card;
    }
   
    return AppCartaoDeslizavel(
      chave: 'unidade_${u.id ?? u.nome}',
      rotuloExclusao: 'Inativar',
      aoConfirmarExclusao: () async {
        final confirmou =
            await _confirmarMudancaStatus(u, true);

        if (!confirmou) {
          return false;
        }

        final sucesso = await _alternarStatus(u, true);

        if (sucesso && mounted) {
          await _carregar();
        }
        return false;
      },
      child: card,
    );
  }
}
