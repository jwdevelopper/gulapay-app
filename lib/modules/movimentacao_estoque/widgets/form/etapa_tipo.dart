import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/tipo_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';

/// Etapa 1 — escolha do tipo de movimentação.
class EtapaTipo extends StatelessWidget {
  final String? tipoSelecionado;
  final ResultadoValidacao validacao;
  final ValueChanged<String> aoSelecionar;

  const EtapaTipo({
    super.key,
    required this.tipoSelecionado,
    required this.validacao,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    final erro = validacao.erroEm(CampoMovimentacao.tipo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotuloCampo('Tipo de movimentação', obrigatorio: true),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: [
            for (final opcao in tiposMovimentacao)
              _CartaoTipo(
                opcao: opcao,
                selecionado: tipoSelecionado == opcao.valor,
                erro: erro,
                aoTocar: () => aoSelecionar(opcao.valor),
              ),
          ],
        ),
        if (tipoSelecionado == 'SAIDA_PERDA_VALIDADE') ...[
          const SizedBox(height: 16),
          const AppCartaoAviso.dica(
            'Perda por validade exige que você selecione qual lote venceu '
            'na próxima etapa.',
          ),
        ],
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
      ],
    );
  }
}

class _CartaoTipo extends StatelessWidget {
  final OpcaoEscolha opcao;
  final bool selecionado;
  final bool erro;
  final VoidCallback aoTocar;

  const _CartaoTipo({
    required this.opcao,
    required this.selecionado,
    required this.erro,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionado ? AppTema.avisoFundo : AppTema.superficieAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado
                ? AppTema.primaria
                : (erro ? AppTema.erro : AppTema.borda),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? AppTema.primaria
                        : AppTema.preenchimentoCampo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    opcao.icone,
                    color: selecionado ? Colors.white : AppTema.primaria,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (selecionado)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTema.primaria,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              opcao.rotulo,
              style: const TextStyle(
                color: AppTema.texto,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              opcao.descricao,
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
