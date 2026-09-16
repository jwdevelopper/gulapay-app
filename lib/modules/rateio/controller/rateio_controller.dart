import 'package:flutter/widgets.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_create_request.dart';
import 'package:my_app_teste/modules/comanda/dto/item_comanda_response.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import '../dto/rateio_comanda_request.dart';
import '../dto/rateio_comanda_response.dart';
import '../dto/rateio_participantes_request.dart';
import '../service/rateio_service.dart';
import '../util/rateio_calculo.dart';

class RateioAviso {
  const RateioAviso(this.mensagem, {required this.sucesso});

  final String mensagem;
  final bool sucesso;
}

typedef RateioParticipanteChip = ({int id, String nome});

class RateioController extends ChangeNotifier {
  RateioController({
    required this.comandaId,
    RateioService? rateioService,
    ComandaService? comandaService,
  })  : _service = rateioService ?? RateioService(),
        _comandaService = comandaService ?? ComandaService();

  static const int maximoPessoas = 20;

  final int comandaId;
  final RateioService _service;
  final ComandaService _comandaService;

  final Map<int, TextEditingController> _controladoresValor = {};
  final Map<int, Set<int>> _consumidoresPorItem = {};
  final Set<int> _marcados = {};

  RateioComandaResponse? _rateio;
  List<ItemComandaResponse> _itensAtivos = [];
  Set<int> _originais = {};
  EstrategiaRateio _estrategia = EstrategiaRateio.igualitario;
  int _quantidadePessoas = 2;
  bool _carregando = true;
  bool _executando = false;
  String? _erro;

  RateioComandaResponse? get rateio => _rateio;
  List<ItemComandaResponse> get itensAtivos => _itensAtivos;
  EstrategiaRateio get estrategia => _estrategia;
  int get quantidadePessoas => _quantidadePessoas;
  bool get carregando => _carregando;
  bool get executando => _executando;
  String? get erro => _erro;

  bool get rateioAplicado => _rateio?.rateioAplicado ?? false;
  bool get semParticipantes => _rateio?.participantes.isEmpty ?? true;
  double get totalLiquido => _rateio?.totalLiquido ?? 0;
  int get totalCentavos => (totalLiquido * 100).round();

  List<RateioParticipanteResponse> get participantes =>
      [...?_rateio?.participantes]..sort(
          (a, b) => a.comandaIndividualId.compareTo(b.comandaIndividualId));

  List<RateioParticipanteResponse> get selecionados => participantes
      .where((p) => _marcados.contains(p.comandaIndividualId))
      .toList();

  List<RateioParticipanteResponse> get participantesDoRateio =>
      participantes.where((p) => p.participante).toList();

  List<RateioParticipanteChip> get chips =>
      selecionados.map((p) => (id: p.comandaIndividualId, nome: nomeDe(p))).toList();

  bool marcado(int comandaIndividualId) =>
      _marcados.contains(comandaIndividualId);

  bool get mudouParticipantes =>
      _marcados.length != _originais.length ||
      !_marcados.containsAll(_originais);

  String nomeDe(RateioParticipanteResponse p) {
    final lista = participantes;
    final nomesDistintos =
        lista.map((e) => e.clienteNome).whereType<String>().toSet().length;
    if (p.clienteNome != null && nomesDistintos == lista.length) {
      return p.clienteNome!;
    }
    final indice =
        lista.indexWhere((e) => e.comandaIndividualId == p.comandaIndividualId);
    return 'Pessoa ${indice + 1}';
  }

  TextEditingController controladorValor(int comandaIndividualId) =>
      _controladoresValor.putIfAbsent(
          comandaIndividualId, TextEditingController.new);

  int? centavosDe(int comandaIndividualId) {
    final texto = _controladoresValor[comandaIndividualId]?.text.trim() ?? '';
    final valor = double.tryParse(texto.replaceAll(',', '.'));
    return valor == null ? null : (valor * 100).round();
  }

  int get somaManualCentavos => selecionados.fold(
      0, (soma, p) => soma + (centavosDe(p.comandaIndividualId) ?? 0));

