import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_cartao_deslizavel.dart';

class InsumoCard extends StatelessWidget {
  final InsumoResponse insumo;
  final Color accentColor;
  final Color stockBarColor;
  final String stockText;
  final IconData icon;

  /// Percentual do estoque atual em relação ao mínimo.
  /// Negativo se abaixo, positivo se acima. Pode ser null.
  final double? percentVsMinimo;

  final VoidCallback onTap;
  final Future<bool> Function() onConfirmDelete;

  const InsumoCard({
    super.key,
    required this.insumo,
    required this.icon,
    required this.accentColor,
    required this.stockBarColor,
    required this.stockText,
    required this.percentVsMinimo,
    required this.onTap,
    required this.onConfirmDelete,
  });

  bool get _abaixoDoMinimo => insumo.abaixoDoMinimo == true;

  String? get _badgePercentText {
    if (!_abaixoDoMinimo) return null;
    final pct = percentVsMinimo;
    if (pct == null) return null;
    final formatted = pct.toStringAsFixed(0);
    return '$formatted% DO MÍNIMO';
  }

  double get _barFraction {
    final atual = insumo.estoqueAtual ?? 0;
    final min = insumo.estoqueMinimo ?? 0;
    if (min <= 0) {
      return atual > 0 ? 1 : 0;
    }
    final ratio = atual / (min * 2);
    return ratio.clamp(0, 1).toDouble();
  }

  bool _atualHasFraction() {
    final v = insumo.estoqueAtual ?? 0;
    return v != v.truncateToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

      final card = Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTema.bordaCampo,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIconBox(theme),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(theme)),
              const SizedBox(width: 8),
              _buildStockArea(theme),
            ],
          ),
        ),
      ),
    );

    return AppCartaoDeslizavel(
      chave: 'insumo_${insumo.id}',
      aoConfirmarExclusao: onConfirmDelete,
      child: card,
    );
  }

  Widget _buildIconBox(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 26,
        color: theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    final unidadeNome = insumo.unidadePadraoNome ??
        insumo.unidadePadrao ??
        insumo.unidadePadraoSimbolo;
    final subtitle = unidadeNome ?? '';
    final badge = _badgePercentText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          insumo.nome ?? 'Sem nome',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTema.textoEscuro,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppTema.textoSecundario,
            ),
          ),
        ],
        if (badge != null) ...[
          const SizedBox(height: 6),
          _buildBelowMinBadge(badge),
        ],
      ],
    );
  }

  Widget _buildBelowMinBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildStockArea(ThemeData theme) {
    final atual = (insumo.estoqueAtual ?? 0)
        .toStringAsFixed(_atualHasFraction() ? 1 : 0)
        .replaceAll('.', ',');
    final simbolo = insumo.unidadePadraoSimbolo ?? '';

    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                atual,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                simbolo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildStockBar(theme),
        ],
      ),
    );
  }

  Widget _buildStockBar(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Stack(
        children: [
          Container(
            height: 5,
            width: double.infinity,
            color: theme.dividerColor,
          ),
          FractionallySizedBox(
            widthFactor: _barFraction,
            child: Container(
              height: 5,
              color: stockBarColor,
            ),
          ),
        ],
      ),
    );
  }

}