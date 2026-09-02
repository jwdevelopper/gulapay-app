import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/repository/local_floor_plan_repository.dart';

class RascunhoMesa {
  RascunhoMesa({
    this.id,
    required this.codigo,
    required this.idArea,
    required this.formato,
    required this.quantidadeCadeiras,
    required this.width,
    required this.height,
    this.pessoasSentadas,
  });

  final String? id;
  final String codigo;
  final String idArea;
  final FormatoMesa formato;
  final int quantidadeCadeiras;
  final double width;
  final double height;
  final int? pessoasSentadas;
}

class ResultadoAberturaComandaMesa {
  ResultadoAberturaComandaMesa({
    required this.idComanda,
    required this.reutilizouComandaExistente,
    required this.idsMesas,
  });

  final String idComanda;
  final bool reutilizouComandaExistente;
  final List<String> idsMesas;
}

class ControladorMapaMesas extends ChangeNotifier {
  ControladorMapaMesas({RepositorioLocalMapaMesas? repositorio})
    : _repositorio = repositorio ?? RepositorioLocalMapaMesas();

  static const double _margemCanvas = 36;
  static const double _intervaloGrade = 12;
  static const double _larguraMinimaMesa = 72;
  static const double _alturaMinimaMesa = 56;
  static const double _larguraMaximaMesa = 220;
  static const double _alturaMaximaMesa = 180;

  final RepositorioLocalMapaMesas _repositorio;
  final ValueNotifier<int> _atualizacaoMovimento = ValueNotifier<int>(0);

  List<AreaRestaurante> _areas = const [];
  String? _idAreaSelecionada;
  bool _estaCarregando = true;
  bool _estaSalvando = false;
  String? _idMesaEmMovimento;
  String? _idAlvoUniaoSugerida;
  String? _idOrigemUniaoSugerida;
  String? _erroUltimaAcao;
  String? _idUltimoContextoAberto;
  DateTime? _ultimaAberturaComandaEm;

  List<AreaRestaurante> get areas => _areas;
  bool get estaCarregando => _estaCarregando;
  bool get estaSalvando => _estaSalvando;
  String? get erroUltimaAcao => _erroUltimaAcao;
  Listenable get observavelMovimento => _atualizacaoMovimento;

  AreaRestaurante? get areaSelecionada {
    if (_idAreaSelecionada == null) {
      return _areas.isEmpty ? null : _areas.first;
    }

    for (final area in _areas) {
      if (area.id == _idAreaSelecionada) {
        return area;
      }
    }
    return _areas.isEmpty ? null : _areas.first;
  }

  String? get idMesaEmMovimento => _idMesaEmMovimento;
  String? get idAlvoUniaoSugerida => _idAlvoUniaoSugerida;
  String? get idOrigemUniaoSugerida => _idOrigemUniaoSugerida;

  @override
  void dispose() {
    _atualizacaoMovimento.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    _estaCarregando = true;
    notifyListeners();

    final estado =
        await _repositorio.carregar() ?? _repositorio.construirDadosIniciais();
    _areas = estado.areas;
    _idAreaSelecionada = estado.idAreaSelecionada;
    _estaCarregando = false;
    notifyListeners();
  }

  Future<void> restaurarDadosIniciais() async {
    final estado = _repositorio.construirDadosIniciais();
    _areas = estado.areas;
    _idAreaSelecionada = estado.idAreaSelecionada;
    await _persistir();
    notifyListeners();
  }

  void selecionarArea(String idArea) {
    if (_idAreaSelecionada == idArea) {
      return;
    }

    _idAreaSelecionada = idArea;
    limparSugestaoUniao();
    notifyListeners();
    _persistir();
  }

  SituacaoMesa resolverSituacao(MesaRestaurante mesa) {
    if (mesa.idComandaAtiva != null) {
      return SituacaoMesa.comPedido;
    }

    if ((mesa.pessoasSentadas ?? 0) > 0) {
      if (mesa.ultimoPedidoEm != null) {
        final tempoDecorrido = DateTime.now().difference(mesa.ultimoPedidoEm!);
        if (tempoDecorrido >= const Duration(hours: 1)) {
          return SituacaoMesa.aguardandoLiberacaoHa1H;
        }
        if (tempoDecorrido >= const Duration(minutes: 30)) {
          return SituacaoMesa.semPedidoHa30Min;
        }
      }

      return SituacaoMesa.ocupada;
    }

    return mesa.situacao == SituacaoMesa.atencao
        ? SituacaoMesa.atencao
        : SituacaoMesa.livre;
  }

  List<MesaRestaurante> mesasDoContexto(String idMesa) {
    final mesa = buscarMesaPorId(idMesa);
    if (mesa == null) {
      return const [];
    }

    if (!mesa.estaUnida || mesa.idGrupoUniao == null) {
      return [mesa];
    }

    final area = buscarAreaPorId(mesa.idArea);
    if (area == null) {
      return [mesa];
    }

    return area.mesas
        .where((item) => item.idGrupoUniao == mesa.idGrupoUniao)
        .toList();
  }

