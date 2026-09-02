import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Adiciona ao card o gesto padrao de exclusao das listagens do Gulapay.
///
/// O callback deve confirmar a acao, executar a chamada remota e retornar
/// `true` somente quando o item puder sair visualmente da lista.
class AppCartaoDeslizavel extends StatefulWidget {
  final String chave;
  final Widget child;
  final Future<bool> Function() aoConfirmarExclusao;
  final double raioBorda;
  final String rotuloExclusao;

  const AppCartaoDeslizavel({
    super.key,
    required this.chave,
    required this.child,
    required this.aoConfirmarExclusao,
    this.raioBorda = 18,
    this.rotuloExclusao = 'Excluir',
  });

  @override
  State<AppCartaoDeslizavel> createState() => _AppCartaoDeslizavelState();
}

class _AppCartaoDeslizavelState extends State<AppCartaoDeslizavel> {
  double _progresso = 0;

  void _aoAtualizarArraste(DismissUpdateDetails detalhes) {
    final novoProgresso = detalhes.direction == DismissDirection.endToStart
        ? detalhes.progress.clamp(0.0, 1.0)
        : 0.0;

    if ((_progresso - novoProgresso).abs() < 0.002) return;

    setState(() => _progresso = novoProgresso);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: _FundoExclusao(
            progresso: _progresso,
            raioBorda: widget.raioBorda,
            rotulo: widget.rotuloExclusao,
          ),
        ),
        Dismissible(
          key: ValueKey(widget.chave),
          direction: DismissDirection.endToStart,
          behavior: HitTestBehavior.opaque,
          movementDuration: const Duration(milliseconds: 220),
          resizeDuration: const Duration(milliseconds: 280),
          // O painel real fica fora do Dismissible. Estes fundos transparentes
          // preservam apenas o mecanismo de gesto e confirmacao do Flutter.
          background: const SizedBox.expand(),
          secondaryBackground: const SizedBox.expand(),
          onUpdate: _aoAtualizarArraste,
          confirmDismiss: (_) => widget.aoConfirmarExclusao(),
          child: _CardPrincipalSobreposto(
            progresso: _progresso,
            raioBorda: widget.raioBorda,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Card destrutivo completo, fixo e renderizado abaixo do item da lista.
///
/// O progresso altera somente a apresentacao do conteudo. A superficie
/// vermelha nunca nasce nem aumenta durante o movimento.
class _FundoExclusao extends StatelessWidget {
  static const _larguraMinimaParaRotulo = 116.0;

  final double progresso;
  final double raioBorda;
  final String rotulo;

  const _FundoExclusao({
    required this.progresso,
    required this.raioBorda,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final vermelho = Colors.red.shade600;
    final vermelhoProfundo = Color.lerp(vermelho, Colors.red.shade900, 0.35)!;

    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('app_cartao_painel_exclusao'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [vermelhoProfundo, vermelho],
          ),
          borderRadius: BorderRadius.circular(raioBorda),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final larguraRevelada = constraints.maxWidth * progresso;
            final mostrarRotulo = larguraRevelada >= _larguraMinimaParaRotulo;
            final opacidade = ((larguraRevelada - 24) / 36).clamp(0.0, 1.0);
            final escala = 0.82 + (0.18 * opacidade);

            return Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: larguraRevelada,
                child: ClipRect(
                  child: Center(
                    child: Opacity(
                      opacity: opacidade,
                      child: Transform.scale(
                        scale: escala,
                        child: mostrarRotulo
                            ? _AcaoExclusaoCompleta(rotulo: rotulo)
                            : const _IconeExclusao(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Projeta sombra na borda movel sem alterar as dimensoes do card principal.
class _CardPrincipalSobreposto extends StatelessWidget {
  final double progresso;
  final double raioBorda;
  final Widget child;

  const _CardPrincipalSobreposto({
    required this.progresso,
    required this.raioBorda,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final intensidade = Curves.easeOutCubic.transform(
      (progresso / 0.18).clamp(0.0, 1.0),
    );

    return DecoratedBox(
      key: const ValueKey('app_cartao_primeiro_plano'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raioBorda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2 * intensidade),
            blurRadius: 14,
            spreadRadius: -3,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AcaoExclusaoCompleta extends StatelessWidget {
  final String rotulo;

  const _AcaoExclusaoCompleta({required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rotulo,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        const _IconeExclusao(),
      ],
    );
  }
}

class _IconeExclusao extends StatelessWidget {
  const _IconeExclusao();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: const FaIcon(
        FontAwesomeIcons.trashCan,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
