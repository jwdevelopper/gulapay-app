import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import 'package:my_app_teste/modules/mesa/dto/mesa_dto.dart';
import 'package:my_app_teste/modules/mesa/service/mesa_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';
import '../dto/comanda_create_request.dart';
import '../service/comanda_service.dart';

class ComandaFormPage extends StatefulWidget {
  const ComandaFormPage({super.key});
  @override State<ComandaFormPage> createState() => _ComandaFormPageState();
}

class _CanalOption {
  const _CanalOption({required this.label, required this.description, required this.value, required this.icon});
  final String label;
  final String description;
  final String value;
  final IconData icon;
}

const _canalOptions = [
  _CanalOption(label: 'Mesa', description: 'Venda realizada no salão', value: 'MESA', icon: Icons.table_restaurant_rounded),
  _CanalOption(label: 'Balcão', description: 'Venda rápida no atendimento', value: 'BALCAO', icon: Icons.storefront_rounded),
  _CanalOption(label: 'Delivery', description: 'Entrega no endereço do cliente', value: 'DELIVERY', icon: Icons.delivery_dining_rounded),
];

class _ComandaFormPageState extends State<ComandaFormPage> {
  final _service = ComandaService();
  final _observacao = TextEditingController();
  int _step = 0;
  String _tipo = 'MESA';
  String _escopo = 'INDIVIDUAL';
  int? _mesaId;
  int? _garcomId;
  ClienteResponse? _cliente;
  List<MesaDto> _mesas = [];
  List<ClienteResponse> _clientes = [];
  List<UsuarioResposta> _garcons = [];
  bool _saving = false;
  String? _validationMessage;

  @override void initState() { super.initState(); _loadOptions(); }
  @override void dispose() { _observacao.dispose(); super.dispose(); }

  String get _stepLabel => ['Canal da venda', 'Cliente', 'Dados da venda', 'Revisão'][_step];

  Future<void> _loadOptions() async {
    try {
      final result = await Future.wait([
        MesaService().listarMesas(),
        listarClientes(apenasAtivos: false),
        UsuarioServico().listar(perfil: 'GARCOM'),
      ]);
      if (!mounted) return;
      setState(() {
        _mesas = result[0] as List<MesaDto>;
        _clientes = result[1] as List<ClienteResponse>;
        _garcons = (result[2] as List<UsuarioResposta>)
            .where((usuario) => usuario.ativo != false && usuario.id != null)
            .toList();
      });
    } catch (_) {}
  }

  bool _validateStep() {
    String? error;
    if (_step == 1) {
      if (_cliente?.id == null) error = 'Selecione o cliente da comanda.';
    }
    if (_step == 2) {
      if (_tipo == 'MESA' && _mesaId == null) error = 'Selecione a mesa da comanda.';
      if (_tipo == 'MESA' && _garcomId == null) error = 'Selecione o garçom responsável pela comanda.';
      if (_tipo == 'DELIVERY' && (_cliente?.id == null || _cliente?.endereco?.id == null)) error = 'Selecione um cliente com endereço cadastrado.';
    }
    setState(() => _validationMessage = error);
    return error == null;
  }