  int quantidadeCadeirasGrupo(String idMesa) {
    return mesasDoContexto(
      idMesa,
    ).fold<int>(0, (total, mesa) => total + mesa.quantidadeCadeiras);
  }

  int quantidadePessoasGrupo(String idMesa) {
    return mesasDoContexto(
      idMesa,
    ).fold<int>(0, (total, mesa) => total + (mesa.pessoasSentadas ?? 0));
  }

  int quantidadeItensGrupo(String idMesa) {
    return mesasDoContexto(
      idMesa,
    ).fold<int>(0, (total, mesa) => max(total, mesa.quantidadeItensPedido));
  }

  double totalParcialGrupo(String idMesa) {
    return mesasDoContexto(idMesa).fold<double>(
      0,
      (total, mesa) => max(total, mesa.totalParcial).toDouble(),
    );
  }

  String? nomeClienteGrupo(String idMesa) {
    for (final mesa in mesasDoContexto(idMesa)) {
      if ((mesa.nomeCliente ?? '').trim().isNotEmpty) {
        return mesa.nomeCliente;
      }
    }
    return null;
  }

  DateTime? ultimoPedidoDoContexto(String idMesa) {
    DateTime? maisRecente;
    for (final mesa in mesasDoContexto(idMesa)) {
      if (mesa.ultimoPedidoEm == null) {
        continue;
      }
      if (maisRecente == null || mesa.ultimoPedidoEm!.isAfter(maisRecente)) {
        maisRecente = mesa.ultimoPedidoEm;
      }
    }
    return maisRecente;
  }

  String? idComandaAtivaDoContexto(String idMesa) {
    for (final mesa in mesasDoContexto(idMesa)) {
      if (mesa.idComandaAtiva != null) {
        return mesa.idComandaAtiva;
      }
    }
    return null;
  }

  List<MesaRestaurante> mesasCompativeisParaUniao(String idMesa) {
    final mesa = buscarMesaPorId(idMesa);
    if (mesa == null) {
      return const [];
    }

    final area = buscarAreaPorId(mesa.idArea);
    if (area == null) {
      return const [];
    }

    final candidates = <MesaRestaurante>[];
    final chavesVisitadas = <String>{};

    for (final candidata in area.mesas) {
      if (candidata.id == idMesa) {
        continue;
      }

      final chaveCandidata = candidata.idGrupoUniao ?? candidata.id;
      if (!chavesVisitadas.add(chaveCandidata)) {
        continue;
      }

      if (mesa.idGrupoUniao != null &&
          candidata.idGrupoUniao == mesa.idGrupoUniao) {
        continue;
      }

      if (!_podeUnirContextos(mesa.id, candidata.id)) {
        continue;
      }

      candidates.add(candidata);
    }

    return candidates;
  }

  AreaRestaurante? buscarAreaPorId(String idArea) {
    for (final area in _areas) {
      if (area.id == idArea) {
        return area;
      }
    }
    return null;
  }

  MesaRestaurante? buscarMesaPorId(String idMesa) {
    for (final area in _areas) {
      for (final mesa in area.mesas) {
        if (mesa.id == idMesa) {
          return mesa;
        }
      }
    }
    return null;
  }

