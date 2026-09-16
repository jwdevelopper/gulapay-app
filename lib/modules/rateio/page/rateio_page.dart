import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_create_request.dart';
import 'package:my_app_teste/modules/comanda/dto/item_comanda_response.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';
import '../service/rateio_service.dart';
import '../util/rateio_calculo.dart';
import '../widget/rateio_estrategia_card.dart';
import '../widget/rateio_item_consumidores_tile.dart';
import '../widget/rateio_status_box.dart';

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
/// Fase 3: **PROPORCIONAL** (sem formulário — o backend pondera pelos
/// itens próprios) e **POR_ITEM** (um chip de consumidor por item da
/// comanda). As duas só ficam clicáveis quando a comanda comporta a
/// estratégia — ver [_indisponibilidade].
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

  /// Itens ativos da comanda COMPARTILHADA, usados pelo POR_ITEM. Vêm do
  /// `GET /comandas/{id}` junto com o carregamento do rateio.
  List<ItemComandaResponse> _itensAtivos = [];

  /// Quem consumiu cada item — `itemComandaId -> ids de INDIVIDUAL`.
  /// Só é enviado quando a estratégia é POR_ITEM.
  final Map<int, Set<int>> _consumidoresPorItem = {};

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

  /// Participantes marcados — só eles entram em `valoresManuais` /
  /// `itensConsumidores`.
  List<RateioParticipanteResponse> get _participantesSelecionados =>
      _participantes
          .where((p) => _participantesMarcados.contains(p.comandaIndividualId))
          .toList();

  /// Os mesmos participantes no formato enxuto que os chips do POR_ITEM
  /// consomem.
  List<RateioParticipanteChip> get _chipsParticipantes =>
      _participantesSelecionados
          .map((p) => (id: p.comandaIndividualId, nome: _nomeParticipante(p)))
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

  int get _somaManualCentavos => _participantesSelecionados.fold(
      0, (soma, p) => soma + (_centavosDe(p.comandaIndividualId) ?? 0));

  bool get _algumValorManualVazio => _participantesSelecionados
      .any((p) => _centavosDe(p.comandaIndividualId) == null);

  bool get _somaManualFecha => _somaManualCentavos == _totalCentavos;

  /// Itens que ainda não têm nenhum consumidor marcado. O backend recusa
  /// o POR_ITEM (422) se sobrar qualquer um, então a tela barra antes.
  List<ItemComandaResponse> get _itensSemConsumidor => _itensAtivos
      .where((i) => (_consumidoresPorItem[i.id] ?? const <int>{}).isEmpty)
      .toList();

  /// Prévia do POR_ITEM: quanto cada participante paga com as marcações
  /// atuais. Só serve de conferência — o valor oficial vem do POST.
  Map<int, int> get _previaPorItem => calcularRateioPorItem(
        subtotalCentavosPorItem: {
          for (final i in _itensAtivos) i.id!: (i.subtotal * 100).round(),
        },
        consumidoresPorItem: _consumidoresPorItem,
        participantes:
            _participantesSelecionados.map((p) => p.comandaIndividualId).toList(),
      );

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
      // Os itens só interessam ao POR_ITEM, mas vêm junto pra tela já
      // saber se pode oferecer a estratégia sem um segundo loading.
      final comanda = await _comandaService.buscarPorId(widget.comandaId);
      if (!mounted) return;
      setState(() {
        _sincronizarItens(comanda.itens);
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

  /// Guarda os itens ativos e descarta marcações de itens que sumiram
  /// (cancelados ou transferidos entre uma abertura e outra da tela).
  void _sincronizarItens(List<ItemComandaResponse> itens) {
    _itensAtivos = itens
        .where((i) => i.id != null && !i.cancelado && !i.transferido)
        .toList();
    final idsValidos = _itensAtivos.map((i) => i.id).toSet();
    _consumidoresPorItem.removeWhere((itemId, _) => !idsValidos.contains(itemId));
  }

  /// Marca/desmarca um participante como consumidor de um item.
  void _alternarConsumidor(int itemId, int comandaIndividualId) {
    setState(() {
      final consumidores =
          _consumidoresPorItem.putIfAbsent(itemId, () => <int>{});
      if (!consumidores.remove(comandaIndividualId)) {
        consumidores.add(comandaIndividualId);
      }
    });
  }

  /// Botão "Todos"/"Limpar" do item: se já estão todos marcados, limpa.
  void _alternarTodosConsumidores(int itemId) {
    final todos =
        _participantesSelecionados.map((p) => p.comandaIndividualId).toSet();
    final atuais = _consumidoresPorItem[itemId] ?? const <int>{};
    setState(() => _consumidoresPorItem[itemId] =
        atuais.length == todos.length ? <int>{} : todos);
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
          ? _participantesSelecionados
              .map((p) => RateioValorManualItem(
                    comandaIndividualId: p.comandaIndividualId,
                    valor: _centavosDe(p.comandaIndividualId)! / 100,
                  ))
              .toList()
          : null;
      // POR_ITEM: o backend exige TODO item ativo na lista, por isso a
      // origem aqui é _itensAtivos e não o mapa de marcações.
      final itensConsumidores =
          _estrategiaSelecionada == EstrategiaRateio.porItem
              ? _itensAtivos
                  .map((i) => RateioConsumidoresItem(
                        itemComandaId: i.id!,
                        comandaIndividualIds:
                            (_consumidoresPorItem[i.id] ?? const <int>{})
                                .toList(),
                      ))
                  .toList()
              : null;
      final resposta = await _service.aplicarRateio(
        widget.comandaId,
        RateioComandaRequest(
          estrategia: _estrategiaSelecionada,
          valoresManuais: valoresManuais,
          itensConsumidores: itensConsumidores,
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
      // Quem deixou de participar não pode continuar marcado como
      // consumidor de item — o backend recusa id fora dos participantes.
      for (final consumidores in _consumidoresPorItem.values) {
        consumidores.retainWhere(_participantesMarcados.contains);
      }
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
      if (_estrategiaSelecionada == EstrategiaRateio.proporcional) ...[
        const SizedBox(height: 16),
        _construirPreviaProporcional(),
      ],
      if (_estrategiaSelecionada == EstrategiaRateio.porItem) ...[
        const SizedBox(height: 16),
        _tituloSecao('3. Quem consumiu cada item'),
        const SizedBox(height: 8),
        ..._construirFormularioPorItem(),
      ],
      const SizedBox(height: 20),
      _construirBotaoAplicar(),
    ];
  }

  /// PROPORCIONAL não tem formulário: o backend pondera pelo total de
  /// itens **próprios** de cada participante. A tela só mostra os pesos
  /// que ele vai usar, pra ninguém aplicar às cegas.
  Widget _construirPreviaProporcional() {
    final participantes = _participantesSelecionados;
    final pesoTotal =
        participantes.fold<double>(0, (soma, p) => soma + p.valorProprio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDica(
          'Quem consumiu mais por fora da comanda compartilhada paga uma '
          'fatia maior. O cálculo é feito pelo servidor — aqui embaixo é '
          'só a prévia dos pesos.',
        ),
        const SizedBox(height: 12),
        ...participantes.map((p) {
          final fatia = pesoTotal == 0 ? 0.0 : p.valorProprio / pesoTotal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(_nomeParticipante(p),
                      style: const TextStyle(
                          color: EstoquePalette.text, fontSize: 13)),
                ),
                Text(
                  '${_money(p.valorProprio)} · ${(fatia * 100).toStringAsFixed(0)}% '
                  '≈ ${_money(_rateio!.totalLiquido * fatia)}',
                  style: const TextStyle(
                      color: EstoquePalette.textMuted, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// POR_ITEM: uma linha por item ativo com os chips de consumidores, e
  /// no fim o status de cobertura + a prévia do que cada um vai pagar.
  List<Widget> _construirFormularioPorItem() {
    final chips = _chipsParticipantes;
    if (chips.isEmpty) {
      return const [
        Text('Marque ao menos 1 participante acima para atribuir os itens.',
            style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12)),
      ];
    }

    final faltando = _itensSemConsumidor.length;
    return [
      const AppDica(
        'Marque quem consumiu cada item. Um item dividido entre várias '
        'pessoas tem o valor partido igualmente entre elas.',
      ),
      const SizedBox(height: 12),
      ..._itensAtivos.map((item) => RateioItemConsumidoresTile(
            item: item,
            participantes: chips,
            consumidores: _consumidoresPorItem[item.id] ?? const <int>{},
            habilitado: !_executando,
            aoAlternar: (idPessoa) => _alternarConsumidor(item.id!, idPessoa),
            aoMarcarTodos: () => _alternarTodosConsumidores(item.id!),
          )),
      const SizedBox(height: 4),
      RateioStatusBox(
        ok: faltando == 0,
        titulo: '${_itensAtivos.length - faltando} de ${_itensAtivos.length} '
            'itens atribuídos',
        detalhe: faltando == 0
            ? 'Todo item tem pelo menos um consumidor.'
            : faltando == 1
                ? 'Falta marcar quem consumiu 1 item.'
                : 'Faltam marcar quem consumiu $faltando itens.',
        rodape: faltando == 0 ? _construirPreviaPorItem() : null,
      ),
    ];
  }

  Widget _construirPreviaPorItem() {
    final previa = _previaPorItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _participantesSelecionados.map((p) {
        final centavos = previa[p.comandaIndividualId] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(_nomeParticipante(p),
                    style: const TextStyle(
                        color: EstoquePalette.text, fontSize: 13)),
              ),
              Text(_money(centavos / 100),
                  style: const TextStyle(
                      color: EstoquePalette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
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

  /// Motivo pelo qual a estratégia não pode ser usada nesta comanda, ou
  /// `null` quando ela está liberada. Evita mandar um POST que o backend
  /// já rejeitaria com 422.
  String? _indisponibilidade(EstrategiaRateio e) => switch (e) {
        EstrategiaRateio.porItem when _itensAtivos.isEmpty =>
          'Sem itens ativos',
        EstrategiaRateio.proporcional
            when _participantesSelecionados.every((p) => p.valorProprio <= 0) =>
          'Ninguém consumiu por fora',
        _ => null,
      };

  Widget _construirCardEstrategia(EstrategiaRateio e) {
    final indisponivel = _indisponibilidade(e);
    return RateioEstrategiaCard(
      estrategia: e,
      selecionada: _estrategiaSelecionada == e,
      indisponivelPor: indisponivel,
      aoSelecionar: _executando
          ? null
          : () => setState(() => _estrategiaSelecionada = e),
    );
  }

  // ---------------------------------------------------------------
  // Formulário da estratégia MANUAL
  // ---------------------------------------------------------------
  Widget _construirFormularioManual() {
    final participantes = _participantesSelecionados;
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

    return RateioStatusBox(
      ok: diferenca == 0,
      titulo:
          'Total: ${_money(soma / 100)} / ${_money(_totalCentavos / 100)}',
      detalhe: switch (diferenca) {
        0 => 'A soma fecha com o total da comanda.',
        > 0 => 'Faltam ${_money(diferenca / 100)}',
        _ => 'Sobram ${_money(-diferenca / 100)}',
      },
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
    } else if (_indisponibilidade(_estrategiaSelecionada) != null) {
      // Ex.: marcou PROPORCIONAL e depois desmarcou quem tinha itens próprios.
      bloqueio = 'Esta estratégia não se aplica a esta comanda.';
    } else if (_estrategiaSelecionada == EstrategiaRateio.porItem &&
        _itensSemConsumidor.isNotEmpty) {
      bloqueio = 'Todo item precisa de pelo menos um consumidor '
          '(faltam ${_itensSemConsumidor.length}).';
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
