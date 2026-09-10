import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';
import 'package:my_app_teste/modules/produto/service/produto_service.dart';
import '../dto/comanda_response.dart';
import '../dto/evento_item_comanda_response.dart';
import '../dto/item_comanda_create_request.dart';
import '../dto/item_comanda_update_request.dart';
import '../service/comanda_service.dart';
import '../service/item_comanda_service.dart';

const _motivosCancelamento = <String, String>{
  'LANCAMENTO_INCORRETO': 'Lançamento incorreto',
  'CLIENTE_DESISTIU': 'Cliente desistiu',
  'CORTESIA': 'Cortesia',
  'ERRO_PRODUCAO': 'Erro de produção',
};

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
  bool _paymentLoading = false;

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
        _usuarioId = _parseInt(claims['usuarioId'] ?? claims['id'] ?? claims['userId']);
        _loading = false;
        _erro = null;
      });
    } on ApiError catch (e) {
      if (mounted) setState(() { _erro = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _erro = 'Não foi possível carregar a comanda.'; _loading = false; });
    }
  }

  int? _parseInt(dynamic value) => value == null ? null : int.tryParse(value.toString());

  bool get _admin => _perfil == 'ADMINISTRADOR';
  bool get _caixa => _admin || _perfil == 'CAIXA';
  bool get _garcom => _perfil == 'GARCOM';
  bool get _comandaAberta =>
      _comanda?.status == 'ABERTA' || _comanda?.status == 'AGUARDANDO_PAGAMENTO';
  bool get _garcomDono =>
      _garcom && _usuarioId != null && _comanda?.garcomId != null && _usuarioId == _comanda!.garcomId;
  bool get _podeMutarItens => _caixa || _garcomDono;

  String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  String _quantityLabel(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString().replaceAll('.', ',');

  String _friendlyOrigin(String origin) => switch (origin) {
        'MESA' => 'Mesa',
        'BALCAO' => 'Balcão',
        'DELIVERY' => 'Delivery',
        _ => origin,
      };

  Color _statusColor(String status) => switch (status) {
        'FECHADA' => EstoquePalette.success,
        'CANCELADA' => EstoquePalette.error,
        'AGUARDANDO_PAGAMENTO' => Colors.orange,
        _ => EstoquePalette.primary,
      };

  IconData _originIcon(String origin) => switch (origin) {
        'MESA' => Icons.table_restaurant_rounded,
        'DELIVERY' => Icons.delivery_dining_rounded,
        _ => Icons.storefront_rounded,
      };

  String _itemStatusLabel(String status) => switch (status) {
        'EM_PREPARO' => 'Em preparo',
        'ENTREGUE' => 'Entregue',
        'CANCELADO' => 'Cancelado',
        'TRANSFERIDO' => 'Transferido',
        _ => status.replaceAll('_', ' '),
      };

  Color _itemStatusColor(String status) => switch (status) {
        'EM_PREPARO' => EstoquePalette.primary,
        'ENTREGUE' => EstoquePalette.success,
        'CANCELADO' => EstoquePalette.error,
        'TRANSFERIDO' => Colors.blueGrey,
        _ => EstoquePalette.textMuted,
      };

  String _acaoLabel(String acao) => switch (acao) {
        'CRIADO' => 'Criado',
        'EDITADO' => 'Editado',
        'TRANSFERIDO' => 'Transferido',
        'CANCELADO' => 'Cancelado',
        'ENTREGUE' => 'Entregue',
        _ => acao,
      };

  Future<void> _action(String action) async {
    if (action == 'fechar') {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: EstoquePalette.surface,
          title: const Text('Fechar comanda?', style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w700)),
          content: const Text('Confira os itens e o valor total antes de finalizar esta venda.', style: TextStyle(color: EstoquePalette.textMuted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Fechar comanda')),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }
    setState(() => _actionLoading = true);
    try {
      final updated = switch (action) {
        'fechar' => await _service.fechar(widget.id),
        'cancelar' => await _service.cancelar(widget.id),
        _ => await _service.reabrir(widget.id),
      };
      if (mounted) {
        setState(() => _comanda = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action == 'fechar' ? 'Comanda fechada com sucesso.' : 'Comanda atualizada.')),
        );
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _runItemMutation(Future<void> Function() call) async {
    setState(() => _actionLoading = true);
    try {
      await call();
      await _load();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível concluir a operação.')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  bool _podeEditar(ItemComandaResponse item) => item.emPreparo && _podeMutarItens && _comandaAberta;
  bool _podeEntregar(ItemComandaResponse item) => item.emPreparo && _podeMutarItens && _comandaAberta;
  bool _podeTransferir(ItemComandaResponse item) {
    if (!_comandaAberta || _comanda?.tipoOrigem != 'MESA' || _comanda?.mesaId == null) return false;
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
        backgroundColor: EstoquePalette.background,
        body: Center(child: CircularProgressIndicator(color: EstoquePalette.primary)),
      );
    }

    if (_erro != null) {
      return Scaffold(
        backgroundColor: EstoquePalette.background,
        body: SafeArea(
          child: Column(children: [
            _pageHeader('Comanda'),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.receipt_long_outlined, size: 48, color: EstoquePalette.primary),
                    const SizedBox(height: 14),
                    Text(_erro!, textAlign: TextAlign.center, style: const TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _load, style: TextButton.styleFrom(foregroundColor: EstoquePalette.primary), child: const Text('Tentar novamente')),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    final comanda = _comanda!;
    return Scaffold(
      backgroundColor: EstoquePalette.background,
      body: SafeArea(
        child: Column(children: [
          _pageHeader(comanda.codigo.isEmpty ? 'Comanda #${comanda.id}' : comanda.codigo),
          Expanded(
            child: RefreshIndicator(
              color: EstoquePalette.primary,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  _summaryCard(comanda),
                  const SizedBox(height: 22),
                  Row(children: [
                    const Expanded(child: Text('ITENS DA COMANDA', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
                    if (_comandaAberta && _podeMutarItens)
                      TextButton.icon(
                        onPressed: _actionLoading ? null : _abrirAdicionarItem,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Adicionar'),
                        style: TextButton.styleFrom(foregroundColor: EstoquePalette.primary),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  if (comanda.itens.isEmpty) _emptyItems() else ...comanda.itens.map(_itemCard),
                ],
              ),
            ),
          ),
          _actions(comanda),
        ]),
      ),
    );
  }

  Widget _pageHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Material(
            color: EstoquePalette.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EstoquePalette.border),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: EstoquePalette.text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
              const SizedBox(height: 2),
              const Text('Detalhes da venda', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
            ]),
          ),
        ]),
      );

  Widget _summaryCard(ComandaResponse c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EstoquePalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EstoquePalette.border),
          boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(14)), child: Icon(_originIcon(c.tipoOrigem), color: EstoquePalette.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_friendlyOrigin(c.tipoOrigem), style: const TextStyle(color: EstoquePalette.text, fontSize: 15, fontWeight: FontWeight.w700)),
              Text(c.clienteNome ?? 'Cliente não informado', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
            ])),
            _statusChip(c.status),
          ]),
          if (c.mesaNumero != null || c.garcomNome != null) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (c.mesaNumero != null) _infoPill(Icons.table_restaurant_outlined, 'Mesa ${c.mesaNumero}'),
              if (c.garcomNome != null) _infoPill(Icons.person_outline_rounded, c.garcomNome!),
            ]),
          ],
          if (c.linkWhatsApp?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: c.linkWhatsApp!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link do WhatsApp copiado.')));
              },
              style: TextButton.styleFrom(foregroundColor: EstoquePalette.primary, padding: EdgeInsets.zero),
              icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
              label: const Text('Abrir no WhatsApp'),
            ),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: EstoquePalette.borderSoft)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total líquido', style: TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
            Text(_money(c.totalLiquido), style: const TextStyle(color: EstoquePalette.primary, fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        ]),
      );

  Widget _statusChip(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: _statusColor(status).withValues(alpha: 0.35))),
        child: Text(status.replaceAll('_', ' '), style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w800)),
      );

  Widget _infoPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: EstoquePalette.textMuted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: EstoquePalette.text, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _emptyItems() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: EstoquePalette.border)),
        child: const Column(children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: EstoquePalette.primary),
          SizedBox(height: 10),
          Text('Nenhum item lançado nesta comanda.', textAlign: TextAlign.center, style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _itemCard(ItemComandaResponse item) {
    final color = _itemStatusColor(item.status);
    final menuItems = <PopupMenuEntry<String>>[
      if (_podeEditar(item)) _menuItem('editar', Icons.edit_rounded, 'Editar'),
      if (_podeTransferir(item)) _menuItem('transferir', Icons.swap_horiz_rounded, 'Transferir'),
      if (item.id != null) _menuItem('eventos', Icons.history_rounded, 'Histórico'),
      if (_podeCancelar(item)) ...[
        const PopupMenuDivider(height: 8),
        _menuItem('cancelar', Icons.cancel_outlined, 'Cancelar item', danger: true),
      ],
    ];
    final podeEntregar = _podeEntregar(item);
    final temMenu = menuItems.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: EstoquePalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.restaurant_rounded, color: EstoquePalette.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.produtoNome, style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${_quantityLabel(item.quantidade)} × ${_money(item.precoUnitario)}', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
                if (item.valorDesconto > 0 || item.valorAcrescimo > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (item.valorDesconto > 0) 'Desc. ${_money(item.valorDesconto)}',
                      if (item.valorAcrescimo > 0) 'Acrés. ${_money(item.valorAcrescimo)}',
                    ].join(' · '),
                    style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11),
                  ),
                ],
                if (item.observacao?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(item.observacao!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
                ],
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_money(item.subtotal), style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              AppTag(_itemStatusLabel(item.status), fundo: color.withValues(alpha: 0.12), cor: color),
            ]),
            if (temMenu)
              PopupMenuButton<String>(
                tooltip: 'Ações do item',
                enabled: !_actionLoading,
                padding: EdgeInsets.zero,
                offset: const Offset(0, 8),
                color: EstoquePalette.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: EstoquePalette.border),
                ),
                constraints: const BoxConstraints(minWidth: 180),
                icon: const Icon(Icons.more_horiz_rounded, color: EstoquePalette.textMuted, size: 22),
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      _abrirEditarItem(item);
                    case 'transferir':
                      _abrirTransferirItem(item);
                    case 'eventos':
                      _abrirEventos(item);
                    case 'cancelar':
                      _abrirCancelarItem(item);
                  }
                },
                itemBuilder: (_) => menuItems,
              ),
          ]),
          if (podeEntregar) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _actionLoading ? null : () => _entregarItem(item),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Marcar como entregue'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EstoquePalette.primary,
                    side: const BorderSide(color: EstoquePalette.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {bool danger = false}) {
    final color = danger ? EstoquePalette.error : EstoquePalette.text;
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color, fontWeight: danger ? FontWeight.w600 : FontWeight.w500)),
      ]),
    );
  }

  Widget _actions(ComandaResponse c) {
    final active = c.status == 'ABERTA' || c.status == 'AGUARDANDO_PAGAMENTO';
    if (!(_caixa && active) && !(_admin && c.status == 'FECHADA')) {
      return const SizedBox(height: 12);
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(color: EstoquePalette.surface, border: Border(top: BorderSide(color: EstoquePalette.borderSoft))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_caixa && active)
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _actionLoading ? null : () => _action('cancelar'), icon: const Icon(Icons.cancel_outlined, size: 18), label: const Text('Cancelar'), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.error, side: const BorderSide(color: EstoquePalette.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: _actionLoading || _paymentLoading ? null : _abrirPagamento, icon: const Icon(Icons.payments_outlined, size: 18), label: const Text('Pagar'), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.primary, side: const BorderSide(color: EstoquePalette.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(onPressed: _actionLoading ? null : () => _action('fechar'), icon: const Icon(Icons.check_circle_outline_rounded, size: 18), label: const Text('Fechar'), style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
            ]),
          if (_admin && c.status == 'FECHADA')
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _actionLoading ? null : () => _action('reabrir'), icon: const Icon(Icons.lock_open_rounded, size: 18), label: const Text('Reabrir comanda'), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, side: const BorderSide(color: EstoquePalette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
        ]),
      ),
    );
  }

  Future<void> _abrirPagamento() async {
    final c = _comanda;
    if (c?.id == null) return;
    String forma = 'DINHEIRO';
    final valorCtrl = TextEditingController(text: c!.totalLiquido.toStringAsFixed(2).replaceAll('.', ','));
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
        backgroundColor: EstoquePalette.surface,
        title: const Text('Registrar pagamento', style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Total da comanda: ${_money(c.totalLiquido)}', style: const TextStyle(color: EstoquePalette.textMuted)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(initialValue: forma, isExpanded: true, decoration: _dialogDecoration('Forma de pagamento'), items: const [
            DropdownMenuItem(value: 'DINHEIRO', child: Text('Dinheiro')),
            DropdownMenuItem(value: 'PIX', child: Text('PIX')),
            DropdownMenuItem(value: 'CARTAO_CREDITO', child: Text('Cartão de crédito')),
            DropdownMenuItem(value: 'CARTAO_DEBITO', child: Text('Cartão de débito')),
          ], onChanged: (v) => setLocal(() => forma = v ?? forma)),
          const SizedBox(height: 12),
          TextField(controller: valorCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))], decoration: _dialogDecoration('Valor pago', prefix: 'R\$ ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar pagamento')),
        ],
      )),
    );
    final valor = _parseMoney(valorCtrl.text);
    valorCtrl.dispose();
    if (confirmado != true || valor == null || valor <= 0 || !mounted) return;
    setState(() => _paymentLoading = true);
    try {
      final updated = await _service.registrarPagamento(c.id!, formaPagamento: forma, valor: valor);
      if (mounted) {
        setState(() => _comanda = updated);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pagamento registrado com sucesso.')));
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível registrar o pagamento.')));
    } finally { if (mounted) setState(() => _paymentLoading = false); }
  }

  InputDecoration _dialogDecoration(String label, {String? prefix}) => InputDecoration(labelText: label, prefixText: prefix, floatingLabelBehavior: FloatingLabelBehavior.always, filled: true, fillColor: EstoquePalette.surfaceAlt, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.primary, width: 1.5)));

  double? _parseMoney(String raw) {
    final value = raw.trim().replaceAll(RegExp(r'[^0-9,.]'), '');
    if (value.isEmpty) return null;
    return double.tryParse(value.contains(',') ? value.replaceAll('.', '').replaceAll(',', '.') : value);
  }

  Future<void> _abrirAdicionarItem() async {
    final comandaId = _comanda?.id;
    if (comandaId == null) return;

    final result = await showModalBottomSheet<_ItemFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EstoquePalette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => const _ItemFormSheet(titulo: 'Adicionar item'),
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
    final result = await showModalBottomSheet<_ItemFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EstoquePalette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ItemFormSheet(
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
    String? motivo = _motivosCancelamento.keys.first;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EstoquePalette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: EstoquePalette.border, borderRadius: BorderRadius.circular(999)))),
              const Text('Cancelar item', style: TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(item.produtoNome, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: motivo,
                isExpanded: true,
                decoration: _dialogDecoration('Motivo *'),
                items: _motivosCancelamento.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (value) => setLocal(() => motivo = value),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, side: const BorderSide(color: EstoquePalette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Voltar'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: motivo == null ? null : () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.error, foregroundColor: Colors.white, disabledBackgroundColor: EstoquePalette.borderSoft, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Cancelar item'))),
              ]),
            ]),
          ),
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
      final lista = await _service.listar(mesaId: _comanda!.mesaId, status: 'ABERTA');
      destinos = lista.where((c) => c.id != null && c.id != _comanda!.id).toList();
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _actionLoading = false);
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível listar comandas da mesa.')));
        setState(() => _actionLoading = false);
      }
      return;
    }
    if (!mounted) return;
    setState(() => _actionLoading = false);

    if (destinos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há outra comanda aberta nesta mesa.')),
      );
      return;
    }

    int? destinoId = destinos.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: EstoquePalette.surface,
          title: const Text('Transferir item', style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w700)),
          content: DropdownButtonFormField<int>(
            initialValue: destinoId,
            decoration: const InputDecoration(labelText: 'Comanda destino', border: OutlineInputBorder()),
            items: destinos
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.codigo.isEmpty ? 'Comanda #${c.id}' : c.codigo),
                    ))
                .toList(),
            onChanged: (value) => setLocal(() => destinoId = value),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
            TextButton(onPressed: destinoId == null ? null : () => Navigator.pop(ctx, true), child: const Text('Transferir')),
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
      backgroundColor: EstoquePalette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _EventosSheet(itemId: item.id!, itemNome: item.produtoNome, acaoLabel: _acaoLabel),
    );
  }
}