  Future<void> salvarMesa(RascunhoMesa rascunho) async {
    final areaAlvo = buscarAreaPorId(rascunho.idArea);
    if (areaAlvo == null) {
      _definirErro('Selecione uma area valida para a mesa.');
      return;
    }

    final codigoNormalizado = rascunho.codigo.trim();
    if (codigoNormalizado.isEmpty) {
      _definirErro('A mesa precisa ter um nome ou codigo.');
      return;
    }
    if (rascunho.quantidadeCadeiras < 1 || rascunho.quantidadeCadeiras > 12) {
      _definirErro('A quantidade de cadeiras deve ficar entre 1 e 12.');
      return;
    }
    if ((rascunho.pessoasSentadas ?? 0) > rascunho.quantidadeCadeiras) {
      _definirErro(
        'Pessoas sentadas nao podem ultrapassar a capacidade da mesa.',
      );
      return;
    }
    if (rascunho.width < _larguraMinimaMesa ||
        rascunho.height < _alturaMinimaMesa) {
      _definirErro('A mesa precisa ter dimensoes minimas para leitura.');
      return;
    }
    if (rascunho.width > _larguraMaximaMesa ||
        rascunho.height > _alturaMaximaMesa) {
      _definirErro('A mesa ultrapassa o tamanho maximo permitido no mapa.');
      return;
    }

    final codigoDuplicado = areaAlvo.mesas.any(
      (mesa) =>
          mesa.id != rascunho.id &&
          mesa.codigo.trim().toLowerCase() == codigoNormalizado.toLowerCase(),
    );
    if (codigoDuplicado) {
      _definirErro('Ja existe uma mesa com esse codigo nessa area.');
      return;
    }

    if (rascunho.id == null) {
      final mesas = [...areaAlvo.mesas];
      final position = _proximaPosicaoDisponivel(
        areaAlvo,
        Size(rascunho.width, rascunho.height),
      );
      mesas.add(
        MesaRestaurante(
          id: 'm${DateTime.now().microsecondsSinceEpoch}',
          codigo: codigoNormalizado,
          idArea: rascunho.idArea,
          x: position.dx,
          y: position.dy,
          width: rascunho.width,
          height: rascunho.height,
          formato: rascunho.formato,
          quantidadeCadeiras: rascunho.quantidadeCadeiras,
          situacao:
              rascunho.pessoasSentadas != null && rascunho.pessoasSentadas! > 0
              ? SituacaoMesa.ocupada
              : SituacaoMesa.livre,
          estaUnida: false,
          pessoasSentadas: rascunho.pessoasSentadas,
          ultimoPedidoEm:
              rascunho.pessoasSentadas != null && rascunho.pessoasSentadas! > 0
              ? DateTime.now()
              : null,
        ),
      );
      _substituirArea(areaAlvo.copiarCom(mesas: mesas));
      await _persistir();
      notifyListeners();
      return;
    }

    AreaRestaurante? areaOrigem;
    MesaRestaurante? current;
    for (final area in _areas) {
      for (final mesa in area.mesas) {
        if (mesa.id == rascunho.id) {
          areaOrigem = area;
          current = mesa;
          break;
        }
      }
      if (current != null) {
        break;
      }
    }

    if (areaOrigem == null || current == null) {
      _definirErro('Nao foi possivel localizar a mesa para edicao.');
      return;
    }

    final areaOrigemValor = areaOrigem;
    final mesaAtual = current;

    if (mesaAtual.estaUnida && rascunho.idArea != mesaAtual.idArea) {
      _definirErro('Separe a mesa antes de mover o grupo para outra area.');
      return;
    }
    if (mesaAtual.idComandaAtiva != null &&
        rascunho.idArea != mesaAtual.idArea) {
      _definirErro('Encerre a comanda antes de mover a mesa para outra area.');
      return;
    }
    if (mesaAtual.idComandaAtiva != null &&
        (rascunho.pessoasSentadas ?? 0) < 1) {
      _definirErro(
        'Mesa com comanda ativa precisa manter ao menos uma pessoa sentada.',
      );
      return;
    }

    final mesaAtualizada = mesaAtual.copiarCom(
      codigo: codigoNormalizado,
      idArea: rascunho.idArea,
      width: rascunho.width,
      height: rascunho.height,
      formato: rascunho.formato,
      quantidadeCadeiras: rascunho.quantidadeCadeiras,
      pessoasSentadas: rascunho.pessoasSentadas,
      situacao: (rascunho.pessoasSentadas ?? 0) > 0
          ? (mesaAtual.idComandaAtiva != null
                ? SituacaoMesa.comPedido
                : SituacaoMesa.ocupada)
          : (mesaAtual.idComandaAtiva != null
                ? SituacaoMesa.comPedido
                : SituacaoMesa.livre),
      ultimoPedidoEm: (rascunho.pessoasSentadas ?? 0) > 0
          ? (mesaAtual.ultimoPedidoEm ?? DateTime.now())
          : mesaAtual.ultimoPedidoEm,
      limparPessoasSentadas: rascunho.pessoasSentadas == null,
    );

    final mesasOrigem = areaOrigemValor.mesas
        .where((mesa) => mesa.id != mesaAtual.id)
        .toList();
    _substituirArea(areaOrigemValor.copiarCom(mesas: mesasOrigem));

    final mesasAlvo = [
      ...areaAlvo.mesas.where((mesa) => mesa.id != mesaAtual.id),
      mesaAtualizada,
    ];
    _substituirArea(areaAlvo.copiarCom(mesas: mesasAlvo));
    await _persistir();
    notifyListeners();
  }

  void iniciarMovimento(String idMesa) {
    _idMesaEmMovimento = idMesa;
    _idOrigemUniaoSugerida = null;
    _idAlvoUniaoSugerida = null;
    notifyListeners();
  }

  void limparSugestaoUniao() {
    _idMesaEmMovimento = null;
    _idAlvoUniaoSugerida = null;
    _idOrigemUniaoSugerida = null;
  }

