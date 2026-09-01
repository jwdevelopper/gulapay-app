import 'package:flutter/material.dart';

/// Barra de navegação curvada com um slot de AÇÃO fixo no canto direito.
///
/// Adaptação do pacote `curved_navigation_bar` 1.0.6 (BSD) com três
/// diferenças em relação ao original:
///
///  1. Suporte a um botão de ação fixo ([acaoFinal], o "+" da Home) no
///     último slot, desenhado com o MESMO entalhe curvo da bolha de
///     seleção — a onda da barra "segue" os dois relevos.
///  2. Recalcula o estado interno quando a quantidade de slots muda
///     (o pacote original congela o total no initState e desalinha a
///     bolha em barras dinâmicas).
///  3. API em português, alinhada à nomenclatura do projeto.
class BarraNavegacaoCurvada extends StatefulWidget {
  /// Itens de página (abas). O slot da ação NÃO entra nesta lista.
  final List<Widget> itens;

  /// Índice do item selecionado dentro de [itens].
  final int indice;

  /// Cor da faixa da barra.
  final Color cor;

  /// Cor da bolha de seleção e do botão de ação.
  final Color? corBotao;

  /// Cor atrás da barra (o "vale" dos entalhes).
  final Color corFundo;

  final ValueChanged<int>? aoTocar;

  /// Conteúdo do botão de ação fixo no canto (ex.: ícone "+").
  /// Quando `null`, a barra se comporta como a original, sem o slot extra.
  final Widget? acaoFinal;

  final VoidCallback? aoTocarAcaoFinal;

  final Curve curvaAnimacao;
  final Duration duracaoAnimacao;
  final double altura;

  BarraNavegacaoCurvada({
    super.key,
    required this.itens,
    this.indice = 0,
    this.cor = Colors.white,
    this.corBotao,
    this.corFundo = Colors.blueAccent,
    this.aoTocar,
    this.acaoFinal,
    this.aoTocarAcaoFinal,
    this.curvaAnimacao = Curves.easeOut,
    this.duracaoAnimacao = const Duration(milliseconds: 600),
    this.altura = 75.0,
  })  : assert(itens.isNotEmpty),
        assert(0 <= indice && indice < itens.length),
        assert(0 <= altura && altura <= 75.0);

  @override
  State<BarraNavegacaoCurvada> createState() => _BarraNavegacaoCurvadaState();
}

