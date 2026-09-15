import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_create_request.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';
import '../service/rateio_service.dart';

/// Tela de rateio de uma comanda COMPARTILHADA (Sprint 3).
///
/// Fluxo:
/// 1. Ao abrir, chama `GET /comandas/{id}/rateio` para carregar o estado.
///    Se ainda não há INDIVIDUAIS filhas, o caixa só informa "quantas
///    pessoas" e a tela cria (e fecha) uma filha por pessoa sozinha.
/// 2. Se `estrategia == null` — modo edição: usuário marca/desmarca
///    participantes (PATCH), escolhe estratégia e aplica (POST).
/// 3. Se `estrategia != null` — modo resumo: mostra os valores calculados
///    por participante e um botão "Recalcular" que reverte antes.
///
/// Fase 1: estratégias **IGUALITARIO** e **SEM_RATEIO**.
/// Fase 2: estratégia **MANUAL** — um campo de valor por participante,
/// com a soma validada no cliente contra o `totalLiquido`.
/// **PROPORCIONAL** e **POR_ITEM** aparecem desabilitadas com badge
/// "Em breve" — próximas entregas.
class RateioPage extends StatefulWidget {
  const RateioPage({super.key, required this.comandaId});

  final int comandaId;

  @override
  State<RateioPage> createState() => _RateioPageState();
}

class _RateioPageState extends State<RateioPage> {
  final _service = RateioService();
  final _comandaService = ComandaService();

  RateioComandaResponse? _rateio;

  /// Quantidade escolhida na divisão rápida (comanda ainda sem filhas).
  int _quantidadePessoas = 2;
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

  /// Campos de valor da estratégia MANUAL — chave é o comandaIndividualId.
  /// Criados sob demanda e liberados no [dispose].
  final Map<int, TextEditingController> _controladoresValor = {};