  Future<void> moverMesa(
    String idMesa,
    Offset delta,
    Size tamanhoCanvas,
  ) async {
    final mesa = buscarMesaPorId(idMesa);
    final area = mesa == null ? null : buscarAreaPorId(mesa.idArea);
    if (mesa == null || area == null) {
      return;
    }

    if (mesa.estaUnida && mesa.idGrupoUniao != null) {
      _moverGrupo(mesa.idGrupoUniao!, delta, tamanhoCanvas);
      return;
    }

    final minX = _margemCanvas;
    final minY = _margemCanvas;
    final maxX = max(minX, tamanhoCanvas.width - mesa.width - _margemCanvas);
    final maxY = max(minY, tamanhoCanvas.height - mesa.height - _margemCanvas);
    final proximoX = (mesa.x + delta.dx).clamp(minX, maxX).toDouble();
    final proximoY = (mesa.y + delta.dy).clamp(minY, maxY).toDouble();

    if ((proximoX - mesa.x).abs() < 0.1 && (proximoY - mesa.y).abs() < 0.1) {
      return;
    }

    final mesaAtualizada = mesa.copiarCom(x: proximoX, y: proximoY);
    final mesasAtualizadas = area.mesas
        .map((item) => item.id == idMesa ? mesaAtualizada : item)
        .toList();

    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
    _atualizarSugestaoUniao(mesaAtualizada);
    _atualizacaoMovimento.value = _atualizacaoMovimento.value + 1;
  }

  Future<void> finalizarMovimento() async {
    final idMesa = _idMesaEmMovimento;
    if (idMesa != null) {
      final mesa = buscarMesaPorId(idMesa);
      if (mesa != null && mesa.estaUnida && mesa.idGrupoUniao != null) {
        _ajustarGrupoAGrade(mesa.idGrupoUniao!);
      } else {
        _ajustarMesaAGrade(idMesa);
      }
    }
    _idMesaEmMovimento = null;
    await _persistir();
    notifyListeners();
  }

  Future<String?> unirMesasSugeridas() async {
    final idOrigem = _idOrigemUniaoSugerida ?? _idMesaEmMovimento;
    final idAlvo = _idAlvoUniaoSugerida;
    if (idOrigem == null || idAlvo == null) {
      return _definirErro('Aproxime duas mesas validas para uniao.');
    }

    return unirMesas(idMesaOrigem: idOrigem, idMesaAlvo: idAlvo);
  }

  Future<String?> unirMesas({
    required String idMesaOrigem,
    required String idMesaAlvo,
  }) async {
    final origem = buscarMesaPorId(idMesaOrigem);
    final alvo = buscarMesaPorId(idMesaAlvo);
    if (origem == null || alvo == null) {
      return _definirErro('Nao foi possivel localizar as mesas para uniao.');
    }
    if (origem.idArea != alvo.idArea) {
      return _definirErro('Mesas de areas diferentes nao podem ser unidas.');
    }

    final area = buscarAreaPorId(origem.idArea);
    if (area == null) {
      return _definirErro('Area da mesa nao encontrada.');
    }

    final idGrupoOrigem = origem.idGrupoUniao;
    final idGrupoAlvo = alvo.idGrupoUniao;
    if (idGrupoOrigem != null && idGrupoOrigem == idGrupoAlvo) {
      return _definirErro('As mesas ja estao no mesmo grupo.');
    }

    if (!_podeUnirContextos(idMesaOrigem, idMesaAlvo)) {
      return _definirErro(
        'As mesas possuem pedidos diferentes e nao podem ser unidas agora.',
      );
    }

    final contextoOrigem = mesasDoContexto(idMesaOrigem);
    final contextoAlvo = mesasDoContexto(idMesaAlvo);
    final tablesMap = <String, MesaRestaurante>{
      for (final mesa in contextoOrigem) mesa.id: mesa,
      for (final mesa in contextoAlvo) mesa.id: mesa,
    };
    final mesasUnificadas = tablesMap.values.toList();

    final idsGruposAnteriores = <String>{
      if (idGrupoOrigem != null) idGrupoOrigem,
      if (idGrupoAlvo != null) idGrupoAlvo,
    };

    final posicoesOriginais = _coletarPosicoesOriginais(
      area,
      mesasUnificadas,
      idsGruposAnteriores,
    );

    final idGrupoUniao = 'jg-${DateTime.now().millisecondsSinceEpoch}';
    final mesaComandaUnificada = _selecionarMesaComanda(mesasUnificadas);

    final mesasAtualizadas = area.mesas.map((mesa) {
      if (!tablesMap.containsKey(mesa.id)) {
        return mesa;
      }

      return mesa.copiarCom(
        estaUnida: true,
        idGrupoUniao: idGrupoUniao,
        idComandaAtiva: mesaComandaUnificada.idComandaAtiva,
        ultimoPedidoEm: mesaComandaUnificada.ultimoPedidoEm,
        nomeCliente: mesaComandaUnificada.nomeCliente,
        quantidadeItensPedido: mesaComandaUnificada.quantidadeItensPedido,
        totalParcial: mesaComandaUnificada.totalParcial,
        situacao: mesaComandaUnificada.idComandaAtiva != null
            ? SituacaoMesa.comPedido
            : (mesa.pessoasSentadas ?? 0) > 0
            ? SituacaoMesa.ocupada
            : SituacaoMesa.livre,
      );
    }).toList();

    final gruposAtualizados = area.gruposUniao
        .where((grupo) => !idsGruposAnteriores.contains(grupo.id))
        .toList();
    gruposAtualizados.add(
      GrupoUniaoMesas(
        id: idGrupoUniao,
        idArea: area.id,
        idsMesas: mesasUnificadas.map((mesa) => mesa.id).toList(),
        posicoesOriginais: posicoesOriginais,
      ),
    );

    final mesasEncaixadas = mesasUnificadas.length == 2
        ? _encaixarMesasUnidas(mesasAtualizadas, idMesaOrigem, idMesaAlvo)
        : mesasAtualizadas;

    _substituirArea(
      area.copiarCom(mesas: mesasEncaixadas, gruposUniao: gruposAtualizados),
    );
    limparSugestaoUniao();
    await _persistir();
    notifyListeners();
    return null;
  }

