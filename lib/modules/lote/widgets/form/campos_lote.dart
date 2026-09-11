/// Peças do formulário de lote.
///
/// Hoje só [ResumoLoteImutavel] — o campo de unidade virou
/// `CampoUnidadeMedida`, no módulo `unidade_medida`, por ser usado também
/// pelo formulário de insumo.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';

/// Quantidade, saldo e custo de um lote em edição.
///
/// O `PUT /lotes/{id}` só aceita código, validade e `ativo`; estes três
/// números aparecem apenas para referência. O saldo restante em especial
/// nunca é editado direto — ele só muda por movimentação de estoque, que é
/// o que mantém o histórico coerente.
class ResumoLoteImutavel extends StatelessWidget {
  final LoteResponse lote;

  const ResumoLoteImutavel({super.key, required this.lote});

  @override
  Widget build(BuildContext context) {
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    final sufixoCusto = simbolo.isEmpty ? '' : ' / $simbolo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTema.avisoFundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _linha(
            'Quantidade inicial',
            _comUnidade(lote.quantidadeInicial, simbolo),
          ),
          const Divider(height: 1, color: AppTema.borda),
          _linha(
            'Saldo restante',
            _comUnidade(lote.quantidadeRestante, simbolo),
          ),
          const Divider(height: 1, color: AppTema.borda),
          AppLinhaResumo(
            rotulo: 'Custo unitário',
            valor:
                '${LoteFormatadores.formatarMoeda(lote.custoUnitario)}'
                '$sufixoCusto',
          ),
        ],
      ),
    );
  }

  /// Uma linha do resumo, com o respiro vertical do bloco.
  Widget _linha(String rotulo, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: AppLinhaResumo(rotulo: rotulo, valor: valor),
  );

  String _comUnidade(double? valor, String simbolo) =>
      '${LoteFormatadores.formatarQuantidade(valor)} $simbolo'.trim();
}