  bool get algumValorManualVazio =>
      selecionados.any((p) => centavosDe(p.comandaIndividualId) == null);

  int restanteCentavosPara(int comandaIndividualId) =>
      totalCentavos -
      (somaManualCentavos - (centavosDe(comandaIndividualId) ?? 0));

  Set<int> consumidoresDe(int itemId) =>
      _consumidoresPorItem[itemId] ?? const <int>{};

  List<ItemComandaResponse> get itensSemConsumidor =>
      _itensAtivos.where((i) => consumidoresDe(i.id!).isEmpty).toList();

  Map<int, int> get previaPorItem => calcularRateioPorItem(
        subtotalCentavosPorItem: {
          for (final i in _itensAtivos) i.id!: (i.subtotal * 100).round(),
        },
        consumidoresPorItem: _consumidoresPorItem,
        participantes: selecionados.map((p) => p.comandaIndividualId).toList(),
      );

  String? indisponibilidade(EstrategiaRateio e) => switch (e) {
        EstrategiaRateio.porItem when _itensAtivos.isEmpty => 'Sem itens ativos',
        EstrategiaRateio.proporcional
            when selecionados.every((p) => p.valorProprio <= 0) =>
          'Ninguém consumiu por fora',
        _ => null,
      };

  String? get bloqueioAplicacao {
    if (mudouParticipantes) return 'Salve os participantes antes de aplicar.';
    if (_marcados.isEmpty) return 'Selecione pelo menos 1 participante.';
    if (_estrategia == EstrategiaRateio.semRateio && _marcados.length != 1) {
      return 'Sem rateio exige exatamente 1 participante marcado.';
    }
    if (_estrategia == EstrategiaRateio.manual && algumValorManualVazio) {
      return 'Informe o valor de todos os participantes (0 é permitido).';
    }
    if (_estrategia == EstrategiaRateio.manual &&
        somaManualCentavos != totalCentavos) {
      return 'A soma dos valores precisa fechar com o total da comanda.';
    }
    if (indisponibilidade(_estrategia) != null) {
      return 'Esta estratégia não se aplica a esta comanda.';
    }
    if (_estrategia == EstrategiaRateio.porItem &&
        itensSemConsumidor.isNotEmpty) {
      return 'Todo item precisa de pelo menos um consumidor '
          '(faltam ${itensSemConsumidor.length}).';
    }
    return null;
  }

  void selecionarEstrategia(EstrategiaRateio e) {
    _estrategia = e;
    notifyListeners();
  }

  void alternarParticipante(int comandaIndividualId) {
    if (!_marcados.remove(comandaIndividualId)) {
      _marcados.add(comandaIndividualId);
    }
    notifyListeners();
  }

  void alternarConsumidor(int itemId, int comandaIndividualId) {
    final consumidores =
        _consumidoresPorItem.putIfAbsent(itemId, () => <int>{});
    if (!consumidores.remove(comandaIndividualId)) {
      consumidores.add(comandaIndividualId);
    }
    notifyListeners();
  }

  void alternarTodosConsumidores(int itemId) {
    final todos = selecionados.map((p) => p.comandaIndividualId).toSet();
    _consumidoresPorItem[itemId] =
        consumidoresDe(itemId).length == todos.length ? <int>{} : todos;
    notifyListeners();
  }

  void valorDigitado() => notifyListeners();

  void preencherRestante(int comandaIndividualId) {
    controladorValor(comandaIndividualId).text =
        (restanteCentavosPara(comandaIndividualId) / 100)
            .toStringAsFixed(2)
            .replaceAll('.', ',');
    notifyListeners();
  }