  Future<String?> separarGrupo(String idGrupo) async {
    AreaRestaurante? area;
    for (final candidata in _areas) {
      if (candidata.gruposUniao.any((grupo) => grupo.id == idGrupo)) {
        area = candidata;
        break;
      }
    }

    if (area == null) {
      return _definirErro('Grupo de mesas nao encontrado.');
    }

    final areaAtual = area;

    final grupo = areaAtual.gruposUniao.firstWhere(
      (grupo) => grupo.id == idGrupo,
      orElse: () => GrupoUniaoMesas(
        id: idGrupo,
        idArea: areaAtual.id,
        idsMesas: const [],
      ),
    );
    final posicoesOriginais = {
      for (final entry in grupo.posicoesOriginais) entry.idMesa: entry,
    };

    final mesasGrupo = areaAtual.mesas
        .where((mesa) => mesa.idGrupoUniao == idGrupo)
        .toList();
    final ancoraComComanda = mesasGrupo.firstWhere(
      (mesa) => mesa.idComandaAtiva != null,
      orElse: () => mesasGrupo.first,
    );

    final mesasAtualizadas = areaAtual.mesas.map((mesa) {
      if (mesa.idGrupoUniao != idGrupo) {
        return mesa;
      }

      final manterComanda = mesa.id == ancoraComComanda.id;
      final original = posicoesOriginais[mesa.id];

      return mesa.copiarCom(
        estaUnida: false,
        limparGrupoUniao: true,
        x: original?.x,
        y: original?.y,
        situacao: manterComanda && ancoraComComanda.idComandaAtiva != null
            ? SituacaoMesa.comPedido
            : (mesa.pessoasSentadas ?? 0) > 0
            ? SituacaoMesa.ocupada
            : SituacaoMesa.livre,
        idComandaAtiva: manterComanda ? ancoraComComanda.idComandaAtiva : null,
        ultimoPedidoEm: manterComanda
            ? ancoraComComanda.ultimoPedidoEm
            : mesa.ultimoPedidoEm,
        nomeCliente: manterComanda ? ancoraComComanda.nomeCliente : null,
        quantidadeItensPedido: manterComanda
            ? ancoraComComanda.quantidadeItensPedido
            : 0,
        totalParcial: manterComanda ? ancoraComComanda.totalParcial : 0,
        limparComandaAtiva: !manterComanda,
        limparNomeCliente: !manterComanda,
      );
    }).toList();

    final gruposAtualizados = areaAtual.gruposUniao
        .where((grupo) => grupo.id != idGrupo)
        .toList();

    _substituirArea(
      areaAtual.copiarCom(
        mesas: mesasAtualizadas,
        gruposUniao: gruposAtualizados,
      ),
    );
    await _persistir();
    notifyListeners();
    return null;
  }

  Future<ResultadoAberturaComandaMesa?> abrirComandaDaMesa(
    String idMesa,
  ) async {
    final mesasContexto = mesasDoContexto(idMesa);
    if (mesasContexto.isEmpty) {
      _definirErro('Mesa nao encontrada para abrir pedido.');
      return null;
    }

    final idContexto =
        mesasContexto.first.idGrupoUniao ?? mesasContexto.first.id;
    final now = DateTime.now();
    if (_idUltimoContextoAberto == idContexto &&
        _ultimaAberturaComandaEm != null &&
        now.difference(_ultimaAberturaComandaEm!) <
            const Duration(milliseconds: 900)) {
      return null;
    }

    _idUltimoContextoAberto = idContexto;
    _ultimaAberturaComandaEm = now;

    final idComandaExistente = idComandaAtivaDoContexto(idMesa);
    if (idComandaExistente != null) {
      return ResultadoAberturaComandaMesa(
        idComanda: idComandaExistente,
        reutilizouComandaExistente: true,
        idsMesas: mesasContexto.map((mesa) => mesa.id).toList(),
      );
    }

    final area = buscarAreaPorId(mesasContexto.first.idArea);
    if (area == null) {
      _definirErro('Area da mesa nao encontrada para abrir pedido.');
      return null;
    }

    final idComanda = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final mesasAtualizadas = area.mesas.map((mesa) {
      if (!mesasContexto.any((mesaContexto) => mesaContexto.id == mesa.id)) {
        return mesa;
      }

      return mesa.copiarCom(
        idComandaAtiva: idComanda,
        ultimoPedidoEm: now,
        situacao: SituacaoMesa.comPedido,
        quantidadeItensPedido: max(mesa.quantidadeItensPedido, 1),
        totalParcial: max(mesa.totalParcial, 0),
        pessoasSentadas: max(mesa.pessoasSentadas ?? 0, 1),
      );
    }).toList();

    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
    await _persistir();
    notifyListeners();

    return ResultadoAberturaComandaMesa(
      idComanda: idComanda,
      reutilizouComandaExistente: false,
      idsMesas: mesasContexto.map((mesa) => mesa.id).toList(),
    );
  }

