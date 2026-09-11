import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/comanda/widgets/cartao_item_comanda.dart';
import 'package:my_app_teste/modules/comanda/widgets/resumo_comanda.dart';
import 'package:my_app_teste/modules/comanda/widgets/folha_eventos_item.dart';
import 'package:my_app_teste/modules/comanda/widgets/folha_item_comanda.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/auth_session.dart';
import '../dto/comanda_response.dart';
import '../dto/item_comanda_create_request.dart';
import '../dto/item_comanda_update_request.dart';
import '../service/comanda_service.dart';
import '../service/item_comanda_service.dart';
import 'comanda_edit_page.dart';

class ComandaDetalhePage extends StatefulWidget {
  const ComandaDetalhePage({super.key, required this.id});

  final int id;

  @override
  State<ComandaDetalhePage> createState() => _ComandaDetalhePageState();
}

class _ComandaDetalhePageState extends State<ComandaDetalhePage> {
  final _service = ComandaService();
  final _itemService = ItemComandaService();
  ComandaResponse? _comanda;
  String? _perfil;
  int? _usuarioId;
  String? _erro;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await Future.wait([
        _service.buscarPorId(widget.id),
        SessaoAutenticacao.obterPerfil(),
        SessaoAutenticacao.dados(),
      ]);
      if (!mounted) return;
      final claims = result[2] as Map<String, dynamic>;
      setState(() {
        _comanda = result[0] as ComandaResponse;
        _perfil = result[1] as String?;
        _usuarioId = _parseInt(
          claims['usuarioId'] ?? claims['id'] ?? claims['userId'],
        );
        _loading = false;
        _erro = null;
      });
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar a comanda.';
          _loading = false;
        });
      }
    }
  }

  int? _parseInt(dynamic value) =>
      value == null ? null : int.tryParse(value.toString());

  bool get _admin => _perfil == 'ADMINISTRADOR';
  bool get _caixa => _admin || _perfil == 'CAIXA';
  bool get _garcom => _perfil == 'GARCOM';
  bool get _comandaAberta =>
      _comanda?.status == 'ABERTA' ||
      _comanda?.status == 'AGUARDANDO_PAGAMENTO';
  bool get _garcomDono =>
      _garcom &&
      _usuarioId != null &&
      _comanda?.garcomId != null &&
      _usuarioId == _comanda!.garcomId;
  bool get _podeMutarItens => _caixa || _garcomDono;
  bool get _podeEditarComanda => _caixa || _garcomDono;

  Future<void> _action(String action) async {
    setState(() => _actionLoading = true);
    try {
      final updated = switch (action) {
        'fechar' => await _service.fechar(widget.id),
        'cancelar' => await _service.cancelar(widget.id),
        _ => await _service.reabrir(widget.id),
      };
      if (mounted) setState(() => _comanda = updated);
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _editarComanda() async {
    final comanda = _comanda;
    if (comanda == null) return;
    final alterada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ComandaEditPage(comanda: comanda, perfil: _perfil),
      ),
    );
    if (alterada == true) await _load();
  }

  Future<void> _runItemMutation(Future<void> Function() call) async {
    setState(() => _actionLoading = true);
    try {
      await call();
      await _load();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível concluir a operação.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  bool _podeEditar(ItemComandaResponse item) =>
      item.emPreparo && _podeMutarItens && _comandaAberta;
  bool _podeEntregar(ItemComandaResponse item) =>
      item.emPreparo && _podeMutarItens && _comandaAberta;
  bool _podeTransferir(ItemComandaResponse item) {
    if (!_comandaAberta ||
        _comanda?.tipoOrigem != 'MESA' ||
        _comanda?.mesaId == null) {
      return false;
    }
    if (item.emPreparo) return _podeMutarItens;
    if (item.entregue) return _caixa;
    return false;
  }

  bool _podeCancelar(ItemComandaResponse item) {
    if (!_comandaAberta) return false;
    if (item.emPreparo) return _podeMutarItens;
    if (item.entregue) return _caixa;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTema.fundo,
        body: AppCarregando(),
      );
    }

    if (_erro != null) {
      return Scaffold(
        backgroundColor: AppTema.fundo,
        body: SafeArea(
          child: Column(
            children: [
              _pageHeader('Comanda'),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppTema.primaria,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTema.texto,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _load,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTema.primaria,
                          ),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final comanda = _comanda!;
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Column(
          children: [
            _pageHeader(
              comanda.codigo.isEmpty
                  ? 'Comanda #${comanda.id}'
                  : comanda.codigo,
              mostrarEditar: _podeEditarComanda,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTema.primaria,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    ResumoComanda(comanda: comanda),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ITENS DA COMANDA',
                            style: TextStyle(
                              color: AppTema.textoSecundario,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (_comandaAberta && _podeMutarItens)
                          TextButton.icon(
                            onPressed: _actionLoading
                                ? null
                                : _abrirAdicionarItem,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Adicionar'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTema.primaria,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (comanda.itens.isEmpty)
                      _emptyItems()
                    else
                      ...comanda.itens.map(_construirCartaoItem),
                  ],
                ),
              ),
            ),
            _actions(comanda),
          ],
        ),
      ),
    );
  }

  Widget _pageHeader(String title, {bool mostrarEditar = false}) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppTema.superficie,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTema.borda),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTema.texto),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTema.texto,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Detalhes da venda',
                style: TextStyle(color: AppTema.textoSecundario, fontSize: 12),
              ),
            ],
          ),
        ),
        if (mostrarEditar) ...[
          const SizedBox(width: 8),
          Material(
            color: AppTema.superficie,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _editarComanda,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTema.borda),
                ),
                child: const Icon(Icons.edit_outlined, color: AppTema.texto),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _emptyItems() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTema.borda),
    ),
    child: const Column(
      children: [
        Icon(Icons.receipt_long_outlined, size: 36, color: AppTema.primaria),
        SizedBox(height: 10),
        Text(
          'Nenhum item lançado nesta comanda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTema.texto, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  /// Monta o cartão de um item já com as permissões resolvidas para o
  /// perfil logado e as ações ligadas aos handlers da página.
  Widget _construirCartaoItem(ItemComandaResponse item) => CartaoItemComanda(
    item: item,
    podeEditar: _podeEditar(item),
    podeEntregar: _podeEntregar(item),
    podeTransferir: _podeTransferir(item),
    podeCancelar: _podeCancelar(item),
    acaoEmAndamento: _actionLoading,
    aoEditar: () => _abrirEditarItem(item),
    aoEntregar: () => _entregarItem(item),
    aoTransferir: () => _abrirTransferirItem(item),
    aoCancelar: () => _abrirCancelarItem(item),
    aoVerEventos: () => _abrirEventos(item),
  );

  Widget _actions(ComandaResponse c) {
    final active = c.status == 'ABERTA' || c.status == 'AGUARDANDO_PAGAMENTO';
    if (!(_caixa && active) && !(_admin && c.status == 'FECHADA')) {
      return const SizedBox(height: 12);
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: AppTema.superficie,
          border: Border(top: BorderSide(color: AppTema.bordaSuave)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_caixa && active)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _actionLoading
                          ? null
                          : () => _action('cancelar'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTema.erro,
                        side: const BorderSide(color: AppTema.erro),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _actionLoading
                          ? null
                          : () => _action('fechar'),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const Text('Fechar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTema.primaria,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            if (_admin && c.status == 'FECHADA')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _actionLoading ? null : () => _action('reabrir'),
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Reabrir comanda'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTema.texto,
                    side: const BorderSide(color: AppTema.borda),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirAdicionarItem() async {
    final comandaId = _comanda?.id;
    if (comandaId == null) return;

    final result = await showModalBottomSheet<ResultadoFormItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTema.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const FolhaItemComanda(titulo: 'Adicionar item'),
    );
    if (result == null || !mounted) return;

    await _runItemMutation(() async {
      await _itemService.adicionar(
        comandaId,
        ItemComandaCreateRequest(
          produtoId: result.produtoId,
          quantidade: result.quantidade,
          valorDesconto: result.valorDesconto,
          valorAcrescimo: result.valorAcrescimo,
          observacao: result.observacao,
        ),
      );
    });
  }

  Future<void> _abrirEditarItem(ItemComandaResponse item) async {
    if (item.id == null) return;
    final result = await showModalBottomSheet<ResultadoFormItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTema.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FolhaItemComanda(
        titulo: 'Editar item',
        produtoFixoNome: item.produtoNome,
        quantidadeInicial: item.quantidade,
        descontoInicial: item.valorDesconto,
        acrescimoInicial: item.valorAcrescimo,
        observacaoInicial: item.observacao,
        edicao: true,
      ),
    );
    if (result == null || !mounted) return;

    await _runItemMutation(() async {
      await _itemService.editar(
        item.id!,
        ItemComandaUpdateRequest(
          quantidade: result.quantidade,
          valorDesconto: result.valorDesconto,
          valorAcrescimo: result.valorAcrescimo,
          observacao: result.observacao,
        ),
      );
    });
  }

  Future<void> _entregarItem(ItemComandaResponse item) async {
    if (item.id == null) return;
    await _runItemMutation(() => _itemService.marcarEntregue(item.id!));
  }

  Future<void> _abrirCancelarItem(ItemComandaResponse item) async {
    if (item.id == null) return;
    String? motivo = motivosCancelamentoItem.keys.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppTema.superficie,
          title: const Text(
            'Cancelar item',
            style: TextStyle(color: AppTema.texto, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.produtoNome,
                style: const TextStyle(color: AppTema.textoSecundario),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: motivo,
                decoration: const InputDecoration(
                  labelText: 'Motivo *',
                  border: OutlineInputBorder(),
                ),
                items: motivosCancelamentoItem.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (value) => setLocal(() => motivo = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: motivo == null ? null : () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppTema.erro),
              child: const Text('Cancelar item'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || motivo == null || !mounted) return;
    await _runItemMutation(() => _itemService.cancelar(item.id!, motivo!));
  }

  Future<void> _abrirTransferirItem(ItemComandaResponse item) async {
    if (item.id == null || _comanda?.mesaId == null) return;
    setState(() => _actionLoading = true);
    List<ComandaResponse> destinos = const [];
    try {
      final lista = await _service.listar(
        mesaId: _comanda!.mesaId,
        status: 'ABERTA',
      );
      destinos = lista
          .where((c) => c.id != null && c.id != _comanda!.id)
          .toList();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _actionLoading = false);
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível listar comandas da mesa.'),
          ),
        );
        setState(() => _actionLoading = false);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _actionLoading = false);

    if (destinos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há outra comanda aberta nesta mesa.'),
        ),
      );
      return;
    }

    int? destinoId = destinos.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppTema.superficie,
          title: const Text(
            'Transferir item',
            style: TextStyle(color: AppTema.texto, fontWeight: FontWeight.w700),
          ),
          content: DropdownButtonFormField<int>(
            initialValue: destinoId,
            decoration: const InputDecoration(
              labelText: 'Comanda destino',
              border: OutlineInputBorder(),
            ),
            items: destinos
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.codigo.isEmpty ? 'Comanda #${c.id}' : c.codigo,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setLocal(() => destinoId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: destinoId == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Transferir'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || destinoId == null || !mounted) return;
    await _runItemMutation(() => _itemService.transferir(item.id!, destinoId!));
  }

  Future<void> _abrirEventos(ItemComandaResponse item) async {
    if (item.id == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTema.superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          FolhaEventosItem(itemId: item.id!, itemNome: item.produtoNome),
    );
  }
}
