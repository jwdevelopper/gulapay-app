import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_node.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class CanvasMapaMesas extends StatefulWidget {
  const CanvasMapaMesas({
    super.key,
    required this.area,
    required this.controlador,
    required this.modoEdicao,
    required this.aoAlternarModoEdicao,
    required this.aoAdicionarMesa,
    required this.aoUnirSugeridas,
    required this.aoEditarMesa,
    required this.aoAbrirMesa,
    required this.aoAbrirComanda,
    this.raioBorda = 24,
  });

  final AreaRestaurante area;
  final ControladorMapaMesas controlador;
  final bool modoEdicao;
  final VoidCallback aoAlternarModoEdicao;
  final VoidCallback aoAdicionarMesa;
  final VoidCallback aoUnirSugeridas;
  final ValueChanged<MesaRestaurante> aoEditarMesa;
  final ValueChanged<MesaRestaurante> aoAbrirMesa;
  final ValueChanged<MesaRestaurante> aoAbrirComanda;
  final double raioBorda;

  @override
  State<CanvasMapaMesas> createState() => _CanvasMapaMesasState();
}

class _CanvasMapaMesasState extends State<CanvasMapaMesas> {
  late final TransformationController _controleTransformacao;
  late final Listenable _observavelReconstrucao;
  double _escala = 1;
  String? _idGrupoSelecionado;
  String? _idMesaOperacionalSelecionada;

  @override
  void initState() {
    super.initState();
    _controleTransformacao = TransformationController();
    _controleTransformacao.addListener(_sincronizarEscalaDaMatriz);
    _observavelReconstrucao = Listenable.merge([
      widget.controlador,
      widget.controlador.observavelMovimento,
    ]);
  }

  @override
  void dispose() {
    _controleTransformacao.removeListener(_sincronizarEscalaDaMatriz);
    _controleTransformacao.dispose();
    super.dispose();
  }

  void _sincronizarEscalaDaMatriz() {
    final proximaEscala = _controleTransformacao.value.getMaxScaleOnAxis();
    if ((proximaEscala - _escala).abs() < 0.01) {
      if (_idMesaOperacionalSelecionada != null) {
        setState(() {});
      }
      return;
    }
    setState(() {
      _escala = proximaEscala;
    });
  }

  void _definirEscala(double value) {
    setState(() {
      _escala = value.clamp(0.62, 1.45).toDouble();
      final matriz = _controleTransformacao.value.clone();
      matriz.setIdentity();
      matriz.setEntry(0, 0, _escala);
      matriz.setEntry(1, 1, _escala);
      _controleTransformacao.value = matriz;
    });
  }

  @override
  void didUpdateWidget(covariant CanvasMapaMesas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.modoEdicao && _idGrupoSelecionado != null) {
      setState(() {
        _idGrupoSelecionado = null;
      });
    } else if (oldWidget.area.id != widget.area.id &&
        _idGrupoSelecionado != null) {
      setState(() {
        _idGrupoSelecionado = null;
      });
    }

