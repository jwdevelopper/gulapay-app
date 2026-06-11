import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/lote/models/lote_status_validade.dart';

/// Tag colorida que mostra a situação de validade do lote. Segue o mesmo
/// formato visual do [AppTag], mas com cores derivadas do [LoteStatusValidade].
class LoteStatusTag extends StatelessWidget {
  final LoteStatusValidade status;

  const LoteStatusTag(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.rotulo,
        style: TextStyle(
          color: status.cor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
