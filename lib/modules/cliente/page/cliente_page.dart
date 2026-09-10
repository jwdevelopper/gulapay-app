// lib/modules/cliente/page/cliente_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import '../dto/cliente_response.dart';
import '../service/cliente_service.dart';
import 'cliente_form_page.dart';
import 'cliente_detalhe_page.dart';
import 'package:my_app_teste/core/widgets/app_menu_acoes.dart';
import 'package:my_app_teste/core/widgets/app_cartao_deslizavel.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final _controleBusca = TextEditingController();
  List<ClienteResponse> _todos = [];
  bool _carregando = true;
  String _busca = '';
  String _filtroStatus = 'TODOS';

  static const _statusOpcoes = <String>['TODOS', 'ATIVOS', 'INATIVOS'];

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
      final lista = await listarClientes();
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

  List<ClienteResponse> get _filtrados {
    final termo = _busca.trim().toLowerCase();
    return _todos.where((c) {
      final casaStatus =
          _filtroStatus == 'TODOS' ||
          (_filtroStatus == 'ATIVOS' && (c.ativo ?? true)) ||
          (_filtroStatus == 'INATIVOS' && !(c.ativo ?? true));
      final casaBusca =
          termo.isEmpty ||
          (c.nome ?? '').toLowerCase().contains(termo) ||
          (c.telefone ?? '').contains(termo);
      return casaStatus && casaBusca;
    }).toList();
  }

  Future<void> _abrirFormulario({ClienteResponse? cliente}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
    if (resultado == true && mounted) _carregar();
  }

  Future<bool> _confirmarInativacao(ClienteResponse c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: AppTema.primaria,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Inativar cliente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja inativar "${c.nome ?? 'este cliente'}"? '
          'O histórico de pedidos será preservado.',
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
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Inativar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _confirmarReativacao(ClienteResponse c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.userCheck,
              color: AppTema.primaria,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Ativar cliente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja reativar "${c.nome ?? 'este cliente'}"?',
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
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<bool> _confirmarMudancaStatus(ClienteResponse c, bool ativa) async {
    if (ativa) {
      return await _confirmarInativacao(c);
    } else {
      return await _confirmarReativacao(c);
    }
  }

  Future<bool> _reativar(ClienteResponse c) async {
    if (c.id == null) return false;
    try {
      await reativarCliente(c.id!, c);
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente "${c.nome ?? ''}" reativado.'),
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

  Future<bool> _inativar(ClienteResponse c) async {
    if (c.id == null) return false;
    try {
      await inativarCliente(c.id!);
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente "${c.nome ?? ''}" inativado.'),
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

  Future<bool> _alternarStatus(ClienteResponse c, bool ativa) async {
    if (ativa) {
      return await _inativar(c);
    } else {
      return await _reativar(c);
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
          _construirBusca(),
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(color: AppTema.primaria),
                  )
                : _filtrados.isEmpty
                ? AppEstadoVazio(
                    icone: Icons.people_outline,
                    mensagem: _busca.isEmpty && _filtroStatus == 'TODOS'
                        ? 'Nenhum cliente cadastrado'
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

  Widget _construirBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AppCampoBusca(
            controle: _controleBusca,
            dica: 'Buscar por nome ou telefone...',
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
                  onSelected: (_) => setState(() => _filtroStatus = opcao),
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

  Widget _construirCartao(ClienteResponse c) {
    final isAtivo = c.ativo ?? true;

    final card = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirFormulario(cliente: c),
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
                  (c.nome!.trim().isNotEmpty
                          ? c.nome!.trim().characters.first
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
                      c.nome!,
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
                onEditar: () => _abrirFormulario(cliente: c),
                onExcluir: () async {
                  final confirmou = await _confirmarMudancaStatus(c, isAtivo);

                  if (!confirmou) return;

                  final sucesso = await _alternarStatus(c, isAtivo);

                  if (sucesso && mounted) {
                    await _carregar();
                  }
                },
                rotuloEditar: 'Editar',
                rotuloExcluir: isAtivo ? 'Inativar' : 'Reativar',
                tooltip: 'Ações da categoria',
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
      chave: 'cliente_${c.id ?? c.nome}',
      rotuloExclusao: 'Inativar',
      aoConfirmarExclusao: () async {
        final confirmou =
            await _confirmarMudancaStatus(c, true);

        if (!confirmou) {
          return false;
        }

        final sucesso = await _alternarStatus(c, true);

        if (sucesso && mounted) {
          await _carregar();
        }
        return false;
      },
      child: card,
    );
  }
}