    if (widget.modoEdicao || oldWidget.area.id != widget.area.id) {
      _idMesaOperacionalSelecionada = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _observavelReconstrucao,
      builder: (context, _) {
        final area =
            widget.controlador.buscarAreaPorId(widget.area.id) ?? widget.area;
        final mesasGrupoSelecionado = _idGrupoSelecionado == null
            ? const <MesaRestaurante>[]
            : area.mesas
                  .where((mesa) => mesa.idGrupoUniao == _idGrupoSelecionado)
                  .toList();
        final showUnmixBar =
            widget.modoEdicao && mesasGrupoSelecionado.length > 1;

        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = max(920.0, constraints.maxWidth);
            final canvasHeight = max(640.0, constraints.maxHeight);
            final tamanhoCanvas = Size(canvasWidth, canvasHeight);
            final overlayCompact = constraints.maxWidth < 520;
            final mesaOperacionalSelecionada =
                _idMesaOperacionalSelecionada == null
                ? null
                : area.mesas.cast<MesaRestaurante?>().firstWhere(
                    (mesa) => mesa!.id == _idMesaOperacionalSelecionada,
                    orElse: () => null,
                  );

            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.raioBorda),
              child: Container(
                decoration: BoxDecoration(
                  color: GulaColors.canvas,
                  borderRadius: BorderRadius.circular(widget.raioBorda),
                  border: widget.raioBorda == 0
                      ? null
                      : Border.all(color: GulaColors.border),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _controleTransformacao,
                        alignment: Alignment.topLeft,
                        boundaryMargin: const EdgeInsets.all(180),
                        constrained: false,
                        panEnabled:
                            widget.controlador.idMesaEmMovimento == null,
                        scaleEnabled:
                            widget.controlador.idMesaEmMovimento == null,
                        minScale: 0.62,
                        maxScale: 1.45,
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: tamanhoCanvas,
                                painter: _PintorPlantaRestaurante(
                                  tipoArea: area.tipo,
                                ),
                              ),
                              ..._construirElementosMesa(area, tamanhoCanvas),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _ControlesCanvas(
                        aoDiminuirZoom: () => _definirEscala(_escala - 0.12),
                        aoAumentarZoom: () => _definirEscala(_escala + 0.12),
                        aoRestaurarZoom: () => _definirEscala(1),
                        compacto: overlayCompact,
                      ),
                    ),
                    if (widget.controlador.idAlvoUniaoSugerida != null)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _AvisoSugestaoUniao(
                          aoUnir: widget.aoUnirSugeridas,
                        ),
                      ),
                    Positioned(
                      right: 12,
                      bottom: 76,
                      child: IgnorePointer(
                        ignoring: !showUnmixBar,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          opacity: showUnmixBar ? 1 : 0,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            offset: showUnmixBar
                                ? Offset.zero
                                : const Offset(0, 0.3),
                            child: _BarraFlutuanteSeparacao(
                              quantidadeMesas: mesasGrupoSelecionado.length,
                              aoDesfazerUniao: () =>
                                  _tratarSeparacaoGrupo(_idGrupoSelecionado!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _BotaoModoLayout(
                        ativo: widget.modoEdicao,
                        aoPressionar: widget.aoAlternarModoEdicao,
                        aoAdicionarMesa: widget.aoAdicionarMesa,
                        compacto: overlayCompact,
                      ),
                    ),
                    if (!widget.modoEdicao &&
                        mesaOperacionalSelecionada != null)
                      _construirResumoRapido(
                        mesaOperacionalSelecionada,
                        constraints.biggest,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _construirElementosMesa(
    AreaRestaurante area,
    Size tamanhoCanvas,
  ) {
    final gruposPorId = <String, List<MesaRestaurante>>{};
    final mesasIndividuais = <MesaRestaurante>[];

    for (final mesa in area.mesas) {
      if (mesa.estaUnida && mesa.idGrupoUniao != null) {
        gruposPorId
            .putIfAbsent(mesa.idGrupoUniao!, () => <MesaRestaurante>[])
            .add(mesa);
      } else {
        mesasIndividuais.add(mesa);
      }
    }

    for (final entry in gruposPorId.entries) {
      if (entry.value.length == 1) {
        mesasIndividuais.add(entry.value.first);
      }
    }

    final nodes = <Widget>[];

    for (final entry in gruposPorId.entries) {
      if (entry.value.length < 2) {
        continue;
      }
      final uniaoSugerida = entry.value.any(
        (mesa) => widget.controlador.idAlvoUniaoSugerida == mesa.id,
      );
      final selecionada = entry.key == _idGrupoSelecionado;
      nodes.add(
        _construirElementoGrupoUnido(
          area: area,
          idGrupo: entry.key,
          mesas: entry.value,
          tamanhoCanvas: tamanhoCanvas,
          uniaoSugerida: uniaoSugerida,
          selecionada: selecionada,
        ),
      );
    }

    nodes.addAll(
      mesasIndividuais.map((mesa) {
        return Positioned(
          left: mesa.x,
          top: mesa.y,
          child: ElementoMesa(
            mesa: mesa,
            nomeArea: area.nome,
            situacao: widget.controlador.resolverSituacao(mesa),
            emMovimento: widget.controlador.idMesaEmMovimento == mesa.id,
            uniaoSugerida:
                widget.controlador.idAlvoUniaoSugerida == mesa.id ||
                widget.controlador.idMesaEmMovimento == mesa.id,
            podeArrastar: widget.modoEdicao,
            ultimoEventoEm: widget.controlador.ultimoPedidoDoContexto(mesa.id),
            aoTocar: () => widget.modoEdicao
                ? _selecionarGrupo(null, () => widget.aoEditarMesa(mesa))
                : _selecionarMesaOperacional(mesa),
            aoToqueDuplo: () {
              if (!widget.modoEdicao) {
                widget.aoAbrirComanda(mesa);
              }
            },
            aoIniciarArraste: () => _selecionarGrupo(null, () {
              widget.controlador.iniciarMovimento(mesa.id);
            }),
            aoAtualizarArraste: (delta) => widget.controlador.moverMesa(
              mesa.id,
              delta / _escala,
              tamanhoCanvas,
            ),
            aoFinalizarArraste: widget.controlador.finalizarMovimento,
          ),
        );
      }),
    );

    return nodes;
  }

  Widget _construirElementoGrupoUnido({
    required AreaRestaurante area,
    required String idGrupo,
    required List<MesaRestaurante> mesas,
    required Size tamanhoCanvas,
    required bool uniaoSugerida,
    required bool selecionada,
  }) {
    final sorted = [...mesas]..sort((a, b) => a.codigo.compareTo(b.codigo));
    final anchor = _mesaAncora(sorted);
    final bounds = _limitesGrupo(sorted);
    final situacaoGrupo = _resolverSituacaoGrupo(sorted);
    final groupLabel = _rotuloGrupo(sorted);
    final cadeirasGrupo = sorted.fold<int>(
      0,
      (sum, mesa) => sum + mesa.quantidadeCadeiras,
    );
    final emMovimento = sorted.any(
      (mesa) => widget.controlador.idMesaEmMovimento == mesa.id,
    );

    final mergedTable = MesaRestaurante(
      id: idGrupo,
      codigo: groupLabel,
      idArea: area.id,
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      formato: FormatoMesa.retangular,
      quantidadeCadeiras: cadeirasGrupo,
      situacao: situacaoGrupo,
      estaUnida: true,
      idGrupoUniao: idGrupo,
      idComandaAtiva: anchor.idComandaAtiva,
      ultimoPedidoEm: anchor.ultimoPedidoEm,
      pessoasSentadas: anchor.pessoasSentadas,
      nomeCliente: anchor.nomeCliente,
      quantidadeItensPedido: anchor.quantidadeItensPedido,
      totalParcial: anchor.totalParcial,
    );

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      child: ElementoMesa(
        mesa: mergedTable,
        nomeArea: area.nome,
        situacao: situacaoGrupo,
        emMovimento: emMovimento,
        uniaoSugerida: uniaoSugerida || selecionada,
        podeArrastar: widget.modoEdicao,
        ultimoEventoEm: widget.controlador.ultimoPedidoDoContexto(anchor.id),
        aoTocar: () => widget.modoEdicao
            ? _selecionarGrupo(idGrupo, () => widget.aoEditarMesa(anchor))
            : _selecionarMesaOperacional(anchor),
        aoToqueDuplo: () {
          if (!widget.modoEdicao) {
            widget.aoAbrirComanda(anchor);
          }
        },
        aoIniciarArraste: () => _selecionarGrupo(idGrupo, () {
          widget.controlador.iniciarMovimento(anchor.id);
        }),
        aoAtualizarArraste: (delta) => widget.controlador.moverMesa(
          anchor.id,
          delta / _escala,
          tamanhoCanvas,
        ),
        aoFinalizarArraste: widget.controlador.finalizarMovimento,
      ),
    );
  }

  void _selecionarMesaOperacional(MesaRestaurante mesa) {
    setState(() {
      _idMesaOperacionalSelecionada = mesa.id;
    });
  }

  Widget _construirResumoRapido(MesaRestaurante mesa, Size tamanhoAreaVisivel) {
    const preferredWidth = 258.0;
    const alturaPreferida = 172.0;
    const margin = 12.0;

    final posicaoCena = MatrixUtils.transformPoint(
      _controleTransformacao.value,
      Offset(mesa.x, mesa.y),
    );
    final larguraDisponivel = max(0.0, tamanhoAreaVisivel.width - (margin * 2));
    final larguraResumo = min(preferredWidth, larguraDisponivel);
    final centroHorizontalMesa = posicaoCena.dx + (mesa.width / 2);
    final prefereDireita = centroHorizontalMesa < tamanhoAreaVisivel.width / 2;
    final preferredLeft = prefereDireita
        ? posicaoCena.dx + mesa.width + margin
        : posicaoCena.dx - larguraResumo - margin;
    final left = preferredLeft
        .clamp(
          margin,
          max(margin, tamanhoAreaVisivel.width - larguraResumo - margin),
        )
        .toDouble();
    final top = (posicaoCena.dy + (mesa.height / 2) - (alturaPreferida / 2))
        .clamp(
          margin,
          max(margin, tamanhoAreaVisivel.height - alturaPreferida - margin),
        )
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      width: larguraResumo,
      child: _ResumoRapidoMesa(
        mesa: mesa,
        situacao: widget.controlador.resolverSituacao(mesa),
        quantidadeItens: widget.controlador.quantidadeItensGrupo(mesa.id),
        totalParcial: widget.controlador.totalParcialGrupo(mesa.id),
        ultimoPedidoEm: widget.controlador.ultimoPedidoDoContexto(mesa.id),
        temComandaAtiva:
            widget.controlador.idComandaAtivaDoContexto(mesa.id) != null,
        aoAbrirComanda: () => widget.aoAbrirComanda(mesa),
        aoVerDetalhes: () => widget.aoAbrirMesa(mesa),
        aoFechar: () => setState(() => _idMesaOperacionalSelecionada = null),
      ),
    );
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

  MesaRestaurante _mesaAncora(List<MesaRestaurante> mesas) {
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

  String _rotuloGrupo(List<MesaRestaurante> mesas) {
    if (mesas.length == 2) {
      return '${mesas[0].codigo} + ${mesas[1].codigo}';
    }
    final extra = mesas.length - 1;
    return '${mesas[0].codigo} + $extra mesas';
  }

  SituacaoMesa _resolverSituacaoGrupo(List<MesaRestaurante> mesas) {
    final situacoes = mesas
        .map((mesa) => widget.controlador.resolverSituacao(mesa))
        .toList();

    if (situacoes.contains(SituacaoMesa.comPedido)) {
      return SituacaoMesa.comPedido;
    }
    if (situacoes.contains(SituacaoMesa.aguardandoLiberacaoHa1H)) {
      return SituacaoMesa.aguardandoLiberacaoHa1H;
    }
    if (situacoes.contains(SituacaoMesa.semPedidoHa30Min)) {
      return SituacaoMesa.semPedidoHa30Min;
    }
    if (situacoes.contains(SituacaoMesa.ocupada)) {
      return SituacaoMesa.ocupada;
    }
    if (situacoes.contains(SituacaoMesa.atencao)) {
      return SituacaoMesa.atencao;
    }
    return SituacaoMesa.livre;
  }

  Future<void> _tratarSeparacaoGrupo(String idGrupo) async {
    final error = await widget.controlador.separarGrupo(idGrupo);
    if (!mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_idGrupoSelecionado == idGrupo) {
      setState(() {
        _idGrupoSelecionado = null;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mistura desfeita com sucesso.')),
    );
  }

  void _selecionarGrupo(String? idGrupo, VoidCallback acao) {
    if (widget.modoEdicao && _idGrupoSelecionado != idGrupo) {
      setState(() {
        _idGrupoSelecionado = idGrupo;
      });
    } else if (!widget.modoEdicao && _idGrupoSelecionado != null) {
      setState(() {
        _idGrupoSelecionado = null;
      });
    }
    acao();
  }
}

class _BarraFlutuanteSeparacao extends StatelessWidget {
  const _BarraFlutuanteSeparacao({
    required this.quantidadeMesas,
    required this.aoDesfazerUniao,
  });

  final int quantidadeMesas;
  final VoidCallback aoDesfazerUniao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.call_split_rounded,
            size: 18,
            color: GulaColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Desfazer ($quantidadeMesas)',
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: aoDesfazerUniao,
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Desfazer'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoRapidoMesa extends StatelessWidget {
  const _ResumoRapidoMesa({
    required this.mesa,
    required this.situacao,
    required this.quantidadeItens,
    required this.totalParcial,
    required this.ultimoPedidoEm,
    required this.temComandaAtiva,
    required this.aoAbrirComanda,
    required this.aoVerDetalhes,
    required this.aoFechar,
  });

  final MesaRestaurante mesa;
  final SituacaoMesa situacao;
  final int quantidadeItens;
  final double totalParcial;
  final DateTime? ultimoPedidoEm;
  final bool temComandaAtiva;
  final VoidCallback aoAbrirComanda;
  final VoidCallback aoVerDetalhes;
  final VoidCallback aoFechar;

  @override
  Widget build(BuildContext context) {
    final orderLabel = temComandaAtiva
        ? 'Pedido ${mesa.idComandaAtiva?.replaceFirst('ORD-', '#') ?? ''}'
        : 'Mesa disponível';

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: GulaColors.surfaceAlt.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: corSituacaoMesa(situacao).withValues(alpha: 0.82),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mesa.codigo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: GulaColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IndicadorSituacaoMesa(situacao: situacao, compacto: true),
                const SizedBox(width: 2),
                IconButton(
                  tooltip: 'Fechar resumo',
                  onPressed: aoFechar,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              orderLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GulaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _DadoRapido(
                  icone: Icons.schedule_outlined,
                  rotulo: _formatarTempoDecorrido(ultimoPedidoEm),
                ),
                _DadoRapido(
                  icone: Icons.receipt_long_outlined,
                  rotulo:
                      '$quantidadeItens item${quantidadeItens == 1 ? '' : 's'}',
                ),
                Text(
                  'R\$ ${totalParcial.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: GulaColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: aoAbrirComanda,
                    icon: Icon(
                      temComandaAtiva
                          ? Icons.receipt_long_outlined
                          : Icons.add_shopping_cart_outlined,
                      size: 16,
                    ),
                    label: Text(
                      temComandaAtiva ? 'Ver comanda' : 'Abrir pedido',
                    ),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Detalhes da mesa',
                  onPressed: aoVerDetalhes,
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatarTempoDecorrido(DateTime? value) {
    if (value == null) {
      return 'sem tempo';
    }
    final tempoDecorrido = DateTime.now().difference(value);
    if (tempoDecorrido.inMinutes < 1) {
      return 'agora';
    }
    if (tempoDecorrido.inMinutes < 60) {
      return '${tempoDecorrido.inMinutes} min';
    }
    return '${tempoDecorrido.inHours} h';
  }
}

class _DadoRapido extends StatelessWidget {
  const _DadoRapido({required this.icone, required this.rotulo});

  final IconData icone;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: GulaColors.textMuted),
        const SizedBox(width: 4),
        Text(
          rotulo,
          style: const TextStyle(
            color: GulaColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BotaoModoLayout extends StatelessWidget {
  const _BotaoModoLayout({
    required this.ativo,
    required this.aoPressionar,
    required this.aoAdicionarMesa,
    required this.compacto,
  });

  final bool ativo;
  final VoidCallback aoPressionar;
  final VoidCallback aoAdicionarMesa;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ativo ? GulaColors.primary : GulaColors.border,
          width: ativo ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ativo)
            IconButton(
              tooltip: 'Nova mesa',
              onPressed: aoAdicionarMesa,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: GulaColors.primary,
                fixedSize: Size(compacto ? 34 : 38, compacto ? 34 : 38),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          FilledButton.icon(
            onPressed: aoPressionar,
            icon: Icon(
              ativo ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              size: compacto ? 16 : 18,
            ),
            label: Text(ativo ? 'Layout ativo' : 'Modo layout'),
            style: FilledButton.styleFrom(
              backgroundColor: ativo ? GulaColors.primary : GulaColors.surface,
              foregroundColor: ativo ? Colors.white : GulaColors.text,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(
                horizontal: compacto ? 10 : 12,
                vertical: compacto ? 9 : 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlesCanvas extends StatelessWidget {
  const _ControlesCanvas({
    required this.aoDiminuirZoom,
    required this.aoAumentarZoom,
    required this.aoRestaurarZoom,
    this.compacto = false,
  });

  final VoidCallback aoDiminuirZoom;
  final VoidCallback aoAumentarZoom;
  final VoidCallback aoRestaurarZoom;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compacto ? 3 : 4),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: compacto ? 10 : 14,
            offset: Offset(0, compacto ? 5 : 7),
          ),
        ],
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          _BotaoControle(
            dica: 'Diminuir zoom',
            icone: Icons.remove_rounded,
            aoPressionar: aoDiminuirZoom,
            compacto: compacto,
          ),
          _BotaoControle(
            dica: 'Restaurar zoom',
            icone: Icons.center_focus_strong_outlined,
            aoPressionar: aoRestaurarZoom,
            compacto: compacto,
          ),
          _BotaoControle(
            dica: 'Aumentar zoom',
            icone: Icons.add_rounded,
            aoPressionar: aoAumentarZoom,
            compacto: compacto,
          ),
        ],
      ),
    );
  }
}

class _BotaoControle extends StatelessWidget {
  const _BotaoControle({
    required this.dica,
    required this.icone,
    required this.aoPressionar,
    this.compacto = false,
  });

  final String dica;
  final IconData icone;
  final VoidCallback aoPressionar;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dica,
      child: IconButton(
        onPressed: aoPressionar,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: GulaColors.text,
          fixedSize: Size(compacto ? 32 : 38, compacto ? 32 : 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compacto ? 11 : 13),
          ),
        ),
        icon: Icon(icone, size: compacto ? 17 : 19),
      ),
    );
  }
}

class _AvisoSugestaoUniao extends StatelessWidget {
  const _AvisoSugestaoUniao({required this.aoUnir});

  final VoidCallback aoUnir;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: GulaColors.surfaceAlt.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GulaColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 18, color: GulaColors.primary),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Mesa proxima detectada.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonalIcon(
              onPressed: aoUnir,
              icon: const Icon(Icons.call_merge_rounded, size: 18),
              label: const Text('Unir'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PintorPlantaRestaurante extends CustomPainter {
  const _PintorPlantaRestaurante({required this.tipoArea});

  final String tipoArea;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = GulaColors.canvas;
    canvas.drawRect(Offset.zero & size, basePaint);

    _desenharTexturaPiso(canvas, size);
    _desenharGrade(canvas, size);
    _desenharParedes(canvas, size);
    _desenharElementosArea(canvas, size);
  }

  void _desenharTexturaPiso(Canvas canvas, Size size) {
    final plankPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    final linePaint = Paint()
      ..color = GulaColors.borderSoft.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    const plankHeight = 34.0;
    for (double y = 0; y < size.height; y += plankHeight) {
      final shift = ((y / plankHeight).round().isEven) ? 0.0 : 42.0;
      for (double x = -shift; x < size.width; x += 132) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 132, plankHeight),
            const Radius.circular(2),
          ),
          plankPaint,
        );
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _desenharGrade(Canvas canvas, Size size) {
    final fineLine = Paint()
      ..color = GulaColors.borderSoft.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const gap = 24.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fineLine);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fineLine);
    }
  }

  void _desenharParedes(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = GulaColors.text.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final wallRect = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, const Radius.circular(24)),
      wallPaint,
    );