  Future<void> adicionarItemSimulado(String idMesa) async {
    final mesasContexto = mesasDoContexto(idMesa);
    if (mesasContexto.isEmpty) {
      return;
    }

    final area = buscarAreaPorId(mesasContexto.first.idArea);
    final idComandaAtiva = idComandaAtivaDoContexto(idMesa);
    if (area == null || idComandaAtiva == null) {
      return;
    }

    final now = DateTime.now();
    final proximaQuantidadeItens = quantidadeItensGrupo(idMesa) + 1;
    final proximoTotal = totalParcialGrupo(idMesa) + 24.90;

    final mesasAtualizadas = area.mesas.map((mesa) {
      if (!mesasContexto.any((mesaContexto) => mesaContexto.id == mesa.id)) {
        return mesa;
      }

      return mesa.copiarCom(
        idComandaAtiva: idComandaAtiva,
        ultimoPedidoEm: now,
        situacao: SituacaoMesa.comPedido,
        quantidadeItensPedido: proximaQuantidadeItens,
        totalParcial: proximoTotal,
      );
    }).toList();

    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
    await _persistir();
    notifyListeners();
  }

  Future<void> liberarMesa(String idMesa) async {
    final mesasContexto = mesasDoContexto(idMesa);
    if (mesasContexto.isEmpty) {
      return;
    }

    final area = buscarAreaPorId(mesasContexto.first.idArea);
    if (area == null) {
      return;
    }

    final mesasAtualizadas = area.mesas.map((mesa) {
      if (!mesasContexto.any((mesaContexto) => mesaContexto.id == mesa.id)) {
        return mesa;
      }

      return mesa.copiarCom(
        situacao: SituacaoMesa.livre,
        limparComandaAtiva: true,
        limparUltimoPedido: true,
        limparPessoasSentadas: true,
        limparNomeCliente: true,
        quantidadeItensPedido: 0,
        totalParcial: 0,
      );
    }).toList();

    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
    await _persistir();
    notifyListeners();
  }

  double _ajustarValorAGrade(double value, double interval) {
    return (value / interval).round() * interval;
  }

  void _substituirArea(AreaRestaurante nextArea) {
    _areas = _areas
        .map((area) => area.id == nextArea.id ? nextArea : area)
        .toList(growable: false);
  }

  void _atualizarSugestaoUniao(MesaRestaurante mesaEmMovimento) {
    final area = buscarAreaPorId(mesaEmMovimento.idArea);
    if (area == null || mesaEmMovimento.estaUnida) {
      _idAlvoUniaoSugerida = null;
      _idOrigemUniaoSugerida = null;
      return;
    }

    _atualizarSugestaoUniaoParaMesas(area, [mesaEmMovimento]);
  }

  void _ajustarMesaAGrade(String idMesa) {
    final mesa = buscarMesaPorId(idMesa);
    final area = mesa == null ? null : buscarAreaPorId(mesa.idArea);
    if (mesa == null || area == null) {
      return;
    }

    final mesaAtualizada = mesa.copiarCom(
      x: _ajustarValorAGrade(mesa.x, _intervaloGrade),
      y: _ajustarValorAGrade(mesa.y, _intervaloGrade),
    );
    final mesasAtualizadas = area.mesas
        .map((item) => item.id == idMesa ? mesaAtualizada : item)
        .toList();
    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
    _atualizarSugestaoUniao(mesaAtualizada);
  }

  void _ajustarGrupoAGrade(String idGrupo) {
    AreaRestaurante? area;
    for (final candidata in _areas) {
      if (candidata.mesas.any((mesa) => mesa.idGrupoUniao == idGrupo)) {
        area = candidata;
        break;
      }
    }
    if (area == null) {
      return;
    }

    final mesasAtualizadas = area.mesas.map((mesa) {
      if (mesa.idGrupoUniao != idGrupo) {
        return mesa;
      }

      return mesa.copiarCom(
        x: _ajustarValorAGrade(mesa.x, _intervaloGrade),
        y: _ajustarValorAGrade(mesa.y, _intervaloGrade),
      );
    }).toList();

    _substituirArea(area.copiarCom(mesas: mesasAtualizadas));
  }

