import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';


class MovimentacaoCard extends StatelessWidget {
  final String insumoNome;
  final String tipo;
  final double? quantidade;
  final String? unidadeSimbolo;
  final String? detalhes;
  final String? hora;
  final String? responsavel;
  final VoidCallback? onTap;

  const MovimentacaoCard({
    super.key,
    required this.insumoNome,
    required this.tipo,
    this.quantidade,
    this.unidadeSimbolo,
    this.detalhes,
    this.hora,
    this.responsavel,
    this.onTap,
  });

  Color get _iconBgColor {
    switch (tipo) {
      case 'ENTRADA_COMPRA':
        return const Color(0xFFE8F5E9);
      case 'ENTRADA_TROCA':
        return const Color(0xFFE3F2FD);
      case 'SAIDA_VENDA':
        return const Color(0xFFFFF3E0);
      case 'SAIDA_PERDA_VALIDADE':
        return const Color(0xFFFFEBEE);
      case 'SAIDA_PERDA_QUEBRA':
        return const Color(0xFFFCE4EC);
      case 'AJUSTE_INVENTARIO':
        return const Color(0xFFF3E5F5);
      default:
        return PaletaApp.inputFill;
    }
  }

  IconData get _icon {
    switch (tipo) {
      case 'ENTRADA_COMPRA':
        return Icons.shopping_cart_rounded;
      case 'ENTRADA_TROCA':
        return Icons.swap_horiz_rounded;
      case 'SAIDA_VENDA':
        return Icons.point_of_sale_rounded;
      case 'SAIDA_PERDA_VALIDADE':
        return Icons.timer_off_rounded;
      case 'SAIDA_PERDA_QUEBRA':
        return Icons.broken_image_rounded;
      case 'AJUSTE_INVENTARIO':
        return Icons.tune_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color get _iconColor {
    switch (tipo) {
      case 'ENTRADA_COMPRA':
        return const Color(0xFF2E7D32);
      case 'ENTRADA_TROCA':
        return const Color(0xFF1565C0);
      case 'SAIDA_VENDA':
        return PaletaApp.primary;
      case 'SAIDA_PERDA_VALIDADE':
        return const Color(0xFFD32F2F);
      case 'SAIDA_PERDA_QUEBRA':
        return const Color(0xFFC62828);
      case 'AJUSTE_INVENTARIO':
        return const Color(0xFF7B1FA2);
      default:
        return PaletaApp.primary;
    }
  }

  bool get _isEntrada =>
      tipo == 'ENTRADA_COMPRA' || tipo == 'ENTRADA_TROCA';

  String get _tipoLabel {
    switch (tipo) {
      case 'ENTRADA_COMPRA':
        return 'Compra';
      case 'ENTRADA_TROCA':
        return 'Entrada por troca';
      case 'SAIDA_VENDA':
        return 'Venda';
      case 'SAIDA_PERDA_VALIDADE':
        return 'Perda por validade';
      case 'SAIDA_PERDA_QUEBRA':
        return 'Perda por quebra';
      case 'AJUSTE_INVENTARIO':
        return 'Ajuste pós-inventário';
      default:
        return tipo;
    }
  }

  String get _quantidadeText {
    final qty = quantidade ?? 0;
    final symbol = unidadeSimbolo ?? '';
    final prefix = _isEntrada ? '+ ' : '- ';
    final formatted = qty == qty.truncateToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2).replaceAll('.', ',');
    return '$prefix$formatted $symbol';
  }

  Color get _quantidadeColor {
    if (_isEntrada) return const Color(0xFF2E7D32);
    if (tipo == 'AJUSTE_INVENTARIO') return const Color(0xFF7B1FA2);
    return PaletaApp.error;
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
            border: Border.all(color: PaletaApp.border),
            boxShadow: const [
              BoxShadow(
                color: PaletaApp.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insumoNome,
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
                      _buildSubtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    _quantidadeText,
                    style: TextStyle(
                      color: _quantidadeColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hora != null || responsavel != null)
                    Text(
                      [hora, responsavel]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' · '),
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

  String _buildSubtitle() {
    final parts = <String>[_tipoLabel];
    if (detalhes != null && detalhes!.trim().isNotEmpty) {
      parts.add(detalhes!.trim());
    }
    return parts.join(' · ');
  }
}