    final doorPaint = Paint()
      ..color = GulaColors.canvas
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.44, size.height - 12),
      Offset(size.width * 0.58, size.height - 12),
      doorPaint,
    );
    _desenharRotulo(
      canvas,
      'Entrada',
      Offset(size.width * 0.46, size.height - 46),
    );
  }

  void _desenharElementosArea(Canvas canvas, Size size) {
    final counterColor = GulaColors.textMuted.withValues(alpha: 0.18);
    final greenColor = const Color(0xFF8DAA91).withValues(alpha: 0.22);
    final glassColor = const Color(0xFF87A7B2).withValues(alpha: 0.2);

    switch (tipoArea) {
      case 'externo':
        _desenharElemento(
          canvas,
          Rect.fromLTWH(54, 42, size.width - 108, 38),
          'Cobertura',
          glassColor,
        );
        _desenharElemento(
          canvas,
          Rect.fromLTWH(size.width - 136, 110, 64, 360),
          'Jardim',
          greenColor,
          rotuloVertical: true,
        );
        break;
      case 'premium':
        _desenharElemento(
          canvas,
          Rect.fromLTWH(62, 56, 180, 58),
          'Recepcao VIP',
          counterColor,
        );
        _desenharElemento(
          canvas,
          Rect.fromLTWH(size.width - 178, 72, 76, 420),
          'Adega',
          const Color(0xFF7E6B8E).withValues(alpha: 0.2),
          rotuloVertical: true,
        );
        break;
      default:
        _desenharElemento(
          canvas,
          Rect.fromLTWH(size.width - 210, 64, 146, 78),
          'Caixa',
          counterColor,
        );
        _desenharElemento(
          canvas,
          Rect.fromLTWH(size.width - 192, 184, 112, 270),
          'Copa',
          counterColor,
          rotuloVertical: true,
        );
    }
  }

  void _desenharElemento(
    Canvas canvas,
    Rect rect,
    String label,
    Color color, {
    bool rotuloVertical = false,
  }) {
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = GulaColors.border.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);
    _desenharRotulo(
      canvas,
      label,
      rotuloVertical
          ? Offset(rect.center.dx - 20, rect.center.dy)
          : Offset(rect.left + 14, rect.top + 18),
      rotate: rotuloVertical,
    );
  }

  void _desenharRotulo(
    Canvas canvas,
    String label,
    Offset offset, {
    bool rotate = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: GulaColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (rotate) {
      canvas.rotate(-pi / 2);
    }
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorPlantaRestaurante oldDelegate) {
    return oldDelegate.tipoArea != tipoArea;
  }
}