  void _moverGrupo(String idGrupo, Offset delta, Size tamanhoCanvas) {
    AreaRestaurante? area;
    List<MesaRestaurante> mesasGrupo = const [];

    for (final candidata in _areas) {
      final matches = candidata.mesas
          .where((mesa) => mesa.idGrupoUniao == idGrupo)
          .toList();
      if (matches.isNotEmpty) {
        area = candidata;
        mesasGrupo = matches;
        break;
      }
    }

    if (area == null || mesasGrupo.length < 2) {
      return;
    }

    final bounds = _limitesGrupo(mesasGrupo);
    final minX = _margemCanvas;
    final minY = _margemCanvas;
    final maxX = max(minX, tamanhoCanvas.width - bounds.width - _margemCanvas);
    final maxY = max(
      minY,
      tamanhoCanvas.height - bounds.height - _margemCanvas,
    );

    final proximaEsquerda = (bounds.left + delta.dx)
        .clamp(minX, maxX)
        .toDouble();
    final proximoTopo = (bounds.top + delta.dy).clamp(minY, maxY).toDouble();
    final deslocamentoAjustado = Offset(
      proximaEsquerda - bounds.left,
      proximoTopo - bounds.top,
    );

    if (deslocamentoAjustado.dx.abs() < 0.1 &&
        deslocamentoAjustado.dy.abs() < 0.1) {
      return;
    }

    final mesasAtualizadas = area.mesas.map((mesa) {
      if (mesa.idGrupoUniao != idGrupo) {
        return mesa;
      }

      return mesa.copiarCom(
        x: mesa.x + deslocamentoAjustado.dx,
        y: mesa.y + deslocamentoAjustado.dy,
      );
    }).toList();

    final areaAtualizada = area.copiarCom(mesas: mesasAtualizadas);
    final mesasGrupoAtualizadas = mesasAtualizadas
        .where((mesa) => mesa.idGrupoUniao == idGrupo)
        .toList();

    _substituirArea(areaAtualizada);
    _atualizarSugestaoUniaoParaMesas(areaAtualizada, mesasGrupoAtualizadas);
    _atualizacaoMovimento.value = _atualizacaoMovimento.value + 1;
  }

