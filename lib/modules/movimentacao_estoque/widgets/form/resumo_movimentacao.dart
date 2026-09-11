import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/tipo_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';

/// Cartão de resumo exibido na última etapa e na tela de sucesso.
class ResumoMovimentacao extends StatelessWidget {
  final DadosMovimentacao dados;

  const ResumoMovimentacao({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final quantidade = dados.quantidade.isEmpty ? '0' : dados.quantidade;
    final simbolo = dados.unidade?.simbolo ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTema.bordaSuave),
        boxShadow: const [
          BoxShadow(
            color: AppTema.sombra,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMO',
            style: TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          AppLinhaResumo(
            rotulo: 'Tipo',
            valor: rotuloTipoMovimentacao(dados.tipo, sePadrao: '-'),
          ),
          const _Separador(),
          AppLinhaResumo(rotulo: 'Insumo', valor: dados.insumo?.nome ?? '-'),
          const _Separador(),
          AppLinhaResumo(rotulo: 'Quantidade', valor: '$quantidade $simbolo'),
          if (dados.lote != null) ...[
            const _Separador(),
            AppLinhaResumo(
              rotulo: 'Lote',
              valor: dados.lote!.codigo ?? '#${dados.lote!.id}',
            ),
          ],
          if (dados.custoNumerico > 0) ...[
            const _Separador(),
            AppLinhaResumo(
              rotulo: 'Custo unitário',
              valor:
                  'R\$ '
                  '${dados.custoNumerico.toStringAsFixed(2).replaceAll('.', ',')}',
            ),
          ],
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 18, color: AppTema.bordaSuave);
}
