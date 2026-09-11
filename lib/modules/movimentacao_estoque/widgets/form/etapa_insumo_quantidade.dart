import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/seletor_insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/seletor_unidade.dart';

/// Etapa 2 — insumo, quantidade e unidade de medida.
class EtapaInsumoQuantidade extends StatelessWidget {
  final Insumo? insumo;
  final UnidadeMedida? unidade;
  final TextEditingController controladorQuantidade;
  final ResultadoValidacao validacao;
  final VoidCallback aoAbrirInsumo;
  final VoidCallback aoAbrirUnidade;
  final ValueChanged<String> aoAlterarQuantidade;

  const EtapaInsumoQuantidade({
    super.key,
    required this.insumo,
    required this.unidade,
    required this.controladorQuantidade,
    required this.validacao,
    required this.aoAbrirInsumo,
    required this.aoAbrirUnidade,
    required this.aoAlterarQuantidade,
  });

  @override
  Widget build(BuildContext context) {
    final erroInsumo = validacao.erroEm(CampoMovimentacao.insumo);
    final erroQuantidade = validacao.erroEm(CampoMovimentacao.quantidade);
    final erroUnidade = validacao.erroEm(CampoMovimentacao.unidade);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeletorInsumo(
          selecionado: insumo,
          erro: erroInsumo,
          aoTocar: aoAbrirInsumo,
        ),
        AppMensagemErroCampo('Selecione um insumo.', visivel: erroInsumo),
        const SizedBox(height: 16),
        const AppRotuloCampo('Quantidade', obrigatorio: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppCampoFormulario(
                controlador: controladorQuantidade,
                dica: '0',
                aoAlterar: aoAlterarQuantidade,
                tipoTeclado: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textoGrande: true,
                erro: erroQuantidade,
              ),
            ),
            const SizedBox(width: 10),
            SeletorUnidade(
              selecionada: unidade,
              erro: erroUnidade,
              aoTocar: aoAbrirUnidade,
            ),
          ],
        ),
        AppMensagemErroCampo('Informe a quantidade.', visivel: erroQuantidade),
        AppMensagemErroCampo('Escolha a unidade.', visivel: erroUnidade),
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
      ],
    );
  }
}
