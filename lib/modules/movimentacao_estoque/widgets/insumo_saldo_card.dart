import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


class InsumoSaldoCard extends StatelessWidget {
  final String nome;
  final double? estoqueMinimo;
  final double? estoqueAtual;
  final String? unidadeSimbolo;
  final double? percentAbaixo;
  final String? fefoLabel;
  final int? totalLotes;
  final VoidCallback? onTap;

  const InsumoSaldoCard({
    super.key,
    required this.nome,
    this.estoqueMinimo,
    this.estoqueAtual,
    this.unidadeSimbolo,
    this.percentAbaixo,
    this.fefoLabel,
    this.totalLotes,
    this.onTap,
  });

  bool get _abaixoDoMinimo => percentAbaixo != null && percentAbaixo! > 0;

  String get _saldoText {
    final qty = estoqueAtual ?? 0;
    final formatted = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1).replaceAll('.', ',');
    return '$formatted ${unidadeSimbolo ?? ''}';
  }

  String get _subtitleText {
    final parts = <String>[];
    if (estoqueMinimo != null) {
      final min = estoqueMinimo!;
      final formatted = min == min.truncateToDouble()
          ? min.toInt().toString()
          : min.toStringAsFixed(1).replaceAll('.', ',');
      parts.add('Mín: $formatted ${unidadeSimbolo ?? ''}');
    }
    if (totalLotes != null && totalLotes! > 0) {
      parts.add('$totalLotes ${totalLotes == 1 ? 'lote' : 'lotes'}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PaletaApp.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PaletaApp.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _abaixoDoMinimo
                  ? PaletaApp.warningBorder
                  : PaletaApp.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: PaletaApp.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _abaixoDoMinimo
                      ? const Color(0xFFFFF3E0)
                      : PaletaApp.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _abaixoDoMinimo
                      ? Icons.warning_amber_rounded
                      : Icons.inventory_2_rounded,
                  color: _abaixoDoMinimo
                      ? PaletaApp.primary
                      : PaletaApp.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        color: PaletaApp.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitleText,
                      style: const TextStyle(
                        color: PaletaApp.textMuted,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _saldoText,
                    style: const TextStyle(
                      color: PaletaApp.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_abaixoDoMinimo)
                    Text(
                      '-${percentAbaixo!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: PaletaApp.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (fefoLabel != null)
                    Text(
                      fefoLabel!,
                      style: const TextStyle(
                        color: PaletaApp.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
