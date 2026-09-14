import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';
import '../service/rateio_service.dart';

/// Tela de rateio de uma comanda COMPARTILHADA (Sprint 3).
///
/// Fluxo:
/// 1. Ao abrir, chama `GET /comandas/{id}/rateio` para carregar o estado.
/// 2. Se `estrategia == null` — modo edição: usuário marca/desmarca
///    participantes (PATCH), escolhe estratégia e aplica (POST).
/// 3. Se `estrategia != null` — modo resumo: mostra os valores calculados
///    por participante e um botão "Recalcular" que reverte antes.
///
/// Fase 1: só as estratégias **IGUALITARIO** e **SEM_RATEIO** estão
/// funcionais. **MANUAL**, **PROPORCIONAL** e **POR_ITEM** aparecem
/// desabilitadas com badge "Em breve" — próximas entregas.
class RateioPage extends StatefulWidget {
  const RateioPage({super.key, required this.comandaId});

  final int comandaId;

  @override
  State<RateioPage> createState() => _RateioPageState();
}

class _RateioPageState extends State<RateioPage> {
  final _service = RateioService();

  RateioComandaResponse? _rateio;
  bool _carregando = true;
  bool _executando = false;
  String? _erro;

  /// Estratégia escolhida (só relevante quando o rateio ainda não foi
  /// aplicado). Default: IGUALITARIO — a mais comum.
  EstrategiaRateio _estrategiaSelecionada = EstrategiaRateio.igualitario;

  /// Ids de participantes marcados no estado local. Só é sincronizado
  /// com o backend quando o usuário toca em "Salvar participantes".
  final Set<int> _participantesMarcados = {};

  /// Snapshot do que veio da API — pra sabermos se o usuário mexeu.
  Set<int> _participantesOriginais = {};