  Rect _limitesGrupo(List<MesaRestaurante> mesas) {
    var minX = mesas.first.x;
    var minY = mesas.first.y;
    var maxX = mesas.first.x + mesas.first.width;
    var maxY = mesas.first.y + mesas.first.height;

    for (final mesa in mesas.skip(1)) {
      minX = min(minX, mesa.x);
      minY = min(minY, mesa.y);
      maxX = max(maxX, mesa.x + mesa.width);
      maxY = max(maxY, mesa.y + mesa.height);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _atualizarSugestaoUniaoParaMesas(
    AreaRestaurante area,
    List<MesaRestaurante> mesasEmMovimento,
  ) {
    if (mesasEmMovimento.isEmpty) {
      _idAlvoUniaoSugerida = null;
      _idOrigemUniaoSugerida = null;
      return;
    }

    final ancoraEmMovimento = _selecionarMesaComanda(mesasEmMovimento);
    final idGrupoEmMovimento = ancoraEmMovimento.idGrupoUniao;
    final retanguloMovimento = _limitesGrupo(mesasEmMovimento);

    MesaRestaurante? melhorCandidata;
    double menorDistancia = double.infinity;
    final chavesVisitadas = <String>{};

    for (final candidata in area.mesas) {
      if (candidata.id == ancoraEmMovimento.id) {
        continue;
      }
      if (idGrupoEmMovimento != null &&
          candidata.idGrupoUniao == idGrupoEmMovimento) {
        continue;
      }

      final chaveCandidata = candidata.idGrupoUniao ?? candidata.id;
      if (!chavesVisitadas.add(chaveCandidata)) {
        continue;
      }

      if (!_podeUnirContextos(ancoraEmMovimento.id, candidata.id)) {
        continue;
      }

      final mesasCandidatas = candidata.idGrupoUniao == null
          ? <MesaRestaurante>[candidata]
          : area.mesas
                .where((mesa) => mesa.idGrupoUniao == candidata.idGrupoUniao)
                .toList();

      final distance = _distanciaEntreRetangulos(
        retanguloMovimento,
        _limitesGrupo(mesasCandidatas),
      );
      if (distance < 30 && distance < menorDistancia) {
        menorDistancia = distance;
        melhorCandidata = _selecionarMesaComanda(mesasCandidatas);
      }
    }

    _idAlvoUniaoSugerida = melhorCandidata?.id;
    _idOrigemUniaoSugerida = melhorCandidata == null
        ? null
        : ancoraEmMovimento.id;
  }

  bool _podeUnirContextos(String idMesaOrigem, String idMesaAlvo) {
    final idsComandasAtivas = <String>{
      ...mesasDoContexto(
        idMesaOrigem,
      ).map((mesa) => mesa.idComandaAtiva).whereType<String>(),
      ...mesasDoContexto(
        idMesaAlvo,
      ).map((mesa) => mesa.idComandaAtiva).whereType<String>(),
    };
    return idsComandasAtivas.length <= 1;
  }

  List<PosicaoOriginalMesa> _coletarPosicoesOriginais(
    AreaRestaurante area,
    List<MesaRestaurante> mesas,
    Set<String> groupIds,
  ) {
    final positions = <String, PosicaoOriginalMesa>{};

    for (final grupo in area.gruposUniao) {
      if (!groupIds.contains(grupo.id)) {
        continue;
      }
      for (final entry in grupo.posicoesOriginais) {
        positions[entry.idMesa] = entry;
      }
    }

    for (final mesa in mesas) {
      positions.putIfAbsent(
        mesa.id,
        () => PosicaoOriginalMesa(idMesa: mesa.id, x: mesa.x, y: mesa.y),
      );
    }

    return positions.values.toList();
  }

  MesaRestaurante _selecionarMesaComanda(List<MesaRestaurante> mesas) {
    for (final mesa in mesas) {
      if (mesa.idComandaAtiva != null) {
        return mesa;
      }
    }
    for (final mesa in mesas) {
      if ((mesa.pessoasSentadas ?? 0) > 0) {
        return mesa;
      }
    }
    return mesas.first;
  }

  double _distanciaEntreRetangulos(Rect aRect, Rect bRect) {
    final dx = max(
      0.0,
      max(aRect.left - bRect.right, bRect.left - aRect.right),
    );
    final dy = max(
      0.0,
      max(aRect.top - bRect.bottom, bRect.top - aRect.bottom),
    );
    return sqrt((dx * dx) + (dy * dy));
  }

  Offset _proximaPosicaoDisponivel(AreaRestaurante area, Size tamanhoMesa) {
    const columns = 4;
    const start = _margemCanvas;
    const gap = 34.0;

    for (var index = 0; index < 24; index++) {
      final column = index % columns;
      final row = index ~/ columns;
      final position = Offset(
        start + column * (_larguraMaximaMesa + gap),
        start + row * (_alturaMaximaMesa + gap),
      );
      final proposed = Rect.fromLTWH(
        position.dx,
        position.dy,
        tamanhoMesa.width,
        tamanhoMesa.height,
      ).inflate(18);
      final overlaps = area.mesas.any((mesa) {
        final current = Rect.fromLTWH(
          mesa.x,
          mesa.y,
          mesa.width,
          mesa.height,
        ).inflate(18);
        return proposed.overlaps(current);
      });
      if (!overlaps) {
        return position;
      }
    }

    return Offset(
      start,
      start + (area.mesas.length * (_alturaMinimaMesa + gap)),
    );
  }

  List<MesaRestaurante> _encaixarMesasUnidas(
    List<MesaRestaurante> mesas,
    String idMesaOrigem,
    String idMesaAlvo,
  ) {
    final indiceOrigem = mesas.indexWhere((mesa) => mesa.id == idMesaOrigem);
    final indiceAlvo = mesas.indexWhere((mesa) => mesa.id == idMesaAlvo);
    if (indiceOrigem < 0 || indiceAlvo < 0) {
      return mesas;
    }

    final origem = mesas[indiceOrigem];
    final alvo = mesas[indiceAlvo];
    final centroOrigem = Offset(
      origem.x + (origem.width / 2),
      origem.y + (origem.height / 2),
    );
    final centroAlvo = Offset(
      alvo.x + (alvo.width / 2),
      alvo.y + (alvo.height / 2),
    );

    final deveAgruparHorizontalmente =
        (centroOrigem.dx - centroAlvo.dx).abs() >=
        (centroOrigem.dy - centroAlvo.dy).abs();

    final alvoEncaixado = deveAgruparHorizontalmente
        ? alvo.copiarCom(x: origem.x + origem.width + 18, y: origem.y)
        : alvo.copiarCom(x: origem.x, y: origem.y + origem.height + 18);

    final result = [...mesas];
    result[indiceAlvo] = alvoEncaixado;
    return result;
  }

  String _definirErro(String message) {
    _erroUltimaAcao = message;
    notifyListeners();
    return message;
  }

  Future<void> _persistir() async {
    if (_idAreaSelecionada == null) {
      return;
    }

    _estaSalvando = true;
    notifyListeners();
    await _repositorio.salvar(
      EstadoMapaMesas(idAreaSelecionada: _idAreaSelecionada!, areas: _areas),
    );
    _estaSalvando = false;
    _erroUltimaAcao = null;
    notifyListeners();
  }
}
