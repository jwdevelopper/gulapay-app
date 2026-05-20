import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';

class _ChoiceOption {
  final String label;
  final String description;
  final String value;
  final IconData icon;
  const _ChoiceOption({required this.label, required this.description, required this.value, required this.icon});
}

const List<_ChoiceOption> _tipoOptions = [
  _ChoiceOption(label: 'Compra', description: 'Entrada de fornecedor', value: 'ENTRADA_COMPRA', icon: Icons.shopping_cart_rounded),
  _ChoiceOption(label: 'Perda validade', description: 'Insumo vencido', value: 'SAIDA_PERDA_VALIDADE', icon: Icons.timer_off_rounded),
  _ChoiceOption(label: 'Perda quebra', description: 'Quebra/avaria', value: 'SAIDA_PERDA_QUEBRA', icon: Icons.broken_image_rounded),
  _ChoiceOption(label: 'Troca', description: 'Entrada por troca', value: 'ENTRADA_TROCA', icon: Icons.swap_horiz_rounded),
  _ChoiceOption(label: 'Ajuste de inventário', description: 'Corrige saldo pós-contagem física', value: 'AJUSTE_INVENTARIO', icon: Icons.tune_rounded),
];

class MovimentacaoFormPage extends StatefulWidget {
  const MovimentacaoFormPage({super.key});
  @override
  State<MovimentacaoFormPage> createState() => _MovimentacaoFormPageState();
}

class _MovimentacaoFormPageState extends State<MovimentacaoFormPage> {
  final _service = MovimentacaoEstoqueService();
  final _quantidade = TextEditingController();
  final _custoUnitario = TextEditingController();
  final _codigoLote = TextEditingController();
  final _justificativa = TextEditingController();
  final _validade = TextEditingController();

  List<Insumo> _insumos = [];
  List<Lote> _lotes = [];
  List<UnidadeMedida> _unidades = [];
  String? _selectedTipo;
  Insumo? _selectedInsumo;
  Lote? _selectedLote;
  UnidadeMedida? _selectedUnidade;
  bool _saving = false;
  bool _success = false;
  int _step = 0;
  String? _validationMessage;
  bool _tipoError = false;
  bool _insumoError = false;
  bool _quantidadeError = false;
  bool _unidadeError = false;

  @override
  void initState() {
    super.initState();
    _loadInsumos();
    _loadUnidades();
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _custoUnitario.dispose();
    _codigoLote.dispose();
    _justificativa.dispose();
    _validade.dispose();
    super.dispose();
  }

  bool get _isEntrada => _selectedTipo == 'ENTRADA_COMPRA' || _selectedTipo == 'ENTRADA_TROCA';

  String get _stepLabel {
    switch (_step) {
      case 0: return 'Tipo';
      case 1: return 'Insumo & quantidade';
      default: return 'Lote & detalhes';
    }
  }

  String get _tipoLabel {
    for (final o in _tipoOptions) {
      if (o.value == _selectedTipo) return o.label;
    }
    return 'Nova movimentação';
  }

  String get _headerTitle {
    if (_step == 0) return 'Nova movimentação';
    return _tipoLabel;
  }

  Future<void> _loadInsumos() async {
    try {
      final list = await _service.listarInsumos(apenasAtivos: false);
      if (!mounted) return;
      setState(() => _insumos = list.map((e) => Insumo.fromJson(Map<String, dynamic>.from(e as Map))).toList());
    } catch (_) {}
  }

  Future<void> _loadUnidades() async {
    try {
      final list = await _service.listarUnidades();
      if (!mounted) return;
      setState(() => _unidades = list.map((e) => UnidadeMedida.fromJson(Map<String, dynamic>.from(e as Map))).toList());
    } catch (_) {}
  }

  Future<void> _loadLotes(int insumoId) async {
    try {
      final list = await _service.listarLotes(insumoId);
      if (!mounted) return;
      setState(() => _lotes = list.map((e) => Lote.fromJson(Map<String, dynamic>.from(e as Map))).toList());
    } catch (_) {}
  }

  double _parseQty() => double.tryParse(_quantidade.text.replaceAll(',', '.')) ?? 0;
  double _parseCusto() => double.tryParse(_custoUnitario.text.replaceAll(',', '.')) ?? 0;