  /// Filtro de dígitos + vírgula (mesmo padrão dos campos de valor da
  /// comanda), limitado a uma vírgula e 2 casas decimais.
  static final List<TextInputFormatter> _formatadoresValor = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
    TextInputFormatter.withFunction((antigo, novo) =>
        RegExp(r'^\d*,?\d{0,2}$').hasMatch(novo.text) ? novo : antigo),
  ];

  /// Participantes em ordem de criação — o backend não garante ordem, e o
  /// rótulo "Pessoa N" precisa ser estável.
  List<RateioParticipanteResponse> get _participantes =>
      [..._rateio!.participantes]..sort(
          (a, b) => a.comandaIndividualId.compareTo(b.comandaIndividualId));

  /// Participantes marcados — só eles entram em `valoresManuais`.
  List<RateioParticipanteResponse> get _participantesManuais => _participantes
      .where((p) => _participantesMarcados.contains(p.comandaIndividualId))
      .toList();

  /// Filhas criadas pela divisão rápida herdam o cliente da compartilhada,
  /// então o nome se repete — nesse caso mostramos "Pessoa N".
  String _nomeParticipante(RateioParticipanteResponse p) {
    final participantes = _participantes;
    final nomesDistintos = participantes
        .map((e) => e.clienteNome)
        .whereType<String>()
        .toSet()
        .length;
    if (p.clienteNome != null && nomesDistintos == participantes.length) {
      return p.clienteNome!;
    }
    final indice = participantes
        .indexWhere((e) => e.comandaIndividualId == p.comandaIndividualId);
    return 'Pessoa ${indice + 1}';
  }

  /// Valores trabalhados em centavos (int) pra comparação exata com o
  /// total — somar doubles pode dar 99.99999 em vez de 100.
  int get _totalCentavos => (_rateio!.totalLiquido * 100).round();

  int get _somaManualCentavos => _participantesManuais.fold(
      0, (soma, p) => soma + (_centavosDe(p.comandaIndividualId) ?? 0));

  bool get _algumValorManualVazio => _participantesManuais
      .any((p) => _centavosDe(p.comandaIndividualId) == null);

  bool get _somaManualFecha => _somaManualCentavos == _totalCentavos;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    for (final controle in _controladoresValor.values) {
      controle.dispose();
    }
    super.dispose();
  }

  TextEditingController _controladorValor(int comandaIndividualId) =>
      _controladoresValor.putIfAbsent(
          comandaIndividualId, TextEditingController.new);

  /// Centavos digitados pro participante. `null` quando o campo está vazio
  /// (ou inválido) — 0 é um valor aceito.
  int? _centavosDe(int comandaIndividualId) {
    final texto = _controladoresValor[comandaIndividualId]?.text.trim() ?? '';
    final valor = double.tryParse(texto.replaceAll(',', '.'));
    return valor == null ? null : (valor * 100).round();
  }

  /// Quanto falta pra fechar o total desconsiderando o próprio participante.
  int _restanteCentavosPara(int comandaIndividualId) {
    final doProprio = _centavosDe(comandaIndividualId) ?? 0;
    return _totalCentavos - (_somaManualCentavos - doProprio);
  }

  void _preencherRestante(int comandaIndividualId) {
    final restante = _restanteCentavosPara(comandaIndividualId);
    setState(() => _controladorValor(comandaIndividualId).text =
        (restante / 100).toStringAsFixed(2).replaceAll('.', ','));
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

  /// Cria [quantidade] comandas INDIVIDUAIS filhas com mesa/garçom/cliente
  /// da compartilhada e já as fecha (vazias), pra mesa não voltar a ficar
  /// OCUPADA. Toda filha nasce participante do rateio no backend.
  Future<void> _adicionarPessoas(int quantidade) async {
    await _executar(() async {
      try {
        final pai = await _comandaService.buscarPorId(widget.comandaId);
        final jaExistentes = _rateio?.participantes.length ?? 0;
        for (var i = 1; i <= quantidade; i++) {
          final filha = await _comandaService.criar(ComandaCreateRequest(
            tipoOrigem: 'MESA',
            escopo: 'INDIVIDUAL',
            mesaId: pai.mesaId,
            garcomId: pai.garcomId,
            clienteId: pai.clienteId,
            comandaPaiId: widget.comandaId,
            observacao: 'Pessoa ${jaExistentes + i} - divisão da ${pai.codigo}',
          ));
          await _comandaService.fechar(filha.id!);
        }
      } finally {
        // Mesmo com falha no meio, mostra as filhas que chegaram a ser criadas.
        final resposta = await _service.buscarRateio(widget.comandaId);
        if (mounted) _aplicarResposta(resposta);
      }
      _mostrarSnack(
          quantidade == 1
              ? 'Pessoa adicionada.'
              : 'Conta pronta para dividir entre $quantidade pessoas.',
          sucesso: true);
    });
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
      final valoresManuais = _estrategiaSelecionada == EstrategiaRateio.manual
          ? _participantesManuais
              .map((p) => RateioValorManualItem(
                    comandaIndividualId: p.comandaIndividualId,
                    valor: _centavosDe(p.comandaIndividualId)! / 100,
                  ))
              .toList()
          : null;
      final resposta = await _service.aplicarRateio(
        widget.comandaId,
        RateioComandaRequest(
          estrategia: _estrategiaSelecionada,
          valoresManuais: valoresManuais,
        ),
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
      for (final controle in _controladoresValor.values) {
        controle.clear();
      }
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
        title: const Text('Dividir conta',
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
    if (r.participantes.isEmpty) return _construirDivisaoRapida();

    return [
      _tituloSecao('1. Quem participa'),
      const SizedBox(height: 8),
      ..._participantes.map(_construirLinhaParticipante),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _executando ? null : () => _adicionarPessoas(1),
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: const Text('Adicionar pessoa'),
          style: TextButton.styleFrom(
              foregroundColor: EstoquePalette.primary),
        ),
      ),
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
      if (_estrategiaSelecionada == EstrategiaRateio.manual) ...[
        const SizedBox(height: 16),
        _tituloSecao('3. Quanto cada um paga'),
        const SizedBox(height: 8),
        _construirFormularioManual(),
      ],
      const SizedBox(height: 20),
      _construirBotaoAplicar(),
    ];
  }

  /// Comanda sem filhas: em vez de exigir cadastro manual de cada
  /// INDIVIDUAL, pergunta só quantas pessoas e cria tudo de uma vez.
  List<Widget> _construirDivisaoRapida() {
    return [
      const SizedBox(height: 16),
      _tituloSecao('Dividir entre quantas pessoas?'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EstoquePalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EstoquePalette.border),
        ),
        child: Row(
          children: [
            _botaoPasso(Icons.remove_rounded,
                _quantidadePessoas > 2 ? -1 : null),
            Expanded(
              child: Column(
                children: [
                  Text('$_quantidadePessoas',
                      style: const TextStyle(
                          color: EstoquePalette.text,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  Text(
                    '≈ ${_money(_rateio!.totalLiquido / _quantidadePessoas)} cada',
                    style: const TextStyle(
                        color: EstoquePalette.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            _botaoPasso(Icons.add_rounded,
                _quantidadePessoas < 20 ? 1 : null),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _executando
              ? null
              : () => _adicionarPessoas(_quantidadePessoas),
          icon: const Icon(Icons.call_split_rounded, size: 18),
          label: Text('Dividir entre $_quantidadePessoas pessoas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EstoquePalette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const AppDica(
        'Depois você escolhe como dividir: igual para todos ou digitando '
        'quanto cada um paga. Dá pra adicionar mais gente depois.',
      ),
    ];
  }

  /// Mesmo visual do seletor de quantidade da tela de comanda.
  Widget _botaoPasso(IconData icone, int? delta) => Material(
        color: EstoquePalette.inputFill,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: delta == null || _executando
              ? null
              : () => setState(() => _quantidadePessoas += delta),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EstoquePalette.borderSoft),
            ),
            child: Icon(icone,
                color: delta == null
                    ? EstoquePalette.border
                    : EstoquePalette.primary,
                size: 22),
          ),
        ),
      );

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
        title: Text(_nomeParticipante(p),
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
    // PROPORCIONAL e POR_ITEM ficam pra Fase 3.
    final habilitada = e == EstrategiaRateio.igualitario ||
        e == EstrategiaRateio.semRateio ||
        e == EstrategiaRateio.manual;
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

  // ---------------------------------------------------------------
  // Formulário da estratégia MANUAL
  // ---------------------------------------------------------------
  Widget _construirFormularioManual() {
    final participantes = _participantesManuais;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDica(
          'Digite quanto cada participante paga. Use o botão ao lado do '
          'campo pra preencher com o valor que falta pra fechar o total.',
        ),
        const SizedBox(height: 12),
        if (participantes.isEmpty)
          const Text(
            'Marque ao menos 1 participante acima para informar os valores.',
            style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12),
          )
        else ...[
          ...participantes.map(_construirLinhaValorManual),
          const SizedBox(height: 4),
          _construirResumoSoma(),
        ],
      ],
    );
  }

  Widget _construirLinhaValorManual(RateioParticipanteResponse p) {
    final id = p.comandaIndividualId;
    final restante = _restanteCentavosPara(id);
    final podePreencher = !_executando && restante >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: EstoquePalette.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nomeParticipante(p),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: EstoquePalette.text)),
                  const SizedBox(height: 2),
                  Text(
                    '${p.codigo} · itens próprios ${_money(p.valorProprio)}',
                    style: const TextStyle(
                        color: EstoquePalette.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: AppCampoTexto(
                controle: _controladorValor(id),
                dica: '0,00',
                tipoTeclado:
                    const TextInputType.numberWithOptions(decimal: true),
                formatadores: _formatadoresValor,
                habilitado: !_executando,
                aoMudar: (_) => setState(() {}),
                prefixo: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 4),
                  child: Center(
                    widthFactor: 1,
                    child: Text('R\$',
                        style: TextStyle(
                            color: EstoquePalette.textMuted,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                sufixo: IconButton(
                  tooltip: podePreencher
                      ? 'Preencher restante (${_money(restante / 100)})'
                      : 'Os outros valores já passam do total',
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 20),
                  color: EstoquePalette.primary,
                  onPressed:
                      podePreencher ? () => _preencherRestante(id) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResumoSoma() {
    final soma = _somaManualCentavos;
    final diferenca = _totalCentavos - soma;
    final fecha = diferenca == 0;
    final cor = fecha ? EstoquePalette.success : EstoquePalette.error;
    final detalhe = fecha
        ? 'A soma fecha com o total da comanda.'
        : diferenca > 0
            ? 'Faltam ${_money(diferenca / 100)}'
            : 'Sobram ${_money(-diferenca / 100)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(fecha ? Icons.check_circle_outline : Icons.error_outline,
              color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${_money(soma / 100)} / ${_money(_totalCentavos / 100)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: EstoquePalette.text),
                ),
                const SizedBox(height: 2),
                Text(detalhe,
                    style: TextStyle(
                        color: cor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
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
    } else if (_estrategiaSelecionada == EstrategiaRateio.manual &&
        _algumValorManualVazio) {
      bloqueio = 'Informe o valor de todos os participantes (0 é permitido).';
    } else if (_estrategiaSelecionada == EstrategiaRateio.manual &&
        !_somaManualFecha) {
      bloqueio = 'A soma dos valores precisa fechar com o total da comanda.';
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
        _participantes.where((p) => p.participante).toList();
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
                  Text(_nomeParticipante(p),
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
