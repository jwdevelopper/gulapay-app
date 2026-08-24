import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/comanda_response.dart';
import '../service/comanda_service.dart';

class ComandaDetalhePage extends StatefulWidget {
  const ComandaDetalhePage({super.key, required this.id});

  final int id;

  @override
  State<ComandaDetalhePage> createState() => _ComandaDetalhePageState();
}

class _ComandaDetalhePageState extends State<ComandaDetalhePage> {
  final _service = ComandaService();
  ComandaResponse? _comanda;
  String? _perfil;
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
      ]);
      if (!mounted) return;
      setState(() {
        _comanda = result[0] as ComandaResponse;
        _perfil = result[1] as String?;
        _loading = false;
        _erro = null;
      });
    } on ApiError catch (e) {
      if (mounted) setState(() { _erro = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _erro = 'Não foi possível carregar a comanda.'; _loading = false; });
    }
  }

  bool get _admin => _perfil == 'ADMINISTRADOR';
  bool get _caixa => _admin || _perfil == 'CAIXA';

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
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
                  _sectionTitle('ITENS DA COMANDA'),
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
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('Copiar link WhatsApp'),
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

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5));

  Widget _emptyItems() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: EstoquePalette.border)),
        child: const Column(children: [
          Icon(Icons.receipt_long_outlined, size: 36, color: EstoquePalette.primary),
          SizedBox(height: 10),
          Text('Nenhum item lançado nesta comanda.', textAlign: TextAlign.center, style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _itemCard(ItemComandaResponse item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.border)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.restaurant_rounded, color: EstoquePalette.primary, size: 21)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.produtoNome, style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('${item.quantidade} × ${_money(item.precoUnitario)}', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
            ])),
            Text(_money(item.total), style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        ),
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
        decoration: const BoxDecoration(color: EstoquePalette.surface, border: Border(top: BorderSide(color: EstoquePalette.borderSoft))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_caixa && active)
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _actionLoading ? null : () => _action('cancelar'), icon: const Icon(Icons.cancel_outlined, size: 18), label: const Text('Cancelar'), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.error, side: const BorderSide(color: EstoquePalette.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: _actionLoading ? null : () => _action('fechar'), icon: const Icon(Icons.check_circle_outline_rounded, size: 18), label: const Text('Fechar'), style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
            ]),
          if (_admin && c.status == 'FECHADA')
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _actionLoading ? null : () => _action('reabrir'), icon: const Icon(Icons.lock_open_rounded, size: 18), label: const Text('Reabrir comanda'), style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, side: const BorderSide(color: EstoquePalette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 15)))),
        ]),
      ),
    );
  }
}