class _BarraNavegacaoCurvadaState extends State<BarraNavegacaoCurvada>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late int _endingIndex;
  late double _pos;
  double _buttonHide = 0;
  late Widget _icone;
  late AnimationController _controlador;
  late int _totalSlots;

  /// Evita setState reentrante quando o layout muda e o valor do
  /// controlador é reposicionado manualmente (ver didUpdateWidget).
  bool _ajustandoLayout = false;

  bool get _temAcao => widget.acaoFinal != null;

  static int _slotsDe(BarraNavegacaoCurvada w) =>
      w.itens.length + (w.acaoFinal != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _icone = widget.itens[widget.indice];
    _totalSlots = _slotsDe(widget);
    _pos = widget.indice / _totalSlots;
    _startingPos = _pos;
    _endingIndex = widget.indice;
    _controlador = AnimationController(vsync: this, value: _pos);
    _controlador.addListener(() {
      if (_ajustandoLayout) return;
      setState(() {
        _pos = _controlador.value;
        final endingPos = _endingIndex / _totalSlots;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icone = widget.itens[_endingIndex];
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(BarraNavegacaoCurvada oldWidget) {
    super.didUpdateWidget(oldWidget);
    final novoTotal = _slotsDe(widget);
    if (novoTotal != _totalSlots) {
      // O layout mudou (slot entrou/saiu): reposiciona a bolha direto no
      // destino, sem animar — animar sobre uma malha de slots diferente
      // deixaria a bolha desalinhada.
      _ajustandoLayout = true;
      _controlador.stop();
      _totalSlots = novoTotal;
      _endingIndex = widget.indice;
      _pos = widget.indice / _totalSlots;
      _startingPos = _pos;
      _buttonHide = 0;
      _controlador.value = _pos;
      _icone = widget.itens[widget.indice];
      _ajustandoLayout = false;
    } else if (oldWidget.indice != widget.indice) {
      final novaPosicao = widget.indice / _totalSlots;
      _startingPos = _pos;
      _endingIndex = widget.indice;
      _controlador.animateTo(
        novaPosicao,
        duration: widget.duracaoAnimacao,
        curve: widget.curvaAnimacao,
      );
    }
    if (!_controlador.isAnimating) {
      _icone = widget.itens[_endingIndex];
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final fracaoAcao = (_totalSlots - 1) / _totalSlots;
    return SizedBox(
      height: widget.altura,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final larguraSlot = maxWidth / _totalSlots;
          return Align(
            alignment: textDirection == TextDirection.ltr
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: Container(
              color: widget.corFundo,
              width: maxWidth,
              child: ClipRect(
                clipper: _RecorteBarra(
                  alturaDispositivo: MediaQuery.sizeOf(context).height,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    // Bolha animada do item selecionado.
                    Positioned(
                      bottom: -40 - (75.0 - widget.altura),
                      left: textDirection == TextDirection.rtl
                          ? null
                          : _pos * maxWidth,
                      right: textDirection == TextDirection.rtl
                          ? _pos * maxWidth
                          : null,
                      width: larguraSlot,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, -(1 - _buttonHide) * 80),
                          child: Material(
                            color: widget.corBotao ?? widget.cor,
                            type: MaterialType.circle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _icone,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Botão de ação fixo, erguido no entalhe do canto.
                    if (_temAcao)
                      Positioned(
                        bottom: -40 - (75.0 - widget.altura),
                        left: textDirection == TextDirection.rtl
                            ? null
                            : fracaoAcao * maxWidth,
                        right: textDirection == TextDirection.rtl
                            ? fracaoAcao * maxWidth
                            : null,
                        width: larguraSlot,
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, -80),
                            child: Material(
                              color: widget.corBotao ?? widget.cor,
                              type: MaterialType.circle,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: widget.aoTocarAcaoFinal,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: widget.acaoFinal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Faixa da barra com os entalhes (bolha + ação).
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0 - (75.0 - widget.altura),
                      child: CustomPaint(
                        painter: _PintorBarraCurvada(
                          _pos,
                          _totalSlots,
                          widget.cor,
                          textDirection,
                          slotAcao: _temAcao ? _totalSlots - 1 : null,
                        ),
                        child: Container(height: 75.0),
                      ),
                    ),
                    // Alvos de toque.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0 - (75.0 - widget.altura),
                      child: SizedBox(
                        height: 100.0,
                        child: Row(
                          children: [
                            for (var i = 0; i < widget.itens.length; i++)
                              _BotaoNav(
                                onTap: _tocarItem,
                                position: _pos,
                                length: _totalSlots,
                                index: i,
                                child: Center(child: widget.itens[i]),
                              ),
                            if (_temAcao)
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: widget.aoTocarAcaoFinal,
                                  child: const SizedBox(height: 75.0),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _tocarItem(int index) {
    if (_controlador.isAnimating) return;
    widget.aoTocar?.call(index);
    final novaPosicao = index / _totalSlots;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _controlador.animateTo(
        novaPosicao,
        duration: widget.duracaoAnimacao,
        curve: widget.curvaAnimacao,
      );
    });
  }
}

/// Botão de aba (cópia do NavButton do pacote original).
class _BotaoNav extends StatelessWidget {
  final double position;
  final int length;
  final int index;
  final ValueChanged<int> onTap;
  final Widget child;

  const _BotaoNav({
    required this.onTap,
    required this.position,
    required this.length,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / length * index;
    final difference = (position - desiredPosition).abs();
    final verticalAlignment = 1 - length * difference;
    final opacity = length * difference;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap(index),
        child: SizedBox(
          height: 75.0,
          child: Transform.translate(
            offset: Offset(
              0,
              difference < 1.0 / length ? verticalAlignment * 40 : 0,
            ),
            child: Opacity(
              opacity: difference < 1.0 / length * 0.99 ? opacity : 1.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Recorta apenas a parte de baixo (cópia do NavCustomClipper original).
class _RecorteBarra extends CustomClipper<Rect> {
  final double alturaDispositivo;

  _RecorteBarra({required this.alturaDispositivo});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      -alturaDispositivo + size.height,
      size.width,
      alturaDispositivo,
    );
  }

  @override
  bool shouldReclip(_RecorteBarra oldClipper) =>
      oldClipper.alturaDispositivo != alturaDispositivo;
}

/// Pintor da faixa: desenha a barra com um ou dois entalhes côncavos —
/// o da bolha (posição animada) e, quando existe ação, o do canto (fixo).
class _PintorBarraCurvada extends CustomPainter {
  late final double _locBolha;
  double? _locAcao;
  late final double _s;
  final Color cor;
  final TextDirection textDirection;

  _PintorBarraCurvada(
    double startingLoc,
    int slots,
    this.cor,
    this.textDirection, {
    int? slotAcao,
  }) {
    final span = 1.0 / slots;
    _s = 0.2;
    final l = startingLoc + (span - _s) / 2;
    _locBolha = textDirection == TextDirection.rtl ? 0.8 - l : l;
    if (slotAcao != null) {
      final la = (slotAcao * span) + (span - _s) / 2;
      _locAcao = textDirection == TextDirection.rtl ? 0.8 - la : la;
    }
  }

  void _entalhe(Path path, double l, Size size) {
    path
      ..lineTo((l - 0.1) * size.width, 0)
      ..cubicTo(
        (l + _s * 0.20) * size.width,
        size.height * 0.05,
        l * size.width,
        size.height * 0.60,
        (l + _s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (l + _s) * size.width,
        size.height * 0.60,
        (l + _s - _s * 0.20) * size.width,
        size.height * 0.05,
        (l + _s + 0.1) * size.width,
        0,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;

    final locs = <double>[
      _locBolha,
      if (_locAcao != null) _locAcao!,
    ]..sort();

    final path = Path()..moveTo(0, 0);
    for (final l in locs) {
      _entalhe(path, l, size);
    }
    path
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PintorBarraCurvada oldDelegate) {
    return oldDelegate._locBolha != _locBolha ||
        oldDelegate._locAcao != _locAcao ||
        oldDelegate.cor != cor;
  }
}