  bool get _mudouParticipantes =>
      !_setEquals(_participantesMarcados, _participantesOriginais);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resposta = await _service.buscarRateio(widget.comandaId);
      if (!mounted) return;
      setState(() {
        _rateio = resposta;
        _participantesOriginais = resposta.participantes
            .where((p) => p.participante)
            .map((p) => p.comandaIndividualId)
            .toSet();
        _participantesMarcados
          ..clear()
          ..addAll(_participantesOriginais);
        _carregando = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        _carregando = false;
      });
    }
  }

  Future<void> _salvarParticipantes() async {
    await _executar(() async {
      final resposta = await _service.definirParticipantes(
        widget.comandaId,
        RateioParticipantesRequest(
          comandaIndividualIds: _participantesMarcados.toList(),
        ),
      );
      if (!mounted) return;
      _aplicarResposta(resposta);
      _mostrarSnack('Participantes atualizados.', sucesso: true);
    });
  }

  Future<void> _aplicarRateio() async {
    await _executar(() async {
      final resposta = await _service.aplicarRateio(
        widget.comandaId,
        RateioComandaRequest(estrategia: _estrategiaSelecionada),
      );
      if (!mounted) return;
      _aplicarResposta(resposta);
      _mostrarSnack(
          'Rateio aplicado: ${_estrategiaSelecionada.rotulo}.',
          sucesso: true);
    });
  }

  Future<void> _reverterRateio() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EstoquePalette.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Recalcular rateio'),
        content: const Text(
            'Isso vai limpar o rateio já calculado. Você poderá aplicar '
            'de novo com outra estratégia. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: EstoquePalette.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Recalcular'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await _executar(() async {
      final resposta = await _service.reverterRateio(widget.comandaId);
      if (!mounted) return;
      _aplicarResposta(resposta);
      _mostrarSnack('Rateio revertido. Escolha uma nova estratégia.',
          sucesso: true);
    });
  }

  Future<void> _executar(Future<void> Function() acao) async {
    setState(() => _executando = true);
    try {
      await acao();
    } on ApiError catch (e) {
      _mostrarSnack(e.message, sucesso: false);
    } finally {
      if (mounted) setState(() => _executando = false);
    }
  }

  void _aplicarResposta(RateioComandaResponse resposta) {
    setState(() {
      _rateio = resposta;
      _participantesOriginais = resposta.participantes
          .where((p) => p.participante)
          .map((p) => p.comandaIndividualId)
          .toSet();
      _participantesMarcados
        ..clear()
        ..addAll(_participantesOriginais);
    });
  }

  void _mostrarSnack(String mensagem, {required bool sucesso}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor:
            sucesso ? EstoquePalette.success : EstoquePalette.error,
      ),
    );
  }

  bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  String _money(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstoquePalette.background,
      appBar: AppBar(
        backgroundColor: EstoquePalette.surface,
        foregroundColor: EstoquePalette.text,
        elevation: 0,
        title: const Text('Rateio da comanda',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    if (_carregando) {
      return const Center(
          child: CircularProgressIndicator(color: EstoquePalette.primary));
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: EstoquePalette.error, size: 48),
              const SizedBox(height: 12),
              Text(_erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: EstoquePalette.text)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: EstoquePalette.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    final r = _rateio!;
    return SafeArea(
      child: Column(
        children: [
          _construirCabecalho(r),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: r.rateioAplicado
                  ? _construirModoResumo(r)
                  : _construirModoEdicao(r),
            ),
          ),
          if (_executando)
            const LinearProgressIndicator(
                color: EstoquePalette.primary,
                backgroundColor: EstoquePalette.borderSoft),
        ],
      ),
    );
  }

  Widget _construirCabecalho(RateioComandaResponse r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: EstoquePalette.surface,
        border: Border(
            bottom: BorderSide(color: EstoquePalette.borderSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.codigo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: EstoquePalette.text)),
          const SizedBox(height: 4),
          Text('Total: ${_money(r.totalLiquido)}',
              style: const TextStyle(
                  color: EstoquePalette.textMuted, fontSize: 13)),
          if (r.rateioAplicado) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EstoquePalette.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        EstoquePalette.success.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Estratégia aplicada: ${EstrategiaRateio.fromApi(r.estrategia)?.rotulo ?? r.estrategia}',
                style: const TextStyle(
                    color: EstoquePalette.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Modo edição: escolher participantes + estratégia + aplicar
  // ---------------------------------------------------------------
  List<Widget> _construirModoEdicao(RateioComandaResponse r) {
    if (r.participantes.isEmpty) {
      return const [
        SizedBox(height: 32),
        Icon(Icons.people_outline,
            size: 48, color: EstoquePalette.textMuted),
        SizedBox(height: 12),
        Text(
          'Esta comanda ainda não tem individuais vinculadas.\n'
          'Crie comandas INDIVIDUAIS com esta como pai antes '
          'de aplicar rateio.',
          textAlign: TextAlign.center,
          style: TextStyle(color: EstoquePalette.textMuted),
        ),
      ];
    }

    return [
      _tituloSecao('1. Quem participa'),
      const SizedBox(height: 8),
      ...r.participantes.map(_construirLinhaParticipante),
      if (_mudouParticipantes) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _executando ? null : _salvarParticipantes,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Salvar participantes'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EstoquePalette.primary,
              side: const BorderSide(color: EstoquePalette.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
      const SizedBox(height: 24),
      _tituloSecao('2. Como dividir'),
      const SizedBox(height: 8),
      ...EstrategiaRateio.values.map(_construirCardEstrategia),
      const SizedBox(height: 20),
      _construirBotaoAplicar(),
      const SizedBox(height: 8),
      const Text(
        'A comanda precisa estar em AGUARDANDO_PAGAMENTO (fechada) '
        'para o rateio ser aplicado.',
        style: TextStyle(
            color: EstoquePalette.textMuted, fontSize: 12),
      ),
    ];
  }

  Widget _construirLinhaParticipante(RateioParticipanteResponse p) {
    final marcado = _participantesMarcados.contains(p.comandaIndividualId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: EstoquePalette.borderSoft),
      ),
      child: CheckboxListTile(
        value: marcado,
        onChanged: _executando
            ? null
            : (v) => setState(() {
                  if (v == true) {
                    _participantesMarcados.add(p.comandaIndividualId);
                  } else {
                    _participantesMarcados.remove(p.comandaIndividualId);
                  }
                }),
        activeColor: EstoquePalette.primary,
        title: Text(p.clienteNome ?? p.codigo,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: EstoquePalette.text)),
        subtitle: Text(
          '${p.codigo} · itens próprios ${_money(p.valorProprio)}',
          style: const TextStyle(
              color: EstoquePalette.textMuted, fontSize: 12),
        ),
      ),
    );
  }

  Widget _construirCardEstrategia(EstrategiaRateio e) {
    // Fase 1: só IGUALITARIO e SEM_RATEIO estão prontas.
    final habilitada = e == EstrategiaRateio.igualitario ||
        e == EstrategiaRateio.semRateio;
    final selecionada = _estrategiaSelecionada == e;

    return Opacity(
      opacity: habilitada ? 1.0 : 0.55,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: selecionada
            ? EstoquePalette.primarySoft.withValues(alpha: 0.35)
            : EstoquePalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selecionada
                  ? EstoquePalette.primary
                  : EstoquePalette.borderSoft,
              width: selecionada ? 1.5 : 1),
        ),
        child: ListTile(
          onTap: (habilitada && !_executando)
              ? () => setState(() => _estrategiaSelecionada = e)
              : null,
          leading: Icon(
            selecionada
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selecionada
                ? EstoquePalette.primary
                : EstoquePalette.textMuted,
          ),
          title: Row(
            children: [
              Text(e.rotulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: EstoquePalette.text)),
              if (!habilitada) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: EstoquePalette.warningBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: EstoquePalette.warningBorder),
                  ),
                  child: const Text('Em breve',
                      style: TextStyle(
                          fontSize: 10,
                          color: EstoquePalette.text,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          subtitle: Text(e.descricao,
              style: const TextStyle(
                  color: EstoquePalette.textMuted, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _construirBotaoAplicar() {
    // Validações locais antes de habilitar — evita 422 do backend.
    final marcados = _participantesMarcados.length;
    String? bloqueio;
    if (_mudouParticipantes) {
      bloqueio = 'Salve os participantes antes de aplicar.';
    } else if (marcados == 0) {
      bloqueio = 'Selecione pelo menos 1 participante.';
    } else if (_estrategiaSelecionada == EstrategiaRateio.semRateio &&
        marcados != 1) {
      bloqueio = 'Sem rateio exige exatamente 1 participante marcado.';
    }
    final habilitado = bloqueio == null && !_executando;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: habilitado ? _aplicarRateio : null,
            icon: const Icon(Icons.check_circle_outline_rounded,
                size: 18),
            label: const Text('Aplicar rateio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EstoquePalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (bloqueio != null) ...[
          const SizedBox(height: 6),
          Text(bloqueio,
              style: const TextStyle(
                  color: EstoquePalette.error, fontSize: 12)),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------
  // Modo resumo: rateio já aplicado
  // ---------------------------------------------------------------
  List<Widget> _construirModoResumo(RateioComandaResponse r) {
    final participantes =
        r.participantes.where((p) => p.participante).toList();
    return [
      _tituloSecao('Valores por participante'),
      const SizedBox(height: 8),
      ...participantes.map(_construirLinhaResumo),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _executando ? null : _reverterRateio,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Recalcular (aplicar outra estratégia)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: EstoquePalette.text,
            side: const BorderSide(color: EstoquePalette.border),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ];
  }

  Widget _construirLinhaResumo(RateioParticipanteResponse p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: EstoquePalette.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.clienteNome ?? p.codigo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: EstoquePalette.text)),
                  const SizedBox(height: 2),
                  Text(
                    '${p.codigo} · próprios ${_money(p.valorProprio)} · '
                    'rateio ${_money(p.valorRateio)}',
                    style: const TextStyle(
                        color: EstoquePalette.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _money(p.valorTotal),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: EstoquePalette.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) => Text(
        texto,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: EstoquePalette.text),
      );
}
