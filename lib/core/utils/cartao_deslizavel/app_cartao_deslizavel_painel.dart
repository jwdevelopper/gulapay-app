import 'package:flutter/material.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel_acao.dart';

class AppCartaoDeslizavelPainel extends StatelessWidget {
  const AppCartaoDeslizavelPainel({
    super.key,
    required this.chave,
    required this.progresso,
    required this.raioBorda,
    required this.acao,
  });

  static const _larguraMinimaParaRotulo = 116.0;

  final String chave;
  final double progresso;
  final double raioBorda;
  final AppCartaoDeslizavelAcao acao;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        key: ValueKey('app_cartao_painel_$chave'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [acao.corProfundaResolvida, acao.cor],
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
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _AcaoDeslizavelCompleta(acao: acao),
                              )
                            : _IconeAcaoDeslizavel(acao: acao),
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

class AppCartaoDeslizavelPrimeiroPlano extends StatelessWidget {
  const AppCartaoDeslizavelPrimeiroPlano({
    super.key,
    required this.chave,
    required this.progresso,
    required this.raioBorda,
    required this.child,
  });

  final String chave;
  final double progresso;
  final double raioBorda;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final intensidade = Curves.easeOutCubic.transform(
      (progresso / 0.18).clamp(0.0, 1.0),
    );

    return DecoratedBox(
      key: ValueKey('app_cartao_primeiro_plano_$chave'),
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

class _AcaoDeslizavelCompleta extends StatelessWidget {
  const _AcaoDeslizavelCompleta({required this.acao});

  final AppCartaoDeslizavelAcao acao;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          acao.rotulo,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        _IconeAcaoDeslizavel(acao: acao),
      ],
    );
  }
}

class _IconeAcaoDeslizavel extends StatelessWidget {
  const _IconeAcaoDeslizavel({required this.acao});

  final AppCartaoDeslizavelAcao acao;

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
      child:
          acao.iconePersonalizado ??
          Icon(acao.icone!, color: Colors.white, size: 18),
    );
  }
}
