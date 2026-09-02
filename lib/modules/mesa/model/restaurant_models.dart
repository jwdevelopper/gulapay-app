enum FormatoMesa { redonda, quadrada, retangular, oval }

enum SituacaoMesa {
  livre,
  ocupada,
  semPedidoHa30Min,
  aguardandoLiberacaoHa1H,
  comPedido,
  atencao,
}

extension on FormatoMesa {
  String get valorPersistencia => switch (this) {
    FormatoMesa.redonda => 'round',
    FormatoMesa.quadrada => 'square',
    FormatoMesa.retangular => 'rectangular',
    FormatoMesa.oval => 'oval',
  };
}

extension on SituacaoMesa {
  String get valorPersistencia => switch (this) {
    SituacaoMesa.livre => 'free',
    SituacaoMesa.ocupada => 'occupied',
    SituacaoMesa.semPedidoHa30Min => 'noOrder30Min',
    SituacaoMesa.aguardandoLiberacaoHa1H => 'awaitingRelease1H',
    SituacaoMesa.comPedido => 'withOrder',
    SituacaoMesa.atencao => 'attention',
  };
}

FormatoMesa _formatoMesaDeValor(String valor) => switch (valor) {
  'round' || 'redonda' => FormatoMesa.redonda,
  'square' || 'quadrada' => FormatoMesa.quadrada,
  'rectangular' || 'retangular' => FormatoMesa.retangular,
  'oval' => FormatoMesa.oval,
  _ => FormatoMesa.retangular,
};

SituacaoMesa _situacaoMesaDeValor(String valor) => switch (valor) {
  'free' || 'livre' => SituacaoMesa.livre,
  'occupied' || 'ocupada' => SituacaoMesa.ocupada,
  'noOrder30Min' || 'semPedidoHa30Min' => SituacaoMesa.semPedidoHa30Min,
  'awaitingRelease1H' ||
  'aguardandoLiberacaoHa1H' => SituacaoMesa.aguardandoLiberacaoHa1H,
  'withOrder' || 'comPedido' => SituacaoMesa.comPedido,
  'attention' || 'atencao' => SituacaoMesa.atencao,
  _ => SituacaoMesa.livre,
};

class MesaRestaurante {
  MesaRestaurante({
    required this.id,
    required this.codigo,
    required this.idArea,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.formato,
    required this.quantidadeCadeiras,
    required this.situacao,
    required this.estaUnida,
    this.idGrupoUniao,
    this.idComandaAtiva,
    this.ultimoPedidoEm,
    this.pessoasSentadas,
    this.nomeCliente,
    this.quantidadeItensPedido = 0,
    this.totalParcial = 0,
  });

  final String id;
  final String codigo;
  final String idArea;
  final double x;
  final double y;
  final double width;
  final double height;
  final FormatoMesa formato;
  final int quantidadeCadeiras;
  final SituacaoMesa situacao;
  final bool estaUnida;
  final String? idGrupoUniao;
  final String? idComandaAtiva;
  final DateTime? ultimoPedidoEm;
  final int? pessoasSentadas;
  final String? nomeCliente;
  final int quantidadeItensPedido;
  final double totalParcial;

  MesaRestaurante copiarCom({
    String? id,
    String? codigo,
    String? idArea,
    double? x,
    double? y,
    double? width,
    double? height,
    FormatoMesa? formato,
    int? quantidadeCadeiras,
    SituacaoMesa? situacao,
    bool? estaUnida,
    String? idGrupoUniao,
    String? idComandaAtiva,
    DateTime? ultimoPedidoEm,
    int? pessoasSentadas,
    String? nomeCliente,
    int? quantidadeItensPedido,
    double? totalParcial,
    bool limparGrupoUniao = false,
    bool limparComandaAtiva = false,
    bool limparUltimoPedido = false,
    bool limparPessoasSentadas = false,
    bool limparNomeCliente = false,
  }) {
    return MesaRestaurante(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      idArea: idArea ?? this.idArea,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      formato: formato ?? this.formato,
      quantidadeCadeiras: quantidadeCadeiras ?? this.quantidadeCadeiras,
      situacao: situacao ?? this.situacao,
      estaUnida: estaUnida ?? this.estaUnida,
      idGrupoUniao: limparGrupoUniao
          ? null
          : (idGrupoUniao ?? this.idGrupoUniao),
      idComandaAtiva: limparComandaAtiva
          ? null
          : (idComandaAtiva ?? this.idComandaAtiva),
      ultimoPedidoEm: limparUltimoPedido
          ? null
          : (ultimoPedidoEm ?? this.ultimoPedidoEm),
      pessoasSentadas: limparPessoasSentadas
          ? null
          : (pessoasSentadas ?? this.pessoasSentadas),
      nomeCliente: limparNomeCliente ? null : (nomeCliente ?? this.nomeCliente),
      quantidadeItensPedido:
          quantidadeItensPedido ?? this.quantidadeItensPedido,
      totalParcial: totalParcial ?? this.totalParcial,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'code': codigo,
      'areaId': idArea,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'shape': formato.valorPersistencia,
      'chairsCount': quantidadeCadeiras,
      'status': situacao.valorPersistencia,
      'isJoined': estaUnida,
      'joinGroupId': idGrupoUniao,
      'activeOrderId': idComandaAtiva,
      'lastOrderAt': ultimoPedidoEm?.toIso8601String(),
      'seatedPeople': pessoasSentadas,
      'customerName': nomeCliente,
      'orderItemsCount': quantidadeItensPedido,
      'partialTotal': totalParcial,
    };
  }

