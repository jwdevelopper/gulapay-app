import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class ElementoMesa extends StatelessWidget {
  const ElementoMesa({
    super.key,
    required this.mesa,
    required this.situacao,
    required this.emMovimento,
    required this.uniaoSugerida,
    required this.podeArrastar,
    required this.nomeArea,
    this.ultimoEventoEm,
    required this.aoTocar,
    required this.aoToqueDuplo,
    required this.aoIniciarArraste,
    required this.aoAtualizarArraste,
    required this.aoFinalizarArraste,
  });

  final MesaRestaurante mesa;
  final SituacaoMesa situacao;
  final bool emMovimento;
  final bool uniaoSugerida;
  final bool podeArrastar;
  final String nomeArea;
  final DateTime? ultimoEventoEm;
  final VoidCallback aoTocar;
  final VoidCallback aoToqueDuplo;
  final VoidCallback aoIniciarArraste;
  final ValueChanged<Offset> aoAtualizarArraste;
  final VoidCallback aoFinalizarArraste;

  @override
  Widget build(BuildContext context) {
    final decoration = _construirDecoracao();
    final chairOffsets = _posicoesCadeiras(
      Size(mesa.width, mesa.height),
      mesa.formato,
      mesa.quantidadeCadeiras,
    );

    final semanticsLabel = [
      mesa.codigo,
      nomeArea,
      rotuloSituacaoMesa(situacao),
      '${mesa.quantidadeCadeiras} cadeiras',
      if (mesa.estaUnida) 'mesa agrupada',
    ].join(', ');

    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: podeArrastar
          ? 'Toque para detalhes ou arraste para reposicionar.'
          : 'Toque para detalhes.',
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: podeArrastar ? null : (_) => aoTocar(),
        child: Tooltip(
          message: podeArrastar
              ? '${mesa.codigo} - arraste para reposicionar'
              : '${mesa.codigo} - ${rotuloSituacaoMesa(situacao)}',
          child: MouseRegion(
            cursor: podeArrastar
                ? SystemMouseCursors.grab
                : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.down,
              onTap: aoTocar,
              onDoubleTap: aoToqueDuplo,
              onPanStart: podeArrastar ? (_) => aoIniciarArraste() : null,
              onPanUpdate: podeArrastar
                  ? (details) => aoAtualizarArraste(details.delta)
                  : null,
              onPanEnd: podeArrastar ? (_) => aoFinalizarArraste() : null,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: emMovimento ? 1.04 : 1,
                child: SizedBox(
                  width: mesa.width,
                  height: mesa.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...chairOffsets.map(
                        (offset) => Positioned(
                          left: offset.dx - 5,
                          top: offset.dy - 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: GulaColors.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(color: GulaColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: decoration,
                          padding: const EdgeInsets.all(8),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compacto =
                                  constraints.maxWidth < 106 ||
                                  constraints.maxHeight < 78;
                              final veryCompact = constraints.maxHeight < 70;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mesa.codigo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: GulaColors.text,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (mesa.estaUnida) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.link,
                                          size: 12,
                                          color: GulaColors.text,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  _IndicadorSituacaoElemento(
                                    situacao: situacao,
                                    compacto: compacto,
                                    ultimoEventoEm: ultimoEventoEm,
                                  ),
                                  if (!veryCompact) ...[
                                    const SizedBox(height: 5),
                                    _LinhaCapacidade(
                                      count: mesa.quantidadeCadeiras,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      if (podeArrastar)
                        const Positioned(
                          right: 7,
                          bottom: 6,
                          child: Icon(
                            Icons.open_with_rounded,
                            size: 13,
                            color: GulaColors.textMuted,
                          ),
                        ),
                      if (uniaoSugerida)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: _raioBordaParaFormato(
                                  mesa.formato,
                                ),
                                border: Border.all(
                                  color: GulaColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _construirDecoracao() {
    final color = corSituacaoMesa(situacao);
    final borderRadius = _raioBordaParaFormato(mesa.formato);

    if (mesa.formato == FormatoMesa.redonda) {
      return BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: uniaoSugerida ? GulaColors.primary : GulaColors.border,
          width: uniaoSugerida ? 2.2 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: Border.all(
        color: uniaoSugerida ? GulaColors.primary : GulaColors.border,
        width: uniaoSugerida ? 2.2 : 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  BorderRadius _raioBordaParaFormato(FormatoMesa formato) {
    switch (formato) {
      case FormatoMesa.redonda:
        return BorderRadius.circular(999);
      case FormatoMesa.quadrada:
        return BorderRadius.circular(24);
      case FormatoMesa.retangular:
        return BorderRadius.circular(22);
      case FormatoMesa.oval:
        return BorderRadius.circular(999);
    }
  }

  List<Offset> _posicoesCadeiras(
    Size size,
    FormatoMesa formato,
    int quantidadeCadeiras,
  ) {
    final seats = quantidadeCadeiras.clamp(1, 12).toInt();
    if (formato == FormatoMesa.redonda || formato == FormatoMesa.oval) {
      return List<Offset>.generate(seats, (index) {
        final angle = (2 * pi * index) / seats;
        final radiusX = (size.width / 2) + 8;
        final radiusY = (size.height / 2) + 8;
        return Offset(
          (size.width / 2) + (radiusX * cos(angle)),
          (size.height / 2) + (radiusY * sin(angle)),
        );
      });
    }

    final topCount = (seats / 4).ceil();
    final bottomCount = topCount;
    final sideCount = ((seats - topCount - bottomCount) / 2).ceil();
    final positions = <Offset>[];

    for (var i = 0; i < topCount; i++) {
      final dx = ((i + 1) * size.width) / (topCount + 1);
      positions.add(Offset(dx, -6));
    }
    for (var i = 0; i < bottomCount; i++) {
      final dx = ((i + 1) * size.width) / (bottomCount + 1);
      positions.add(Offset(dx, size.height + 6));
    }
    for (var i = 0; i < sideCount; i++) {
      final dy = ((i + 1) * size.height) / (sideCount + 1);
      positions.add(Offset(-6, dy));
    }
    while (positions.length < seats) {
      final index = positions.length - (topCount + bottomCount + sideCount) + 1;
      final dy = (index * size.height) / (max(1, seats - positions.length) + 1);
      positions.add(Offset(size.width + 6, dy));
    }
    return positions.take(seats).toList();
  }
}

class _IndicadorSituacaoElemento extends StatelessWidget {
  const _IndicadorSituacaoElemento({
    required this.situacao,
    required this.compacto,
    this.ultimoEventoEm,
  });

  final SituacaoMesa situacao;
  final bool compacto;
  final DateTime? ultimoEventoEm;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconeSituacaoMesa(situacao),
          size: compacto ? 13 : 12,
          color: GulaColors.text,
        ),
        if (!compacto) ...[
          const SizedBox(width: 4),
          Text(
            _rotuloCurto(situacao, ultimoEventoEm),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GulaColors.text,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );

    return Container(
      constraints: compacto
          ? const BoxConstraints.tightFor(width: 26, height: 24)
          : const BoxConstraints(maxWidth: 88),
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 0 : 8,
        vertical: compacto ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: GulaColors.border.withValues(alpha: 0.8)),
      ),
      alignment: Alignment.center,
      child: FittedBox(child: child),
    );
  }

  String _rotuloCurto(SituacaoMesa situacao, DateTime? ultimoEventoEm) {
    switch (situacao) {
      case SituacaoMesa.livre:
        return 'Livre';
      case SituacaoMesa.ocupada:
        return 'Ocupada';
      case SituacaoMesa.semPedidoHa30Min:
        return _rotuloTempoDecorrido(ultimoEventoEm, fallback: '30 min');
      case SituacaoMesa.aguardandoLiberacaoHa1H:
        return _rotuloTempoDecorrido(ultimoEventoEm, fallback: '1 h');
      case SituacaoMesa.comPedido:
        return _rotuloTempoDecorrido(ultimoEventoEm, fallback: 'Pedido');
      case SituacaoMesa.atencao:
        return 'Atencao';
    }
  }

  String _rotuloTempoDecorrido(DateTime? value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }
    final tempoDecorrido = DateTime.now().difference(value);
    if (tempoDecorrido.inMinutes < 1) {
      return 'Agora';
    }
    if (tempoDecorrido.inMinutes < 60) {
      return '${tempoDecorrido.inMinutes} min';
    }
    return '${tempoDecorrido.inHours} h';
  }
}

class _LinhaCapacidade extends StatelessWidget {
  const _LinhaCapacidade({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chair_alt_outlined,
            size: 12,
            color: GulaColors.textMuted,
          ),
          const SizedBox(width: 3),
          Text(
            '$count cad.',
            style: const TextStyle(
              color: GulaColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
