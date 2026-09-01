import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/comanda_response.dart';
import '../service/comanda_service.dart';
import 'comanda_detalhe_page.dart';
import 'comanda_form_page.dart';

class ComandasPage extends StatefulWidget {
  const ComandasPage({super.key});
  @override State<ComandasPage> createState() => _ComandasPageState();
}

class _ComandasPageState extends State<ComandasPage> {
  final _service = ComandaService();
  List<ComandaResponse> _comandas = [];
  String? _status;
  String? _tipo;
  bool _loading = true;
  String? _erro;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _erro = null; });
    try { _comandas = await _service.listar(status: _status, tipoOrigem: _tipo); }
    on ApiError catch (e) { _erro = e.message; }
    catch (_) { _erro = 'Não foi possível carregar as comandas.'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _new() async { if (await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const ComandaFormPage())) == true) _load(); }
  String _money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  Color _statusColor(String status) => switch (status) { 'FECHADA' => EstoquePalette.success, 'CANCELADA' => EstoquePalette.error, 'AGUARDANDO_PAGAMENTO' => Colors.orange, _ => EstoquePalette.primary };

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: EstoquePalette.background,
    floatingActionButton: FloatingActionButton(
      onPressed: _new,
      backgroundColor: EstoquePalette.primary,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(width: 44, height: 44),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Comandas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.05, color: EstoquePalette.text)),
          SizedBox(height: 2),
          Text('Acompanhe as vendas abertas e finalizadas', style: TextStyle(fontSize: 12, height: 1.15, color: EstoquePalette.textMuted)),
        ])),
        IconButton(onPressed: _load, color: EstoquePalette.text, icon: const Icon(Icons.refresh_rounded)),
      ])),
      _filters(),
      Expanded(child: RefreshIndicator(onRefresh: _load, color: EstoquePalette.primary, child: _body())),
    ])),
  );

  Widget _filters() => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
    _chip('Todas', _status == null, () { setState(() => _status = null); _load(); }),
    for (final value in ['ABERTA', 'AGUARDANDO_PAGAMENTO', 'FECHADA', 'CANCELADA']) _chip(value, _status == value, () { setState(() => _status = value); _load(); }),
    const SizedBox(width: 4),
    for (final value in ['MESA', 'BALCAO', 'DELIVERY']) _chip(value, _tipo == value, () { setState(() => _tipo = _tipo == value ? null : value); _load(); }),
  ]));
  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? EstoquePalette.primary : EstoquePalette.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border),
            ),
            child: Text(label.replaceAll('_', ' '), style: TextStyle(color: selected ? Colors.white : EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      );
  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: EstoquePalette.primary));
    if (_erro != null) return ListView(children: [const SizedBox(height: 100), Center(child: Text(_erro!, style: TextStyle(color: EstoquePalette.text))), Center(child: TextButton(onPressed: _load, style: TextButton.styleFrom(foregroundColor: EstoquePalette.primary), child: const Text('Tentar novamente')))]);
    if (_comandas.isEmpty) return ListView(children: const [SizedBox(height: 80), Center(child: Icon(Icons.receipt_long_outlined, size: 48, color: EstoquePalette.primary)), SizedBox(height: 14), Center(child: Text('Nenhuma comanda encontrada.', style: TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w600)))]);
    return ListView.separated(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), itemCount: _comandas.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
      final c = _comandas[i];
      return Card(color: EstoquePalette.surface, elevation: 0, shadowColor: EstoquePalette.shadow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: EstoquePalette.border)), child: ListTile(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ComandaDetalhePage(id: c.id!))); _load(); }, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(14)), child: Icon(c.tipoOrigem == 'MESA' ? Icons.table_restaurant : c.tipoOrigem == 'DELIVERY' ? Icons.delivery_dining : Icons.point_of_sale, color: EstoquePalette.primary)), title: Text(c.codigo.isEmpty ? 'Comanda #${c.id}' : c.codigo, style: const TextStyle(fontWeight: FontWeight.w700, color: EstoquePalette.text)), subtitle: Text([c.tipoOrigem, if (c.clienteNome != null) c.clienteNome!, if (c.mesaNumero != null) 'Mesa ${c.mesaNumero}'].join(' • '), style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_money(c.totalLiquido), style: const TextStyle(fontWeight: FontWeight.w700, color: EstoquePalette.text)), Text(c.status.replaceAll('_', ' '), style: TextStyle(fontSize: 11, color: _statusColor(c.status), fontWeight: FontWeight.w700))])));
    });
  }
}
