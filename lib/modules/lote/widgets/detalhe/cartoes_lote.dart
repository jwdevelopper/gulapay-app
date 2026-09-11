/// Peças da tela de detalhe do lote.
///
///  * [HeroiLote] — identificação do lote e os três números-chave;
///  * [AvisoValidadeLote] — faixa de alerta quando a validade aperta;
///  * [AtributosLote] — os dados que não cabem no herói;
///  * [LinhaMovimentacaoLote] — uma movimentação do histórico do lote.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/data_extenso.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_status_validade.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_status_tag.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/tipo_movimentacao.dart';

/// Cabeçalho do detalhe: quem é o lote e os três números que se olha
/// primeiro — saldo restante, quantidade inicial e validade.
class HeroiLote extends StatelessWidget {
  final LoteResponse lote;

  const HeroiLote({super.key, required this.lote});

  String get _titulo {
    final codigo = (lote.codigo ?? '').trim();
    return codigo.isEmpty ? 'Lote ${lote.id ?? ''}' : 'Lote $codigo';
  }

  @override
  Widget build(BuildContext context) {
    final status = LoteStatusValidade.calcular(lote.validade);
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTema.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTema.avisoFundo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppTema.primariaEscura,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTema.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lote.insumoNome ?? 'Insumo',
                      style: const TextStyle(color: AppTema.textoSecundario),
                    ),
                  ],
                ),
              ),
              LoteStatusTag(status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Numero(
                rotulo: 'Restante',
                valor: _comUnidade(lote.quantidadeRestante, simbolo),
              ),
              _Numero(
                rotulo: 'Inicial',
                valor: _comUnidade(lote.quantidadeInicial, simbolo),
              ),
              _Numero(
                rotulo: 'Validade',
                valor: LoteFormatadores.formatarDataCurta(lote.validade),
                cor: status.exigeAtencao ? status.cor : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _comUnidade(double? valor, String simbolo) =>
      '${LoteFormatadores.formatarQuantidade(valor)} $simbolo'.trim();
}

class _Numero extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color? cor;

  const _Numero({required this.rotulo, required this.valor, this.cor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 11,
            color: AppTema.textoSecundario,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: cor ?? AppTema.texto,
          ),
        ),
      ],
    ),
  );
}

/// Faixa de alerta de validade, com a ação sugerida.
///
/// Só aparece quando [LoteStatusValidade.exigeAtencao] — o que já venceu
/// pede descarte ou ajuste; o que está para vencer pede prioridade na
/// produção. A cor vem do próprio status, para casar com a etiqueta.
class AvisoValidadeLote extends StatelessWidget {
  final LoteResponse lote;

  const AvisoValidadeLote({super.key, required this.lote});

  @override
  Widget build(BuildContext context) {
    final status = LoteStatusValidade.calcular(lote.validade);
    final descricao = LoteStatusValidade.descricaoVencimento(lote.validade);
    final vencido = status == LoteStatusValidade.vencido;
    final mensagem = vencido
        ? '$descricao. Avalie descarte ou ajuste de inventário.'
        : '$descricao. Priorize na produção ou avalie uma promoção.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.fundo,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: status.cor, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            vencido ? Icons.error_outline : Icons.warning_amber_rounded,
            color: status.cor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(color: status.cor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custo, valor em estoque, validade e situação do lote.
class AtributosLote extends StatelessWidget {
  final LoteResponse lote;

  const AtributosLote({super.key, required this.lote});

  /// Quanto de dinheiro está parado neste lote.
  double get _valorEmEstoque =>
      (lote.quantidadeRestante ?? 0) * (lote.custoUnitario ?? 0);

  @override
  Widget build(BuildContext context) {
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    final sufixoCusto = simbolo.isEmpty ? '' : ' / $simbolo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTema.borda),
      ),
      child: Column(
        children: [
          _linha(
            'Custo unitário',
            LoteFormatadores.formatarMoeda(lote.custoUnitario) + sufixoCusto,
          ),
          const Divider(height: 1, color: AppTema.borda),
          _linha(
            'Valor em estoque',
            LoteFormatadores.formatarMoeda(_valorEmEstoque),
          ),
          const Divider(height: 1, color: AppTema.borda),
          _linha('Validade', LoteFormatadores.formatarData(lote.validade)),
          const Divider(height: 1, color: AppTema.borda),
          _linha('Situação', (lote.ativo ?? true) ? 'Ativo' : 'Inativo'),
        ],
      ),
    );
  }

  Widget _linha(String rotulo, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            color: AppTema.textoSecundario,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: AppTema.primariaEscura,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

/// Uma movimentação no histórico do lote.
///
/// Entradas somam e saem em verde com `+`; saídas subtraem e saem em
/// vermelho com `−`. O sinal vem do prefixo do tipo (`ENTRADA_`), que é o
/// mesmo critério que o backend usa para decidir se soma ou baixa do saldo.
class LinhaMovimentacaoLote extends StatelessWidget {
  final MovimentacaoEstoque movimentacao;

  const LinhaMovimentacaoLote({super.key, required this.movimentacao});

  bool get _ehEntrada =>
      (movimentacao.tipo ?? '').toUpperCase().startsWith('ENTRADA');

  @override
  Widget build(BuildContext context) {
    final cor = _ehEntrada ? AppTema.sucesso : AppTema.erro;
    final quantidade = LoteFormatadores.formatarQuantidade(
      movimentacao.quantidade,
    );
    final simbolo = movimentacao.unidadeSimbolo ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _ehEntrada ? AppTema.sucessoFundo : AppTema.avisoFundo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _ehEntrada ? Icons.south_west : Icons.north_east,
              size: 18,
              color: cor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotuloTipoMovimentacao(
                    movimentacao.tipo,
                    sePadrao: 'Movimentação',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTema.texto,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _descricao,
                  style: const TextStyle(
                    color: AppTema.textoSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_ehEntrada ? '+' : '−'}$quantidade $simbolo'.trim(),
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String get _descricao => [
    DataExtenso.cabecalho(movimentacao.dataHora),
    if ((movimentacao.responsavel ?? '').isNotEmpty) movimentacao.responsavel!,
  ].join(' · ');
}
