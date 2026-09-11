import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';

/// Lista de lotes disponíveis para baixa, ordenada por validade (FEFO).
///
/// Quando não há lote algum, exibe um estado vazio explícito — antes a
/// seção inteira sumia da tela (`SizedBox.shrink()`) e a saída seguia sem
/// `loteId`, silenciosamente.
class SeletorLote extends StatelessWidget {
  final List<Lote> lotes;
  final Lote? selecionado;
  final bool erro;
  final ValueChanged<Lote> aoSelecionar;

  const SeletorLote({
    super.key,
    required this.lotes,
    required this.selecionado,
    required this.aoSelecionar,
    this.erro = false,
  });

  @override
  Widget build(BuildContext context) {
    final semSelecao = selecionado == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRotuloCampo(
          'Lote a baixar',
          obrigatorio: true,
          acessorio: lotes.isEmpty
              ? null
              : const Text(
                  'Ordenado por validade (FEFO)',
                  style: TextStyle(
                    color: AppTema.textoSecundario,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        if (lotes.isEmpty)
          _LotesIndisponiveis(erro: erro)
        else
          ...lotes.map(
            (lote) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CartaoLote(
                lote: lote,
                selecionado: selecionado?.id == lote.id,
                erro: erro && semSelecao,
                aoTocar: () => aoSelecionar(lote),
              ),
            ),
          ),
        AppMensagemErroCampo(
          'Selecione o lote que será baixado.',
          visivel: erro && lotes.isNotEmpty && semSelecao,
        ),
      ],
    );
  }
}

class _LotesIndisponiveis extends StatelessWidget {
  final bool erro;

  const _LotesIndisponiveis({required this.erro});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: DecoracoesApp.campoPlano(erro: erro),
      child: const Row(
        children: [
          Icon(
            Icons.layers_clear_rounded,
            color: AppTema.textoSecundario,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhum lote disponível para este insumo.\n'
              'Registre uma entrada antes de lançar a saída.',
              style: TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoLote extends StatelessWidget {
  final Lote lote;
  final bool selecionado;
  final bool erro;
  final VoidCallback aoTocar;

  const _CartaoLote({
    required this.lote,
    required this.selecionado,
    required this.erro,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final restante = lote.quantidadeRestante?.toStringAsFixed(1) ?? '0';
    final simbolo = lote.unidadePadraoSimbolo ?? '';
    final custo =
        lote.custoUnitario?.toStringAsFixed(2).replaceAll('.', ',') ?? '0';

    return AppItemSelecionavel(
      selecionado: selecionado,
      aoTocar: aoTocar,
      padding: const EdgeInsets.all(12),
      raio: DecoracoesApp.raioCampo,
      filho: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      lote.codigo ?? 'L${lote.id}',
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (lote.isVencido) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTema.erro,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VENCIDO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$restante $simbolo restantes · custo R\$ $custo',
                  style: const TextStyle(
                    color: AppTema.textoSecundario,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selecionado
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selecionado
                ? AppTema.primaria
                : (erro ? AppTema.erro : AppTema.borda),
            size: 20,
          ),
        ],
      ),
    );
  }
}