  void _next() { if (!_validateStep()) return; if (_step < 3) { setState(() => _step++); } else { _save(); } }
  void _previous() { if (_step > 0) { setState(() => _step--); } else { Navigator.pop(context); } }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.criar(ComandaCreateRequest(tipoOrigem: _tipo, escopo: _tipo == 'MESA' ? _escopo : 'INDIVIDUAL', mesaId: _mesaId, garcomId: _tipo == 'MESA' ? _garcomId : null, clienteId: _cliente?.id, enderecoEntregaId: _tipo == 'DELIVERY' ? _cliente?.endereco?.id : null, observacao: _observacao.text));
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) { _showMessage(e.message); }
    catch (_) { _showMessage('Não foi possível abrir a comanda.'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: EstoquePalette.background,
        body: SafeArea(child: Column(children: [
          _header(), _progress(), const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: _stepBody())),
          _bottomButtons(),
        ])),
      );

  Widget _header() => Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _iconButton(Icons.arrow_back_rounded, _previous), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nova comanda', style: TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w700, height: 1.05)),
          const SizedBox(height: 2), Text('Etapa ${_step + 1} de 4 • $_stepLabel', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
        ])),
      ]));

  Widget _iconButton(IconData icon, VoidCallback onTap) => Material(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.border)), child: Icon(icon, color: EstoquePalette.text))));
  Widget _progress() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: List.generate(4, (index) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: index == 3 ? 0 : 8), decoration: BoxDecoration(color: index <= _step ? EstoquePalette.primary : EstoquePalette.borderSoft, borderRadius: BorderRadius.circular(999)))))));

  Widget _stepBody() { switch (_step) { case 0: return _canalStep(); case 1: return _clienteStep(); case 2: return _dadosStep(); default: return _revisaoStep(); } }
  Widget _title(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: EstoquePalette.text, fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13, height: 1.35))]);
  Widget _label(String label) => Text(label, style: const TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _canalStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_title('Como será esta venda?', 'Escolha o canal para configurar os próximos dados.'), const SizedBox(height: 18), ..._canalOptions.map(_canalCard), const SizedBox(height: 8), _infoCard('O canal define quais informações serão obrigatórias para abrir a comanda.')]);
  Widget _canalCard(_CanalOption option) { final selected = option.value == _tipo; return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => setState(() { _tipo = option.value; _validationMessage = null; }), borderRadius: BorderRadius.circular(18), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: selected ? EstoquePalette.inputFill : EstoquePalette.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? EstoquePalette.primary : EstoquePalette.border, width: selected ? 1.5 : 1), boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))]), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: selected ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(14)), child: Icon(option.icon, color: selected ? Colors.white : EstoquePalette.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(option.label, style: const TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w700, fontSize: 15)), const SizedBox(height: 3), Text(option.description, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12))])), Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? EstoquePalette.primary : EstoquePalette.textMuted)])))); }

  Widget _dadosStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title(_tipo == 'MESA' ? 'Configure a mesa' : 'Informe os dados', 'Preencha as informações necessárias para esta comanda.'), const SizedBox(height: 18),
        if (_tipo == 'MESA') ...[_label('Mesa'), _dropdownMesa(), const SizedBox(height: 18), _label('Garçom responsável'), _dropdownGarcom(), const SizedBox(height: 18), _label('Tipo de comanda'), _dropdownEscopo()],
        if (_tipo == 'DELIVERY') ...[_label('Cliente'), _dropdownCliente(), const SizedBox(height: 10), _addressCard()],
        if (_tipo == 'BALCAO') ...[_label('Cliente (opcional)'), _dropdownCliente(optional: true)],
        if (_validationMessage != null) ...[const SizedBox(height: 14), _errorBanner()],
      ]);

  Widget _clienteStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Quem está fazendo o pedido?', 'Selecione o cliente vinculado a esta comanda.'),
        const SizedBox(height: 18),
        _label('Cliente *'),
        const SizedBox(height: 8),
        _dropdownCliente(),
        const SizedBox(height: 14),
        if (_cliente != null) _clientCard(),
        if (_validationMessage != null) ...[const SizedBox(height: 14), _errorBanner()],
      ]);

  Widget _clientCard() => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: EstoquePalette.inputFill, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.border)), child: Row(children: [const Icon(Icons.person_outline_rounded, color: EstoquePalette.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_cliente!.nome ?? 'Cliente selecionado', style: const TextStyle(color: EstoquePalette.text, fontWeight: FontWeight.w700)), if (_cliente!.telefone?.isNotEmpty == true) Text(_cliente!.telefone!, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 12))]))]));

  Widget _revisaoStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_title('Revise sua comanda', 'Confira os dados antes de abrir a venda.'), const SizedBox(height: 18), _summaryCard(), const SizedBox(height: 18), _label('Observação (opcional)'), const SizedBox(height: 8), _textField(_observacao, 'Ex.: sem cebola, separar bebidas', maxLines: 4)]);

  Widget _dropdownMesa() => DropdownButtonFormField<int>(initialValue: _mesaId, isExpanded: true, decoration: _decoration('Selecione uma mesa'), items: _mesas.where((m) => m.id != null).map((m) => DropdownMenuItem(value: m.id, child: Text('Mesa ${m.numero ?? m.id}'))).toList(), onChanged: (value) => setState(() { _mesaId = value; _validationMessage = null; }));
  Widget _dropdownGarcom() => DropdownButtonFormField<int>(initialValue: _garcomId, isExpanded: true, decoration: _decoration('Selecione o garçom'), items: _garcons.map((usuario) => DropdownMenuItem(value: usuario.id, child: Text(usuario.nome ?? usuario.login ?? 'Garçom ${usuario.id}'))).toList(), onChanged: (value) => setState(() { _garcomId = value; _validationMessage = null; }));
  Widget _dropdownEscopo() => DropdownButtonFormField<String>(initialValue: _escopo, isExpanded: true, decoration: _decoration('Selecione o tipo'), items: const [DropdownMenuItem(value: 'INDIVIDUAL', child: Text('Individual')), DropdownMenuItem(value: 'COMPARTILHADA', child: Text('Compartilhada'))], onChanged: (value) => setState(() => _escopo = value!));
  Widget _dropdownCliente({bool optional = false}) => DropdownButtonFormField<int>(initialValue: _cliente?.id, isExpanded: true, decoration: _decoration(optional ? 'Selecione um cliente ou deixe vazio' : 'Selecione um cliente'), items: _clientes.where((c) => c.id != null).map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome ?? 'Cliente ${c.id}'))).toList(), onChanged: (value) => setState(() { _cliente = _clientes.firstWhere((c) => c.id == value); _validationMessage = null; }));
  InputDecoration _decoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: EstoquePalette.textMuted), filled: true, fillColor: EstoquePalette.surfaceAlt, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.primary, width: 1.5)));
  Widget _textField(TextEditingController controller, String hint, {int maxLines = 1}) => Container(decoration: BoxDecoration(color: EstoquePalette.surfaceAlt, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.border), boxShadow: const [BoxShadow(color: Color(0x0F9C5A1E), blurRadius: 12, offset: Offset(0, 4))]), child: TextField(controller: controller, maxLines: maxLines, style: const TextStyle(color: EstoquePalette.text, fontSize: 15), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: EstoquePalette.textMuted), border: InputBorder.none, contentPadding: const EdgeInsets.all(16))));
  Widget _addressCard() => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _cliente?.endereco == null ? EstoquePalette.warningBg : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cliente?.endereco == null ? EstoquePalette.warningBorder : EstoquePalette.border)), child: Row(children: [Icon(_cliente?.endereco == null ? Icons.info_outline_rounded : Icons.location_on_outlined, color: EstoquePalette.primary, size: 20), const SizedBox(width: 10), Expanded(child: Text(_cliente?.endereco == null ? 'O cliente precisa ter endereço cadastrado.' : 'Endereço cadastrado selecionado para a entrega.', style: const TextStyle(color: EstoquePalette.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35)))]));
  Widget _infoCard(String text) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: EstoquePalette.warningBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.warningBorder)), child: Row(children: [const Icon(Icons.lightbulb_outline_rounded, color: EstoquePalette.primary, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: EstoquePalette.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35)))]));
  Widget _errorBanner() => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: EstoquePalette.warningBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: EstoquePalette.error)), child: Row(children: [const Icon(Icons.warning_amber_rounded, color: EstoquePalette.error, size: 18), const SizedBox(width: 10), Expanded(child: Text(_validationMessage!, style: const TextStyle(color: EstoquePalette.text, fontSize: 12, fontWeight: FontWeight.w600)))]));
  String get _mesaLabel { for (final mesa in _mesas) { if (mesa.id == _mesaId) return 'Mesa ${mesa.numero ?? mesa.id}'; } return 'Mesa $_mesaId'; }
  String get _garcomLabel { for (final usuario in _garcons) { if (usuario.id == _garcomId) return usuario.nome ?? usuario.login ?? 'Garçom $_garcomId'; } return 'Garçom $_garcomId'; }
  Widget _summaryCard() => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: EstoquePalette.border)), child: Column(children: [_summaryLine('Canal', _canalOptions.firstWhere((o) => o.value == _tipo).label), if (_mesaId != null) _summaryLine('Mesa', _mesaLabel), if (_garcomId != null) _summaryLine('Garçom', _garcomLabel), if (_cliente != null) _summaryLine('Cliente', _cliente!.nome ?? 'Cliente'), if (_tipo == 'MESA') _summaryLine('Escopo', _escopo == 'COMPARTILHADA' ? 'Compartilhada' : 'Individual')]));
  Widget _summaryLine(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 13)), Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)))]));
  Widget _bottomButtons() => SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Row(children: [Expanded(child: OutlinedButton(onPressed: _previous, style: OutlinedButton.styleFrom(foregroundColor: EstoquePalette.text, backgroundColor: EstoquePalette.surfaceAlt, side: const BorderSide(color: EstoquePalette.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(_step == 0 ? 'Cancelar' : 'Voltar'))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: _saving ? null : _next, style: ElevatedButton.styleFrom(backgroundColor: EstoquePalette.primary, foregroundColor: Colors.white, disabledBackgroundColor: EstoquePalette.primarySoft, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_step == 3 ? 'Abrir comanda' : 'Continuar'), const SizedBox(width: 8), const Icon(Icons.chevron_right_rounded, size: 18)]))) ])));
}