class _ItemFormResult {
  const _ItemFormResult({
    required this.produtoId,
    required this.quantidade,
    this.valorDesconto,
    this.valorAcrescimo,
    this.observacao,
  });

  final int produtoId;
  final double quantidade;
  final double? valorDesconto;
  final double? valorAcrescimo;
  final String? observacao;
}

class _ItemFormSheet extends StatefulWidget {
  const _ItemFormSheet({
    required this.titulo,
    this.produtoFixoNome,
    this.quantidadeInicial = 1,
    this.descontoInicial = 0,
    this.acrescimoInicial = 0,
    this.observacaoInicial,
    this.edicao = false,
  });

  final String titulo;
  final String? produtoFixoNome;
  final double quantidadeInicial;
  final double descontoInicial;
  final double acrescimoInicial;
  final String? observacaoInicial;
  final bool edicao;

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _produtoService = ProdutoService();
  final _qtdCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _acresCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  List<Produto> _produtos = const [];
  Produto? _produto;
  bool _loading = true;
  bool _mostrarAjustes = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _qtdCtrl.text = _fmtQtd(widget.quantidadeInicial);
    _descCtrl.text = widget.descontoInicial == 0 ? '' : _fmtMoney(widget.descontoInicial);
    _acresCtrl.text = widget.acrescimoInicial == 0 ? '' : _fmtMoney(widget.acrescimoInicial);
    _obsCtrl.text = widget.observacaoInicial ?? '';
    _mostrarAjustes = widget.descontoInicial > 0 || widget.acrescimoInicial > 0;
    if (widget.edicao) {
      _loading = false;
    } else {
      _carregarProdutos();
    }
  }

  String _fmtMoney(double value) => value.toStringAsFixed(2).replaceAll('.', ',');

  String _formatCurrencyInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final cents = int.tryParse(digits) ?? 0;
    return (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  }

  void _onCurrencyChanged(TextEditingController controller, String value) {
    final formatted = _formatCurrencyInput(value);
    if (formatted == value) return;
    controller.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }

  String _fmtQtd(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString().replaceAll('.', ',');
  }

  double? _parseDecimal(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'[^\d,.]'), '');
    if (cleaned.isEmpty) return null;
    if (cleaned.contains(',') && cleaned.contains('.')) {
      return double.tryParse(cleaned.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.tryParse(cleaned.replaceAll(',', '.'));
  }

  double _qtdAtual() => _parseDecimal(_qtdCtrl.text) ?? 0;

  void _ajustarQtd(double delta) {
    final atual = _qtdAtual();
    final base = atual <= 0 ? 1.0 : atual;
    final nova = (base + delta).clamp(0.001, 9999.0);
    setState(() => _qtdCtrl.text = _fmtQtd(nova));
  }

  InputDecoration _decoration(String label, {String? hint, String? prefix, String? helper}) => InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixText: prefix,
        labelStyle: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: EstoquePalette.textMuted),
        helperStyle: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11),
        filled: true,
        fillColor: EstoquePalette.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.primary, width: 1.5)),
      );

  Widget _fieldLabel(String title, {String? subtitle}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
          ],
        ]),
      );

  Widget _quantidadeStepper() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EstoquePalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
          boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(children: [
          _stepBtn(Icons.remove_rounded, () => _ajustarQtd(-1)),
          Expanded(
            child: TextField(
              controller: _qtdCtrl,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
              style: const TextStyle(color: EstoquePalette.text, fontSize: 22, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintText: '1',
                hintStyle: TextStyle(color: EstoquePalette.textMuted, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          _stepBtn(Icons.add_rounded, () => _ajustarQtd(1)),
        ]),
      );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => Material(
        color: EstoquePalette.inputFill,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EstoquePalette.borderSoft),
            ),
            child: Icon(icon, color: EstoquePalette.primary, size: 22),
          ),
        ),
      );

  Widget _produtoCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EstoquePalette.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.restaurant_rounded, color: EstoquePalette.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.produtoFixoNome ?? 'Item',
              style: const TextStyle(color: EstoquePalette.text, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      );

  @override
  void dispose() {
    _qtdCtrl.dispose();
    _descCtrl.dispose();
    _acresCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    try {
      final lista = await _produtoService.listar(apenasAtivos: true);
      if (!mounted) return;
      setState(() {
        _produtos = lista.whereType<Map>().map((e) => Produto.fromJson(Map<String, dynamic>.from(e))).toList();
        _loading = false;
      });
    } on ApiError catch (e) {
      if (mounted) setState(() { _erro = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _erro = 'Não foi possível carregar produtos.'; _loading = false; });
    }
  }

  Future<void> _selecionarProduto() async {
    final buscaCtrl = TextEditingController();
    final produtoSelecionado = await showModalBottomSheet<Produto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: EstoquePalette.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final termo = buscaCtrl.text.trim().toLowerCase();
          final produtos = _produtos.where((produto) => termo.isEmpty || produto.nome.toLowerCase().contains(termo)).toList();
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: BoxDecoration(color: EstoquePalette.border, borderRadius: BorderRadius.circular(999)))),
              const Text('Escolher produto', style: TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Selecione o produto que será lançado na comanda.', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: buscaCtrl,
                onChanged: (_) => setLocal(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar produto',
                  prefixIcon: const Icon(Icons.search_rounded, color: EstoquePalette.textMuted),
                  filled: true,
                  fillColor: EstoquePalette.surfaceAlt,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: EstoquePalette.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.48,
                child: produtos.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado.', style: TextStyle(color: EstoquePalette.textMuted)))
                    : ListView.separated(
                        itemCount: produtos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final produto = produtos[index];
                          final selecionado = _produto?.id == produto.id;
                          return Material(
                            color: selecionado ? EstoquePalette.inputFill : EstoquePalette.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () => Navigator.pop(ctx, produto),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: selecionado ? EstoquePalette.primary : EstoquePalette.border)),
                                child: Row(children: [
                                  Container(width: 42, height: 42, decoration: BoxDecoration(color: selecionado ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(13)), child: Icon(Icons.restaurant_rounded, color: selecionado ? Colors.white : EstoquePalette.primary)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(produto.nome, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700))),
                                  Icon(selecionado ? Icons.check_circle_rounded : Icons.chevron_right_rounded, color: selecionado ? EstoquePalette.primary : EstoquePalette.textMuted),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          );
        },
      ),
    );
    buscaCtrl.dispose();
    if (!mounted || produtoSelecionado == null) return;
    setState(() {
      _produto = produtoSelecionado;
      _qtdCtrl.text = '1';
    });
  }

  Widget _produtoSelector() {
    final nome = _produto?.nome ?? 'Selecione um produto';
    return Material(
      color: EstoquePalette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _selecionarProduto,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _produto == null ? EstoquePalette.border : EstoquePalette.primary)),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: _produto == null ? EstoquePalette.inputFill : EstoquePalette.primary, borderRadius: BorderRadius.circular(13)), child: Icon(Icons.restaurant_rounded, color: _produto == null ? EstoquePalette.primary : Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Text(nome, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _produto == null ? EstoquePalette.textMuted : EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700))),
            const Icon(Icons.touch_app_rounded, color: EstoquePalette.textMuted, size: 20),
          ]),
        ),
      ),
    );
  }

  void _salvar() {
    final qtd = _parseDecimal(_qtdCtrl.text);
    if (!widget.edicao && (_produto?.id == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um produto.')));
      return;
    }
    if (qtd == null || qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe uma quantidade válida.')));
      return;
    }
    Navigator.pop(
      context,
      _ItemFormResult(
        produtoId: _produto?.id ?? 0,
        quantidade: qtd,
        valorDesconto: _parseDecimal(_descCtrl.text),
        valorAcrescimo: _parseDecimal(_acresCtrl.text),
        observacao: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: EstoquePalette.border, borderRadius: BorderRadius.circular(999)),
          ),
        ),
        Text(widget.titulo, style: const TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          widget.edicao ? 'Altere os dados do item' : 'Escolha o produto e a quantidade',
          style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: EstoquePalette.primary)))
        else if (_erro != null)
          Text(_erro!, textAlign: TextAlign.center, style: const TextStyle(color: EstoquePalette.error))
        else ...[
          if (widget.edicao)
            _produtoCard()
          else ...[
            _fieldLabel('Produto', subtitle: 'Obrigatório'),
            _produtoSelector(),
          ],
          const SizedBox(height: 20),
          _fieldLabel('Quantidade', subtitle: 'Toque nos botões ou digite o valor'),
          _quantidadeStepper(),
          const SizedBox(height: 20),
          _fieldLabel('Observação', subtitle: 'Opcional'),
          TextField(
            controller: _obsCtrl,
            maxLines: 2,
            style: const TextStyle(color: EstoquePalette.text, fontSize: 15),
            decoration: _decoration('Observação', hint: 'Ex.: sem gelo, ponto da carne…').copyWith(labelText: null, floatingLabelBehavior: FloatingLabelBehavior.never),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: EstoquePalette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: EstoquePalette.border),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: _mostrarAjustes,
                tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                iconColor: EstoquePalette.primary,
                collapsedIconColor: EstoquePalette.textMuted,
                title: const Text(
                  'Ajuste de valor',
                  style: TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Desconto abate · acréscimo soma',
                  style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12),
                ),
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _descCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                        onChanged: (value) => _onCurrencyChanged(_descCtrl, value),
                        style: const TextStyle(color: EstoquePalette.text, fontSize: 15),
                        decoration: _decoration('Desconto', prefix: 'R\$ ', hint: '0,00', helper: 'Valor a menos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _acresCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                        onChanged: (value) => _onCurrencyChanged(_acresCtrl, value),
                        style: const TextStyle(color: EstoquePalette.text, fontSize: 15),
                        decoration: _decoration('Acréscimo', prefix: 'R\$ ', hint: '0,00', helper: 'Valor a mais'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: EstoquePalette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.edicao ? 'Salvar alterações' : 'Adicionar à comanda', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
        ]),
      ),
    );
  }
}