  factory MesaRestaurante.deMapa(Map<String, dynamic> map) {
    return MesaRestaurante(
      id: map['id'] as String,
      codigo: map['code'] as String,
      idArea: map['areaId'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      formato: _formatoMesaDeValor(map['shape'] as String),
      quantidadeCadeiras: map['chairsCount'] as int,
      situacao: _situacaoMesaDeValor(map['status'] as String),
      estaUnida: map['isJoined'] as bool? ?? false,
      idGrupoUniao: map['joinGroupId'] as String?,
      idComandaAtiva: map['activeOrderId'] as String?,
      ultimoPedidoEm: map['lastOrderAt'] == null
          ? null
          : DateTime.parse(map['lastOrderAt'] as String),
      pessoasSentadas: map['seatedPeople'] as int?,
      nomeCliente: map['customerName'] as String?,
      quantidadeItensPedido: map['orderItemsCount'] as int? ?? 0,
      totalParcial: (map['partialTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GrupoUniaoMesas {
  GrupoUniaoMesas({
    required this.id,
    required this.idArea,
    required this.idsMesas,
    this.posicoesOriginais = const <PosicaoOriginalMesa>[],
  });

  final String id;
  final String idArea;
  final List<String> idsMesas;
  final List<PosicaoOriginalMesa> posicoesOriginais;

  GrupoUniaoMesas copiarCom({
    String? id,
    String? idArea,
    List<String>? idsMesas,
    List<PosicaoOriginalMesa>? posicoesOriginais,
  }) {
    return GrupoUniaoMesas(
      id: id ?? this.id,
      idArea: idArea ?? this.idArea,
      idsMesas: idsMesas ?? this.idsMesas,
      posicoesOriginais: posicoesOriginais ?? this.posicoesOriginais,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'areaId': idArea,
      'tableIds': idsMesas,
      'originalPositions': posicoesOriginais
          .map((position) => position.paraMapa())
          .toList(),
    };
  }

  factory GrupoUniaoMesas.deMapa(Map<String, dynamic> map) {
    return GrupoUniaoMesas(
      id: map['id'] as String,
      idArea: map['areaId'] as String,
      idsMesas: List<String>.from(map['tableIds'] as List<dynamic>),
      posicoesOriginais:
          (map['originalPositions'] as List<dynamic>? ?? const [])
              .map(
                (entry) => PosicaoOriginalMesa.deMapa(
                  Map<String, dynamic>.from(entry as Map),
                ),
              )
              .toList(),
    );
  }
}

class PosicaoOriginalMesa {
  PosicaoOriginalMesa({required this.idMesa, required this.x, required this.y});

  final String idMesa;
  final double x;
  final double y;

  PosicaoOriginalMesa copiarCom({String? idMesa, double? x, double? y}) {
    return PosicaoOriginalMesa(
      idMesa: idMesa ?? this.idMesa,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {'tableId': idMesa, 'x': x, 'y': y};
  }

  factory PosicaoOriginalMesa.deMapa(Map<String, dynamic> map) {
    return PosicaoOriginalMesa(
      idMesa: map['tableId'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}

class AreaRestaurante {
  AreaRestaurante({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.mesas,
    this.gruposUniao = const <GrupoUniaoMesas>[],
  });

  final String id;
  final String nome;
  final String tipo;
  final List<MesaRestaurante> mesas;
  final List<GrupoUniaoMesas> gruposUniao;

  int get quantidadeOcupadas => mesas
      .where(
        (mesa) =>
            mesa.idComandaAtiva != null || (mesa.pessoasSentadas ?? 0) > 0,
      )
      .length;

  int get totalMesas => mesas.length;

  AreaRestaurante copiarCom({
    String? id,
    String? nome,
    String? tipo,
    List<MesaRestaurante>? mesas,
    List<GrupoUniaoMesas>? gruposUniao,
  }) {
    return AreaRestaurante(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      mesas: mesas ?? this.mesas,
      gruposUniao: gruposUniao ?? this.gruposUniao,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'name': nome,
      'type': tipo,
      'tables': mesas.map((mesa) => mesa.paraMapa()).toList(),
      'joinGroups': gruposUniao.map((grupo) => grupo.paraMapa()).toList(),
    };
  }

  factory AreaRestaurante.deMapa(Map<String, dynamic> map) {
    return AreaRestaurante(
      id: map['id'] as String,
      nome: map['name'] as String,
      tipo: map['type'] as String,
      mesas: (map['tables'] as List<dynamic>)
          .map(
            (mesa) =>
                MesaRestaurante.deMapa(Map<String, dynamic>.from(mesa as Map)),
          )
          .toList(),
      gruposUniao: (map['joinGroups'] as List<dynamic>? ?? const [])
          .map(
            (grupo) =>
                GrupoUniaoMesas.deMapa(Map<String, dynamic>.from(grupo as Map)),
          )
          .toList(),
    );
  }
}

class EstadoMapaMesas {
  EstadoMapaMesas({required this.idAreaSelecionada, required this.areas});

  final String idAreaSelecionada;
  final List<AreaRestaurante> areas;

  Map<String, dynamic> paraMapa() {
    return {
      'selectedAreaId': idAreaSelecionada,
      'areas': areas.map((area) => area.paraMapa()).toList(),
    };
  }

  factory EstadoMapaMesas.deMapa(Map<String, dynamic> map) {
    return EstadoMapaMesas(
      idAreaSelecionada: map['selectedAreaId'] as String,
      areas: (map['areas'] as List<dynamic>)
          .map(
            (area) =>
                AreaRestaurante.deMapa(Map<String, dynamic>.from(area as Map)),
          )
          .toList(),
    );
  }
}
