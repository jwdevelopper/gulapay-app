import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/models/lote_status_validade.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_status_tag.dart';

/// Card de lote inspirado no frame B1 do escopo: bloco de código/validade à
/// esquerda, informações do insumo no centro e quantidade/custo à direita.
class LoteCard extends StatelessWidget {
  final LoteResponse lote;
  final VoidCallback? onTap;

  const LoteCard({super.key, required this.lote, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = LoteStatusValidade.calcular(lote.validade);
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    final exigeAtencao = status.exigeAtencao;

    return Material(
      color: AppTema.cartao,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: exigeAtencao ? status.cor.withValues(alpha: 0.5) : AppTema.bordaCampo,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BlocoCodigo(lote: lote, status: status),
              const SizedBox(width: 12),
              Expanded(child: _Informacoes(lote: lote, status: status)),
              const SizedBox(width: 10),
              _Quantidade(lote: lote, simbolo: simbolo),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlocoCodigo extends StatelessWidget {
  final LoteResponse lote;
  final LoteStatusValidade status;

  const _BlocoCodigo({required this.lote, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: status.fundo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LoteFormatadores.diaDoMes(lote.validade),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: status.cor,
            ),
          ),
          Text(
            LoteFormatadores.mesAbreviado(lote.validade),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.cor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Informacoes extends StatelessWidget {
  final LoteResponse lote;
  final LoteStatusValidade status;

  const _Informacoes({required this.lote, required this.status});

  @override
  Widget build(BuildContext context) {
    final codigo = (lote.codigo ?? '').trim();
    final descricaoVencimento =
        LoteStatusValidade.descricaoVencimento(lote.validade);
    final metaPartes = <String>[descricaoVencimento];
    if (codigo.isNotEmpty) metaPartes.add(codigo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lote.insumoNome ?? 'Insumo',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTema.textoEscuro,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          metaPartes.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppTema.textoSecundario,
          ),
        ),
        const SizedBox(height: 6),
        LoteStatusTag(status),
      ],
    );
  }
}

class _Quantidade extends StatelessWidget {
  final LoteResponse lote;
  final String simbolo;

  const _Quantidade({required this.lote, required this.simbolo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: LoteFormatadores.formatarQuantidade(lote.quantidadeRestante),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTema.textoEscuro,
            ),
            children: [
              if (simbolo.isNotEmpty)
                TextSpan(
                  text: ' $simbolo',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTema.textoSecundario,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${LoteFormatadores.formatarMoeda(lote.custoUnitario)}${simbolo.isNotEmpty ? '/$simbolo' : ''}',
          style: const TextStyle(
            fontSize: 12,
            color: AppTema.textoSecundario,
          ),
        ),
      ],
    );
  }
}