  void _clearValidation() {
    _tipoError = false;
    _insumoError = false;
    _quantidadeError = false;
    _unidadeError = false;
    _validationMessage = null;
  }

  bool _validateStep() {
    setState(_clearValidation);
    if (_step == 0) {
      if (_selectedTipo == null) {
        setState(() { _tipoError = true; _validationMessage = 'Selecione o tipo de movimentação.'; });
        return false;
      }
      return true;
    }
    if (_step == 1) {
      var errors = 0;
      if (_selectedInsumo == null) { _insumoError = true; errors++; }
      if (_parseQty() <= 0) { _quantidadeError = true; errors++; }
      if (_selectedUnidade == null) { _unidadeError = true; errors++; }
      if (errors > 0) {
        setState(() => _validationMessage = '$errors campo(s) obrigatório(s).');
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> _next() async {
    if (!_validateStep()) return;
    if (_step == 1 && _selectedInsumo?.id != null) {
      await _loadLotes(_selectedInsumo!.id!);
    }
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await _submit();
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'tipo': _selectedTipo,
      'insumoId': _selectedInsumo?.id,
      'unidadeId': _selectedUnidade?.id,
      'quantidade': _parseQty(),
    };
    if (_selectedLote != null) payload['loteId'] = _selectedLote!.id;
    if (_parseCusto() > 0) payload['custoUnitario'] = _parseCusto();
    if (_validade.text.trim().isNotEmpty) payload['validade'] = _validade.text.trim();
    if (_codigoLote.text.trim().isNotEmpty) payload['codigoLote'] = _codigoLote.text.trim();
    if (_justificativa.text.trim().isNotEmpty) payload['justificativa'] = _justificativa.text.trim();

    try {
      await _service.criarMovimentacao(payload);
      if (!mounted) return;
      setState(() => _success = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openInsumoSelector() {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.72,
        child: Container(
          decoration: const BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SafeArea(top: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: EstoquePalette.borderSoft, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Text('Escolher insumo', style: TextStyle(color: EstoquePalette.text, fontSize: 18, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded), color: EstoquePalette.text),
              ]),
              const SizedBox(height: 8),
              Expanded(child: _insumos.isEmpty
                ? const Center(child: Text('Sem insumos cadastrados', style: TextStyle(color: EstoquePalette.text, fontSize: 16, fontWeight: FontWeight.w700)))
                : ListView.separated(
                    itemCount: _insumos.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final insumo = _insumos[index];
                      final selected = insumo.id == _selectedInsumo?.id;
                      return InkWell(
                        onTap: () { setState(() { _selectedInsumo = insumo; _insumoError = false; _validationMessage = null;
                          if (insumo.unidadePadraoId != null) {
                            for (final u in _unidades) { if (u.id == insumo.unidadePadraoId) { _selectedUnidade = u; break; } }
                          }
                        }); Navigator.pop(ctx); },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected ? EstoquePalette.warningBg : EstoquePalette.surfaceAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border)),
                          child: Row(children: [
                            Container(width: 40, height: 40,
                              decoration: BoxDecoration(color: selected ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(14)),
                              child: Icon(Icons.inventory_2_rounded, color: selected ? Colors.white : EstoquePalette.primary, size: 20)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(insumo.nome, style: const TextStyle(color: EstoquePalette.text, fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Saldo atual: ${insumo.estoqueAtual?.toStringAsFixed(1) ?? '0'} ${insumo.unidadePadraoSimbolo ?? ''}',
                                style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
                            ])),
                            if (selected) const Icon(Icons.check_rounded, color: EstoquePalette.primary) else const SizedBox(width: 18),
                          ])));
                    })),
            ]),
          )),
        ),
      ),
    );
  }

  void _openUnidadeSelector() {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.55,
        child: Container(
          decoration: const BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SafeArea(top: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: EstoquePalette.borderSoft, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Text('Unidade de medida', style: TextStyle(color: EstoquePalette.text, fontSize: 18, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded), color: EstoquePalette.text),
              ]),
              const SizedBox(height: 8),
              Expanded(child: ListView.separated(
                itemCount: _unidades.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final u = _unidades[index];
                  final selected = u.id == _selectedUnidade?.id;
                  return InkWell(
                    onTap: () { setState(() { _selectedUnidade = u; _unidadeError = false; _validationMessage = null; }); Navigator.pop(ctx); },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? EstoquePalette.warningBg : EstoquePalette.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border)),
                      child: Row(children: [
                        Text(u.simbolo ?? u.nome, style: TextStyle(color: selected ? EstoquePalette.primary : EstoquePalette.text, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 14),
                        Expanded(child: Text(u.nome, style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w600))),
                        if (selected) const Icon(Icons.check_rounded, color: EstoquePalette.primary),
                      ])));
                })),
            ]),
          )),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FormHeaderIconButton(icon: Icons.arrow_back_rounded, onTap: () {
          if (_step == 0) {
            Navigator.pop(context);
          } else {
            _prev();
          }
        }),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_headerTitle, style: const TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
          const SizedBox(height: 2),
          Text('Etapa ${_step + 1} de 3 · $_stepLabel', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
        ])),
      ]));
  }

  Widget _buildProgress() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: List.generate(3, (i) => Expanded(
        child: Container(height: 4, margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
          decoration: BoxDecoration(color: i <= _step ? EstoquePalette.primary : EstoquePalette.borderSoft, borderRadius: BorderRadius.circular(999)))))));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required ValueChanged<String> onChanged,
    int maxLines = 1, TextInputType keyboardType = TextInputType.text, bool error = false, bool price = false, bool largeText = false, String? suffix}) {
    final big = price || largeText;
    return Container(
      decoration: BoxDecoration(color: EstoquePalette.surfaceAlt, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: error ? EstoquePalette.error : EstoquePalette.border),
        boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))]),
      child: TextField(controller: controller, onChanged: onChanged, maxLines: maxLines, keyboardType: keyboardType,
        style: TextStyle(color: EstoquePalette.text, fontSize: big ? 28 : 15, fontWeight: big ? FontWeight.w700 : FontWeight.w500),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: EstoquePalette.textMuted),
          prefixText: price ? 'R\$ ' : null,
          prefixStyle: const TextStyle(color: EstoquePalette.textMuted, fontSize: 20, fontWeight: FontWeight.w700),
          suffixText: suffix, suffixStyle: const TextStyle(color: EstoquePalette.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
          border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: big ? 20 : 16))));
  }

  Widget _buildErrorBanner() {
    if (_validationMessage == null) return const SizedBox.shrink();
    return Container(width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: EstoquePalette.warningBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.error)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.warning_amber_rounded, color: EstoquePalette.error, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(_validationMessage!, style: const TextStyle(color: EstoquePalette.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35))),
      ]));
  }

  Widget _buildInfoCard(String text) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: EstoquePalette.warningBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.warningBorder)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.lightbulb_outline_rounded, color: EstoquePalette.primary, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: EstoquePalette.text, fontSize: 12, height: 1.35, fontWeight: FontWeight.w500))),
      ]));
  }

  Widget _buildTypeOption(_ChoiceOption option) {
    final selected = _selectedTipo == option.value;
    return InkWell(onTap: () => setState(() { _selectedTipo = option.value; _tipoError = false; _validationMessage = null; }),
      borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: selected ? EstoquePalette.warningBg : EstoquePalette.surfaceAlt, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 34, height: 34,
              decoration: BoxDecoration(color: selected ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(12)),
              child: Icon(option.icon, color: selected ? Colors.white : EstoquePalette.primary, size: 18)),
            const Spacer(),
            if (selected) const Icon(Icons.check_circle_rounded, color: EstoquePalette.primary, size: 18),
          ]),
          const SizedBox(height: 14),
          Text(option.label, style: const TextStyle(color: EstoquePalette.text, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(option.description, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11, height: 1.2)),
        ])));
  }

  Widget _buildStep0() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tipo de movimentação *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      GridView.count(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.25,
        children: _tipoOptions.map(_buildTypeOption).toList()),
      if (_selectedTipo == 'SAIDA_PERDA_VALIDADE') ...[
        const SizedBox(height: 16),
        _buildInfoCard('Perda por validade exige que você selecione qual lote venceu na próxima etapa.'),
      ],
      const SizedBox(height: 16),
      if (_tipoError) ...[const SizedBox(height: 4)],
      _buildErrorBanner(),
    ]);
  }

  Widget _buildInsumoSelector() {
    final has = _selectedInsumo != null;
    return InkWell(onTap: _openInsumoSelector, borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: EstoquePalette.surfaceAlt, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _insumoError ? EstoquePalette.error : EstoquePalette.border),
          boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))]),
        child: Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: has ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.inventory_2_rounded, color: has ? Colors.white : EstoquePalette.primary, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Insumo *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(has ? _selectedInsumo!.nome : 'Selecione o insumo',
              style: TextStyle(color: has ? EstoquePalette.text : EstoquePalette.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
            if (has) Text('Saldo atual: ${_selectedInsumo!.estoqueAtual?.toStringAsFixed(1) ?? '0'} ${_selectedInsumo!.unidadePadraoSimbolo ?? ''}',
              style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: EstoquePalette.textMuted),
        ])));
  }

  Widget _buildUnidadeSelector() {
    final has = _selectedUnidade != null;
    return InkWell(onTap: _openUnidadeSelector, borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: EstoquePalette.surfaceAlt, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _unidadeError ? EstoquePalette.error : EstoquePalette.border)),
        child: Row(children: [
          Text(has ? (_selectedUnidade!.simbolo ?? _selectedUnidade!.nome) : 'Unidade',
            style: TextStyle(color: has ? EstoquePalette.text : EstoquePalette.textMuted, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more_rounded, color: EstoquePalette.textMuted, size: 20),
        ])));
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildInsumoSelector(),
      if (_insumoError) ...[const SizedBox(height: 6), const Text('Selecione um insumo.', style: TextStyle(color: EstoquePalette.error, fontSize: 11, fontWeight: FontWeight.w600))],
      const SizedBox(height: 16),
      const Text('Quantidade *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _buildTextField(controller: _quantidade, hint: '0', onChanged: (_) { if (_quantidadeError) setState(() { _quantidadeError = false; _validationMessage = null; }); },
          keyboardType: const TextInputType.numberWithOptions(decimal: true), largeText: true, error: _quantidadeError)),
        const SizedBox(width: 10),
        _buildUnidadeSelector(),
      ]),
      if (_quantidadeError) ...[const SizedBox(height: 6), const Text('Informe a quantidade.', style: TextStyle(color: EstoquePalette.error, fontSize: 11, fontWeight: FontWeight.w600))],
      const SizedBox(height: 16),
      _buildErrorBanner(),
    ]);
  }

  Widget _buildLoteSelector() {
    if (_lotes.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Lote a baixar *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('Ordenado por validade (FEFO)', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: 8),
      ..._lotes.map((lote) {
        final selected = _selectedLote?.id == lote.id;
        final vencido = lote.isVencido;
        return Padding(padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(onTap: () => setState(() => _selectedLote = lote), borderRadius: BorderRadius.circular(16),
            child: Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: selected ? EstoquePalette.warningBg : EstoquePalette.surfaceAlt,
                borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(lote.codigo ?? 'L${lote.id}', style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
                    if (vencido) ...[const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: EstoquePalette.error, borderRadius: BorderRadius.circular(4)),
                        child: const Text('VENCIDO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))],
                  ]),
                  const SizedBox(height: 4),
                  Text('${lote.quantidadeRestante?.toStringAsFixed(1) ?? '0'} ${lote.unidadePadraoSimbolo ?? ''} restantes · custo R\$ ${lote.custoUnitario?.toStringAsFixed(2).replaceAll('.', ',') ?? '0'}',
                    style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
                ])),
                if (selected) const Icon(Icons.check_circle_rounded, color: EstoquePalette.primary, size: 20)
                  else const Icon(Icons.radio_button_unchecked_rounded, color: EstoquePalette.border, size: 20),
              ]))));
      }),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!_isEntrada) ...[_buildLoteSelector(), const SizedBox(height: 16)],
      if (_isEntrada) ...[
        const Text('Validade *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildTextField(controller: _validade, hint: '2026-12-31', onChanged: (_) {}, keyboardType: TextInputType.datetime),
        const SizedBox(height: 16),
        const Text('Custo unitário *', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildTextField(controller: _custoUnitario, hint: '0,00', onChanged: (_) {},
          keyboardType: const TextInputType.numberWithOptions(decimal: true), price: true),
        const SizedBox(height: 16),
        const Text('Código do lote', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildTextField(controller: _codigoLote, hint: 'Ex.: NF-8821', onChanged: (_) {}),
        const SizedBox(height: 16),
        _buildInfoCard('Novo lote será criado com a validade e custo informados.'),
        const SizedBox(height: 16),
      ],
      const Text('Observação opcional', style: TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      _buildTextField(controller: _justificativa, hint: 'Motivo ou observação...', onChanged: (_) {}, maxLines: 3),
      const SizedBox(height: 16),
      _buildSummary(),
    ]);
  }

  Widget _buildSummary() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EstoquePalette.borderSoft),
        boxShadow: const [BoxShadow(color: EstoquePalette.shadow, blurRadius: 12, offset: Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('RESUMO', style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
        const SizedBox(height: 12),
        _SummaryRow(label: 'Tipo', value: _tipoLabel),
        const Divider(height: 18, color: EstoquePalette.borderSoft),
        _SummaryRow(label: 'Insumo', value: _selectedInsumo?.nome ?? '-'),
        const Divider(height: 18, color: EstoquePalette.borderSoft),
        _SummaryRow(label: 'Quantidade', value: '${_quantidade.text.isEmpty ? '0' : _quantidade.text} ${_selectedUnidade?.simbolo ?? ''}'),
        if (_selectedLote != null) ...[
          const Divider(height: 18, color: EstoquePalette.borderSoft),
          _SummaryRow(label: 'Lote', value: _selectedLote!.codigo ?? '#${_selectedLote!.id}'),
        ],
        if (_parseCusto() > 0) ...[
          const Divider(height: 18, color: EstoquePalette.borderSoft),
          _SummaryRow(label: 'Custo unitário', value: 'R\$ ${_parseCusto().toStringAsFixed(2).replaceAll('.', ',')}'),
        ],
      ]));
  }

  Widget _buildSuccessScreen() {
    return Scaffold(backgroundColor: EstoquePalette.background,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(),
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: EstoquePalette.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 44)),
          const SizedBox(height: 24),
          const Text('Movimentação registrada!', style: TextStyle(color: EstoquePalette.text, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildSummary(),
          const Spacer(),
          SafeArea(top: false, child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, backgroundColor: EstoquePalette.surfaceAlt,
                side: const BorderSide(color: EstoquePalette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Voltar'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.primary, foregroundColor: Colors.white,
                elevation: 4, shadowColor: EstoquePalette.primaryPressed.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.check_rounded, size: 18), label: const Text('Concluído'))),
          ])),
        ]))));
  }

  Widget _buildBottomButtons() {
    final leftLabel = _step == 0 ? 'Cancelar' : 'Voltar';
    String rightLabel;
    if (_step == 2) {
      if (_isEntrada) { rightLabel = 'Registrar compra'; }
      else { rightLabel = 'Registrar saída'; }
    } else { rightLabel = 'Continuar'; }

    return SafeArea(top: false,
      child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: _step == 0 ? () => Navigator.pop(context) : _prev,
            style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, backgroundColor: EstoquePalette.surfaceAlt,
              side: const BorderSide(color: EstoquePalette.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(leftLabel))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _saving ? null : _next,
            style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.primary, foregroundColor: Colors.white,
              disabledBackgroundColor: EstoquePalette.primarySoft.withValues(alpha: 0.55),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
              elevation: 4, shadowColor: EstoquePalette.primaryPressed.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(rightLabel),
                  if (_step < 2) ...[const SizedBox(width: 8), const Icon(Icons.chevron_right_rounded, size: 18)],
                  if (_step == 2) ...[const SizedBox(width: 8), const Icon(Icons.check_rounded, size: 18)],
                ]))),
        ])));
  }

  Widget _buildStepBody() {
    switch (_step) {
      case 0: return _buildStep0();
      case 1: return _buildStep1();
      default: return _buildStep2();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccessScreen();
    return Scaffold(backgroundColor: EstoquePalette.background,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        _buildProgress(),
        const SizedBox(height: 12),
        Expanded(child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: _buildStepBody())),
        _buildBottomButtons(),
      ])));
  }
}

class _FormHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _FormHeaderIconButton({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(16),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Container(width: 44, height: 44,
          decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EstoquePalette.border)),
          child: Icon(icon, color: EstoquePalette.text, size: 22))));
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(width: 12),
      Flexible(child: Text(value, textAlign: TextAlign.right,
        style: const TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700))),
    ]);
  }
}

