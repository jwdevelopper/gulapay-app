import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../dto/rateio_comanda_request.dart';

class RateioEstrategiaCard extends StatelessWidget {
  const RateioEstrategiaCard({
    super.key,
    required this.estrategia,
    required this.selecionada,
    this.indisponivelPor,
    this.aoSelecionar,
  });

  final EstrategiaRateio estrategia;
  final bool selecionada;
  final String? indisponivelPor;
  final VoidCallback? aoSelecionar;

  bool get _habilitada => indisponivelPor == null && aoSelecionar != null;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: indisponivelPor == null ? 1.0 : 0.55,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: selecionada
            ? EstoquePalette.primarySoft.withValues(alpha: 0.35)
            : EstoquePalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selecionada
                  ? EstoquePalette.primary
                  : EstoquePalette.borderSoft,
              width: selecionada ? 1.5 : 1),
        ),
        child: ListTile(
          onTap: _habilitada ? aoSelecionar : null,
          leading: Icon(
            selecionada
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color:
                selecionada ? EstoquePalette.primary : EstoquePalette.textMuted,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(estrategia.rotulo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: EstoquePalette.text)),
              ),
              if (indisponivelPor != null) ...[
                const SizedBox(width: 8),
                _selo(indisponivelPor!),
              ],
            ],
          ),
          subtitle: Text(estrategia.descricao,
              style: const TextStyle(
                  color: EstoquePalette.textMuted, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _selo(String texto) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: EstoquePalette.warningBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EstoquePalette.warningBorder),
        ),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 10,
                color: EstoquePalette.text,
                fontWeight: FontWeight.w600)),
      );
}
