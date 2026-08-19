import 'package:flutter/material.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel_acao.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel_painel.dart';

/// Revela uma ação configurável ao deslizar o cartão para a esquerda.
///
/// O callback deve confirmar e executar a ação. Retorne `true` apenas quando
/// o item puder deixar a lista; use [aoConcluir] para sincronizar os dados.
class AppCartaoDeslizavel extends StatefulWidget {
  const AppCartaoDeslizavel({
    super.key,
    required this.chave,
    required this.child,
    required this.aoConfirmarAcao,
    this.aoConcluir,
    this.acao = const AppCartaoDeslizavelAcao.excluir(),
    this.raioBorda = 18,
    this.limiarConclusao = 0.5,
  }) : assert(limiarConclusao > 0 && limiarConclusao <= 1);

  final String chave;
  final Widget child;
  final Future<bool> Function() aoConfirmarAcao;
  final VoidCallback? aoConcluir;
  final AppCartaoDeslizavelAcao acao;
  final double raioBorda;
  final double limiarConclusao;

  @override
  State<AppCartaoDeslizavel> createState() => _AppCartaoDeslizavelState();
}

class _AppCartaoDeslizavelState extends State<AppCartaoDeslizavel> {
  double _progresso = 0;

  void _aoAtualizarArraste(DismissUpdateDetails detalhes) {
    final novoProgresso = detalhes.direction == DismissDirection.endToStart
        ? detalhes.progress.clamp(0.0, 1.0).toDouble()
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
          child: AppCartaoDeslizavelPainel(
            chave: widget.chave,
            progresso: _progresso,
            raioBorda: widget.raioBorda,
            acao: widget.acao,
          ),
        ),
        Dismissible(
          key: ValueKey(widget.chave),
          direction: DismissDirection.endToStart,
          dismissThresholds: {
            DismissDirection.endToStart: widget.limiarConclusao,
          },
          behavior: HitTestBehavior.opaque,
          movementDuration: const Duration(milliseconds: 220),
          resizeDuration: const Duration(milliseconds: 280),
          background: const SizedBox.expand(),
          secondaryBackground: const SizedBox.expand(),
          onUpdate: _aoAtualizarArraste,
          confirmDismiss: (_) => widget.aoConfirmarAcao(),
          onDismissed: (_) => widget.aoConcluir?.call(),
          child: AppCartaoDeslizavelPrimeiroPlano(
            chave: widget.chave,
            progresso: _progresso,
            raioBorda: widget.raioBorda,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
