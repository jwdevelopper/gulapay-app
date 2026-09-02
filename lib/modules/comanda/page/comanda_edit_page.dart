import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';
import '../dto/comanda_patch_request.dart';
import '../dto/comanda_response.dart';
import '../service/comanda_service.dart';
import '../widgets/comanda_search_selector.dart';

class ComandaEditPage extends StatefulWidget {
  const ComandaEditPage({super.key, required this.comanda, required this.perfil});

  final ComandaResponse comanda;
  final String? perfil;

  @override
  State<ComandaEditPage> createState() => _ComandaEditPageState();
}

class _ComandaEditPageState extends State<ComandaEditPage> {
  final _service = ComandaService();
  late final TextEditingController _observacao;
  List<UsuarioResposta> _garcons = [];
  int? _garcomId;
  bool _saving = false;

  bool get _podeEditarGarcom => widget.perfil == 'ADMINISTRADOR' || widget.perfil == 'CAIXA';

  @override
  void initState() {
    super.initState();
    _observacao = TextEditingController(text: widget.comanda.observacao ?? '');
    _garcomId = widget.comanda.garcomId;
    _loadGarcons();
  }

  @override
  void dispose() {
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _loadGarcons() async {
    try {
      final usuarios = await UsuarioServico().listar(perfil: 'GARCOM');
      if (mounted) setState(() => _garcons = usuarios.where((usuario) => usuario.id != null && usuario.ativo != false).toList());
    } catch (_) {}
  }

  UsuarioResposta? get _garcomSelecionado {
    for (final garcom in _garcons) {
      if (garcom.id == _garcomId) return garcom;
    }
    return null;
  }

  String get _garcomLabel => _garcomSelecionado?.nome ?? _garcomSelecionado?.login ?? widget.comanda.garcomNome ?? 'Selecione o garçom';

  Future<void> _abrirGarcom() async {
    final garcom = await abrirSeletorComBusca<UsuarioResposta>(
      context: context,
      titulo: 'Escolher garçom',
      itens: _garcons,
      tituloItem: (item) => item.nome ?? item.login ?? 'Garçom ${item.id}',
      subtituloItem: (item) => item.login ?? '',
      icone: Icons.person_outline_rounded,
      selecionado: _garcomSelecionado,
    );
    if (garcom != null && mounted) setState(() => _garcomId = garcom.id);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.patch(
        widget.comanda.id!,
        ComandaPatchRequest(
          observacao: _observacao.text.trim(),
          garcomId: _podeEditarGarcom && _garcomId != widget.comanda.garcomId ? _garcomId : null,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: PaletaApp.background,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(children: [
                _backButton(),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Editar comanda', style: TextStyle(color: PaletaApp.text, fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(widget.comanda.codigo, style: const TextStyle(color: PaletaApp.textMuted, fontSize: 12)),
                ])),
              ]),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20), children: [
                _sectionTitle('INFORMAÇÕES EDITÁVEIS'),
                const SizedBox(height: 10),
                _observationField(),
                if (widget.comanda.tipoOrigem == 'MESA' && _podeEditarGarcom) ...[
                  const SizedBox(height: 18),
                  CampoSeletorComanda(rotulo: 'Garçom responsável', valor: _garcomId == null ? '' : _garcomLabel, icone: Icons.person_outline_rounded, aoTocar: _abrirGarcom),
                ],
                const SizedBox(height: 18),
                _infoCard(),
              ]),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Salvar alterações'),
                    style: ElevatedButton.styleFrom(backgroundColor: PaletaApp.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );

  Widget _backButton() => Material(color: PaletaApp.surface, borderRadius: BorderRadius.circular(16), child: InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(16), child: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: PaletaApp.border)), child: const Icon(Icons.arrow_back_rounded, color: PaletaApp.text))));
  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(color: PaletaApp.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5));
  Widget _observationField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Observação', style: TextStyle(color: PaletaApp.text, fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Container(decoration: BoxDecoration(color: PaletaApp.surfaceAlt, borderRadius: BorderRadius.circular(16), border: Border.all(color: PaletaApp.border)), child: TextField(controller: _observacao, maxLines: 4, style: const TextStyle(color: PaletaApp.text, fontSize: 15), decoration: const InputDecoration(hintText: 'Ex.: sem cebola, separar bebidas', hintStyle: TextStyle(color: PaletaApp.textMuted), border: InputBorder.none, contentPadding: EdgeInsets.all(16))))]);
  Widget _infoCard() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: PaletaApp.warningBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: PaletaApp.warningBorder)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: PaletaApp.primary, size: 20), SizedBox(width: 10), Expanded(child: Text('Clientes, mesa e canal são definidos na abertura. Esta tela permite alterar os campos autorizados pela API.', style: TextStyle(color: PaletaApp.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35)))]));
}