  void ajustarQuantidadePessoas(int delta) {
    final nova = _quantidadePessoas + delta;
    if (nova < 2 || nova > maximoPessoas) return;
    _quantidadePessoas = nova;
    notifyListeners();
  }

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final resposta = await _service.buscarRateio(comandaId);
      final comanda = await _comandaService.buscarPorId(comandaId);
      _sincronizarItens(comanda.itens);
      _absorver(resposta);
    } on ApiError catch (e) {
      _erro = e.message;
    }
    _carregando = false;
    notifyListeners();
  }

  Future<RateioAviso?> adicionarPessoas(int quantidade) => _executar(() async {
        try {
          final pai = await _comandaService.buscarPorId(comandaId);
          final jaExistentes = _rateio?.participantes.length ?? 0;
          for (var i = 1; i <= quantidade; i++) {
            final filha = await _comandaService.criar(ComandaCreateRequest(
              tipoOrigem: 'MESA',
              escopo: 'INDIVIDUAL',
              mesaId: pai.mesaId,
              garcomId: pai.garcomId,
              clienteId: pai.clienteId,
              comandaPaiId: comandaId,
              observacao:
                  'Pessoa ${jaExistentes + i} - divisão da ${pai.codigo}',
            ));
            await _comandaService.fechar(filha.id!);
          }
        } finally {
          _absorver(await _service.buscarRateio(comandaId));
        }
        return RateioAviso(
          quantidade == 1
              ? 'Pessoa adicionada.'
              : 'Conta pronta para dividir entre $quantidade pessoas.',
          sucesso: true,
        );
      });

  Future<RateioAviso?> salvarParticipantes() => _executar(() async {
        _absorver(await _service.definirParticipantes(
          comandaId,
          RateioParticipantesRequest(comandaIndividualIds: _marcados.toList()),
        ));
        return const RateioAviso('Participantes atualizados.', sucesso: true);
      });

  Future<RateioAviso?> aplicar() => _executar(() async {
        _absorver(await _service.aplicarRateio(
          comandaId,
          RateioComandaRequest(
            estrategia: _estrategia,
            valoresManuais: _montarValoresManuais(),
            itensConsumidores: _montarItensConsumidores(),
          ),
        ));
        return RateioAviso('Rateio aplicado: ${_estrategia.rotulo}.',
            sucesso: true);
      });

  Future<RateioAviso?> reverter() => _executar(() async {
        _absorver(await _service.reverterRateio(comandaId));
        for (final controle in _controladoresValor.values) {
          controle.clear();
        }
        return const RateioAviso(
            'Rateio revertido. Escolha uma nova estratégia.',
            sucesso: true);
      });

  List<RateioValorManualItem>? _montarValoresManuais() {
    if (_estrategia != EstrategiaRateio.manual) return null;
    return selecionados
        .map((p) => RateioValorManualItem(
              comandaIndividualId: p.comandaIndividualId,
              valor: centavosDe(p.comandaIndividualId)! / 100,
            ))
        .toList();
  }

  List<RateioConsumidoresItem>? _montarItensConsumidores() {
    if (_estrategia != EstrategiaRateio.porItem) return null;
    return _itensAtivos
        .map((i) => RateioConsumidoresItem(
              itemComandaId: i.id!,
              comandaIndividualIds: consumidoresDe(i.id!).toList(),
            ))
        .toList();
  }

  Future<RateioAviso?> _executar(Future<RateioAviso?> Function() acao) async {
    _executando = true;
    notifyListeners();
    try {
      return await acao();
    } on ApiError catch (e) {
      return RateioAviso(e.message, sucesso: false);
    } finally {
      _executando = false;
      notifyListeners();
    }
  }

  void _sincronizarItens(List<ItemComandaResponse> itens) {
    _itensAtivos = itens
        .where((i) => i.id != null && !i.cancelado && !i.transferido)
        .toList();
    final validos = _itensAtivos.map((i) => i.id).toSet();
    _consumidoresPorItem.removeWhere((itemId, _) => !validos.contains(itemId));
  }

  void _absorver(RateioComandaResponse resposta) {
    _rateio = resposta;
    _originais = resposta.participantes
        .where((p) => p.participante)
        .map((p) => p.comandaIndividualId)
        .toSet();
    _marcados
      ..clear()
      ..addAll(_originais);
    for (final consumidores in _consumidoresPorItem.values) {
      consumidores.retainWhere(_marcados.contains);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controle in _controladoresValor.values) {
      controle.dispose();
    }
    super.dispose();
  }
}
