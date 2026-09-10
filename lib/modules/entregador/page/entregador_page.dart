import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_active_count.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_card.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_empty_state.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_results_header.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregador_search_field.dart';
import 'package:my_app_teste/modules/entregador/widgets/entregadores_palette.dart';

import 'entregador_form_page.dart';

class EntregadorPage extends StatefulWidget {
  final EntregadorService? service;

  const EntregadorPage({super.key, this.service});

  @override
  State<EntregadorPage> createState() => _EntregadorPageState();
}

class _EntregadorPageState extends State<EntregadorPage> {
  // Estes campos sao anulaveis de proposito. Em Flutter Web, um hot reload que
  // adiciona campos a um State ja montado pode preservar a instancia antiga
  // com propriedades `undefined`. Os getters e o reassemble recuperam esse
  // estado sem derrubar a arvore de widgets.
  TextEditingController? _searchController = TextEditingController();
  EntregadorService? _service;
  List<EntregadorResponse>? _entregadores = <EntregadorResponse>[];
  bool? _loading = true;
  bool? _ascending = true;
  String? _search = '';
  String? _loadError;

  TextEditingController get _resolvedSearchController =>
      _searchController ??= TextEditingController();

  EntregadorService get _resolvedService =>
      _service ??= widget.service ?? EntregadorService();

  List<EntregadorResponse> get _items =>
      _entregadores ??= <EntregadorResponse>[];

  bool get _isLoading => _loading ?? true;
  bool get _isAscending => _ascending ?? true;
  String get _searchValue => _search ?? '';

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
    _load();
  }

  @override
  void reassemble() {
    super.reassemble();
    _ensureInitialized();
    _load();
  }

  void _ensureInitialized() {
    _searchController ??= TextEditingController();
    _service ??= widget.service ?? EntregadorService();
    _entregadores ??= <EntregadorResponse>[];
    _loading ??= true;
    _ascending ??= true;
    _search ??= '';
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _searchController = null;
    super.dispose();
  }

  List<EntregadorResponse> get _filtered {
    final query = _searchValue.trim().toLowerCase();
    final result = _items.where((entregador) {
      if (query.isEmpty) return true;
      return entregador.nome.toLowerCase().contains(query) ||
          entregador.telefone.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      final comparison = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });
    return result;
  }

  String get _activeCountLabel {
    if (_isLoading) return 'Carregando entregadores...';
    if (_loadError != null) return 'Entregadores ativos indisponíveis';
    final label = _items.length == 1
        ? 'entregador ativo'
        : 'entregadores ativos';
    return '${_items.length} $label';
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final entregadores = await _resolvedService.listar(apenasAtivos: true);
      if (!mounted) return;
      setState(() => _entregadores = entregadores);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Erro inesperado ao consultar a API.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntregadorFormPage(service: _resolvedService),
      ),
    );
    if (created != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entregador cadastrado com sucesso.'),
        backgroundColor: EntregadoresPalette.success,
      ),
    );
    await _load();
  }

  Future<void> _openEdit(EntregadorResponse entregador) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntregadorFormPage(
          entregador: entregador,
          service: _resolvedService,
        ),
      ),
    );
    if (changed != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entregador atualizado com sucesso.'),
        backgroundColor: EntregadoresPalette.success,
      ),
    );
    await _load();
  }

  Future<bool> _confirmDelete(EntregadorResponse entregador) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: EntregadoresPalette.primary,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Excluir entregador',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: EntregadoresPalette.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja excluir "${entregador.nome}"? O entregador será inativado e sairá desta lista.',
          style: const TextStyle(color: EntregadoresPalette.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: EntregadoresPalette.textMuted,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _delete(EntregadorResponse entregador) async {
    if (entregador.id == null) return false;

    try {
      await _resolvedService.inativar(entregador.id!);
      if (!mounted) return false;
      setState(() {
        _items.removeWhere((item) => item.id == entregador.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entregador "${entregador.nome}" excluído.'),
          backgroundColor: EntregadoresPalette.success,
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
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao excluir o entregador.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _confirmAndDelete(EntregadorResponse entregador) async {
    if (!await _confirmDelete(entregador)) return false;
    return _delete(entregador);
  }

  void _clearSearch() {
    _resolvedSearchController.clear();
    setState(() => _search = '');
  }

  Widget _buildList() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 96),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(
              color: EntregadoresPalette.primary,
            ),
          ),
        ],
      );
    }

    if (_loadError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
        children: [
          EntregadorEmptyState(
            title: 'Não foi possível carregar',
            subtitle: _loadError!,
            icon: Icons.cloud_off_rounded,
            buttonLabel: 'Tentar novamente',
            buttonIcon: Icons.refresh_rounded,
            onPressed: _load,
            secondary: true,
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
        children: [
          EntregadorEmptyState(
            title: 'Sem entregadores por aqui',
            subtitle:
                'Cadastre o primeiro entregador para organizar as entregas dos pedidos.',
            icon: Icons.delivery_dining_rounded,
            buttonLabel: 'Cadastrar entregador',
            buttonIcon: Icons.add_rounded,
            onPressed: _openCreate,
          ),
        ],
      );
    }

    if (_filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
        children: [
          EntregadorEmptyState(
            title: 'Nenhum entregador encontrado',
            subtitle: 'Tente buscar por outro nome ou telefone.',
            icon: Icons.search_off_rounded,
            buttonLabel: 'Limpar busca',
            buttonIcon: Icons.close_rounded,
            onPressed: _clearSearch,
            secondary: true,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entregador = _filtered[index];
        return EntregadorCard(
          entregador: entregador,
          onTap: () => _openEdit(entregador),
          onEdit: () => _openEdit(entregador),
          onConfirmDelete: () => _confirmAndDelete(entregador),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EntregadoresPalette.background,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Cadastrar entregador',
        onPressed: _openCreate,
        backgroundColor: EntregadoresPalette.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            EntregadorActiveCount(label: _activeCountLabel),
            EntregadorSearchField(
              controller: _resolvedSearchController,
              search: _searchValue,
              onChanged: (value) => setState(() => _search = value),
              onClear: _clearSearch,
            ),
            EntregadorResultsHeader(
              resultCount: _filtered.length,
              ascending: _isAscending,
              onSortTap: () => setState(() => _ascending = !_isAscending),
            ),
            Expanded(
              child: RefreshIndicator(
                color: EntregadoresPalette.primary,
                onRefresh: _load,
                child: _buildList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
