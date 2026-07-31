import 'package:flutter/material.dart';

import 'produtos_palette.dart';

class ProdutoCardAction {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const ProdutoCardAction({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });
}

class ProdutoCardContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final List<ProdutoCardAction> actions;

  const ProdutoCardContainer({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.actions = const [],
  });

  @override
  State<ProdutoCardContainer> createState() => _ProdutoCardContainerState();
}

class _ProdutoCardContainerState extends State<ProdutoCardContainer>
    with SingleTickerProviderStateMixin {
  static const double _revealThreshold = 0.32;
  static const double _openVelocity = 280;
  static const double _closeVelocity = 280;
  static const Duration _animationDuration = Duration(milliseconds: 280);

  late final AnimationController _controller;
  double _dragStartValue = 0;
  double _dragDistance = 0;

  bool get _hasActions => widget.actions.isNotEmpty;

  bool get _isOpen => _controller.value > 0.02;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (!_hasActions) return;
    _controller.animateTo(1, curve: Curves.easeOutQuart);
  }

  void _close() {
    _controller.animateTo(0, curve: Curves.easeOutQuart);
  }

  void _handleDragStart(DragStartDetails details) {
    if (!_hasActions) return;
    _dragStartValue = _controller.value;
    _dragDistance = 0;
  }

  void _handleDragUpdate(DragUpdateDetails details, double revealWidth) {
    if (!_hasActions) return;
    final delta = details.primaryDelta ?? 0;
    _dragDistance += delta;
    final nextValue = (_dragStartValue - (_dragDistance / revealWidth)).clamp(
      0.0,
      1.0,
    );
    _controller.value = nextValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_hasActions) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity <= -_openVelocity) {
      _open();
      return;
    }
    if (velocity >= _closeVelocity) {
      _close();
      return;
    }
    if (_controller.value >= _revealThreshold) {
      _open();
    } else {
      _close();
    }
  }

  void _handleCardTap() {
    if (_isOpen) {
      _close();
      return;
    }
    widget.onTap();
  }

  void _handleCardLongPress() {
    if (_isOpen) {
      _close();
      return;
    }
    widget.onLongPress?.call();
  }

  void _handleActionTap(VoidCallback action) {
    _controller.value = 0;
    action();
  }

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: ProdutosPalette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _handleCardTap,
        onLongPress: widget.onLongPress == null ? null : _handleCardLongPress,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ProdutosPalette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ProdutosPalette.border),
            boxShadow: const [
              BoxShadow(
                color: ProdutosPalette.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (!_hasActions) {
      return card;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final revealWidth = _revealWidthFor(constraints.maxWidth);

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: (details) {
              _handleDragUpdate(details, revealWidth);
            },
            onHorizontalDragEnd: _handleDragEnd,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.actions.first.backgroundColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: widget.actions.first.backgroundColor,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: revealWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildActions(),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-_controller.value * revealWidth, 0),
                      child: child,
                    );
                  },
                  child: card,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _revealWidthFor(double maxWidth) {
    if (!_hasActions) return 0;
    final desired = widget.actions.length == 1
        ? maxWidth * 0.28
        : maxWidth * 0.48;
    final minReveal = widget.actions.length == 1 ? 116.0 : 176.0;
    final maxReveal = widget.actions.length == 1 ? 148.0 : 240.0;
    return desired.clamp(minReveal, maxReveal);
  }

  List<Widget> _buildActions() {
    final widgets = <Widget>[];
    for (var index = 0; index < widget.actions.length; index++) {
      final action = widget.actions[index];
      widgets.add(
        Expanded(
          child: _SwipeActionButton(
            label: action.label,
            icon: action.icon,
            backgroundColor: action.backgroundColor,
            foregroundColor: action.foregroundColor,
            onTap: () => _handleActionTap(action.onTap),
          ),
        ),
      );
      if (index < widget.actions.length - 1) {
        widgets.add(const SizedBox.shrink());
      }
    }
    return widgets;
  }
}

class _SwipeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _SwipeActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
