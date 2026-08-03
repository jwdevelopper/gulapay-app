import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/models/lote_status_validade.dart';
import 'package:my_app_teste/modules/lote/page/lote_detalhes_page.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_card.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_insumo_seletor.dart';

/// Filtro por validade aplicado no cliente sobre a lista FEFO do backend.
enum _FiltroValidade { todos, vencidos, ate7, ate30 }

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final LoteService _service = LoteService();
  final TextEditingController _busca = TextEditingController();

  InsumoResponse? _insumo;
  List<LoteResponse> _lotes = [];
  bool _carregando = false;
  String? _erro;
  String _filtroTexto = '';
  _FiltroValidade _filtroValidade = _FiltroValidade.todos;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _selecionarInsumo() async {
    final insumo = await LoteInsumoSeletor.abrir(context);
    if (insumo == null) return;
    setState(() {
      _insumo = insumo;
      _lotes = [];
      _filtroTexto = '';
      _busca.clear();
      _filtroValidade = _FiltroValidade.todos;
    });
    await _carregar();
  }

  Future<void> _carregar() async {
    final insumo = _insumo;
    if (insumo?.id == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _service.listar(insumoId: insumo!.id!);
      if (!mounted) return;
      setState(() => _lotes = lista);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao carregar lotes: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  bool _correspondeValidade(LoteResponse lote) {
    final status = LoteStatusValidade.calcular(lote.validade);
    switch (_filtroValidade) {
      case _FiltroValidade.todos:
        return true;
      case _FiltroValidade.vencidos:
        return status == LoteStatusValidade.vencido;
      case _FiltroValidade.ate7:
        return status == LoteStatusValidade.ate7Dias;
      case _FiltroValidade.ate30:
        return status == LoteStatusValidade.ate7Dias ||
            status == LoteStatusValidade.ate30Dias;
    }
  }

  bool _correspondeTexto(LoteResponse lote) {
    final termo = _filtroTexto.trim().toLowerCase();
    if (termo.isEmpty) return true;
    final codigo = (lote.codigo ?? '').toLowerCase();
    final insumo = (lote.insumoNome ?? '').toLowerCase();
    return codigo.contains(termo) || insumo.contains(termo);
  }

  List<LoteResponse> get _filtrados =>
      _lotes.where((l) => _correspondeTexto(l) && _correspondeValidade(l)).toList();

  int _contar(bool Function(LoteStatusValidade) teste) {
    return _lotes
        .where((l) => teste(LoteStatusValidade.calcular(l.validade)))
        .length;
  }

  Future<void> _abrirDetalhes(LoteResponse lote) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LoteDetalhesPage(lote: lote, insumo: _insumo),
      ),
    );
    if (alterou == true) await _carregar();
  }

  Future<void> _abrirCriacao() async {
    final criado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormPage(insumoInicial: _insumo),
      ),
    );
    if (criado == true) await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final temInsumo = _insumo != null;

    return Scaffold(
      backgroundColor: AppTema.fundo,
      floatingActionButton: temInsumo
          ? FloatingActionButton(
              onPressed: _abrirCriacao,
              backgroundColor: AppTema.primaria,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: temInsumo ? _corpoComInsumo() : _corpoSelecaoInsumo(),
    );
  }

  Widget _corpoSelecaoInsumo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppEstadoVazio(
              icone: Icons.calendar_month_outlined,
              mensagem:
                  'Selecione um insumo para visualizar seus lotes em ordem de validade (FEFO).',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selecionarInsumo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTema.primaria,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text(
                'Selecionar insumo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corpoComInsumo() {
    return Column(
      children: [
        _cabecalhoInsumo(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: AppCampoBusca(
            controle: _busca,
            dica: 'Buscar por código ou insumo…',
            aoMudar: (valor) => setState(() => _filtroTexto = valor),
          ),
        ),
        _chipsFiltro(),
        const SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator(
            color: AppTema.primaria,
            onRefresh: _carregar,
            child: _lista(),
          ),
        ),
      ],
    );
  }

  Widget _cabecalhoInsumo() {
    final insumo = _insumo!;
    final unidade = insumo.unidadePadraoSimbolo ?? insumo.unidadePadrao;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTema.cartao,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTema.primariaEscura),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insumo.nome ?? '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTema.textoEscuro,
                  ),
                ),
                Text(
                  unidade != null && unidade.isNotEmpty
                      ? 'Unidade base: $unidade'
                      : 'Lotes em ordem FEFO',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTema.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _selecionarInsumo,
            child: const Text('Trocar'),
          ),
        ],
      ),
    );
  }

  Widget _chipsFiltro() {
    final vencidos = _contar((s) => s == LoteStatusValidade.vencido);
    final ate7 = _contar((s) => s == LoteStatusValidade.ate7Dias);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip('Todos', _FiltroValidade.todos),
          _chip(
            '⏰ Vencidos${vencidos > 0 ? ' · $vencidos' : ''}',
            _FiltroValidade.vencidos,
          ),
          _chip(
            '⚠️ 7d${ate7 > 0 ? ' · $ate7' : ''}',
            _FiltroValidade.ate7,
          ),
          _chip('📅 30d', _FiltroValidade.ate30),
        ],
      ),
    );
  }

  Widget _chip(String texto, _FiltroValidade valor) {
    final ativo = _filtroValidade == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto, overflow: TextOverflow.visible, softWrap: false),
        selected: ativo,
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: TextStyle(
          color: ativo ? Colors.white : AppTema.textoSecundario,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        backgroundColor: AppTema.cartao,
        selectedColor: AppTema.primaria,
        side: BorderSide(
          color: ativo ? AppTema.primaria : AppTema.bordaCampo,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (_) => setState(() => _filtroValidade = valor),
      ),
    );
  }

  Widget _lista() {
    if (_carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 140),
          Center(child: CircularProgressIndicator(color: AppTema.primaria)),
        ],
      );
    }

    if (_erro != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: [
          AppEstadoVazio(icone: Icons.error_outline, mensagem: _erro!),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    if (_lotes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: const [
          AppEstadoVazio(
            icone: Icons.calendar_month_outlined,
            mensagem:
                'Nenhum lote cadastrado para este insumo. Use o botão + para criar um lote avulso.',
          ),
        ],
      );
    }

    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        children: const [
          AppEstadoVazio(
            icone: Icons.search_off,
            mensagem: 'Nenhum lote corresponde à busca ou ao filtro.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final lote = filtrados[index];
        return LoteCard(lote: lote, onTap: () => _abrirDetalhes(lote));
      },
    );
  }
}