class _EventosSheet extends StatefulWidget {
  const _EventosSheet({required this.itemId, required this.itemNome, required this.acaoLabel});

  final int itemId;
  final String itemNome;
  final String Function(String) acaoLabel;

  @override
  State<_EventosSheet> createState() => _EventosSheetState();
}

class _EventosSheetState extends State<_EventosSheet> {
  final _service = ItemComandaService();
  bool _loading = true;
  String? _erro;
  List<EventoItemComandaResponse> _eventos = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lista = await _service.listarEventos(widget.itemId);
      if (!mounted) return;
      setState(() {
        _eventos = lista;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (mounted) setState(() { _erro = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _erro = 'Não foi possível carregar os eventos.'; _loading = false; });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  String _formatEventValue(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 140) return compact;
    return '${compact.substring(0, 137)}...';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Eventos — ${widget.itemNome}', style: const TextStyle(color: EstoquePalette.text, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Linha do tempo de auditoria', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: EstoquePalette.primary))
                : _erro != null
                    ? Center(child: Text(_erro!, textAlign: TextAlign.center, style: const TextStyle(color: EstoquePalette.error)))
                    : _eventos.isEmpty
                        ? const Center(child: Text('Nenhum evento registrado.', style: TextStyle(color: EstoquePalette.textMuted)))
                        : ListView.separated(
                            controller: controller,
                            itemCount: _eventos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final e = _eventos[i];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: EstoquePalette.inputFill,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: EstoquePalette.border),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    AppTag(widget.acaoLabel(e.acao), fundo: EstoquePalette.primary.withValues(alpha: 0.12), cor: EstoquePalette.primary),
                                    const Spacer(),
                                    Text(_formatDate(e.dataHora), style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
                                  ]),
                                  const SizedBox(height: 8),
                                  Text(
                                    e.usuarioNome ?? e.usuarioLogin ?? 'Usuário',
                                    style: const TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (e.motivo?.isNotEmpty == true) ...[
                                    const SizedBox(height: 4),
                                    Text('Motivo: ${_motivosCancelamento[e.motivo!] ?? e.motivo}', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
                                  ],
                                  if (_formatEventValue(e.valorAntes).isNotEmpty == true) ...[
                                    const SizedBox(height: 6),
                                    Text('Dados anteriores: ${_formatEventValue(e.valorAntes)}', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
                                  ],
                                  if (_formatEventValue(e.valorDepois).isNotEmpty == true) ...[
                                    const SizedBox(height: 2),
                                    Text('Dados atuais: ${_formatEventValue(e.valorDepois)}', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
                                  ],
                                ]),
                              );
                            },
                          ),
          ),
        ]),
      ),
    );
  }
}
