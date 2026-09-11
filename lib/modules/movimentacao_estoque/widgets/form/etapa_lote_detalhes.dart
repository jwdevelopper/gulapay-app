import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_data.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/resumo_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/seletor_lote.dart';

/// Etapa 3 — lote e detalhes.
///
/// O conteúdo muda conforme o tipo: **entrada** cria um lote novo (validade
/// e custo obrigatórios); **saída/ajuste** baixa de um lote existente
/// (seleção do lote obrigatória).
class EtapaLoteDetalhes extends StatelessWidget {
  final DadosMovimentacao dados;
  final List<Lote> lotes;
  final ResultadoValidacao validacao;
  final TextEditingController controladorCusto;
  final TextEditingController controladorCodigoLote;
  final TextEditingController controladorJustificativa;
  final ValueChanged<DateTime> aoSelecionarValidade;
  final ValueChanged<Lote> aoSelecionarLote;
  final ValueChanged<CampoMovimentacao> aoEditarCampo;

  const EtapaLoteDetalhes({
    super.key,
    required this.dados,
    required this.lotes,
    required this.validacao,
    required this.controladorCusto,
    required this.controladorCodigoLote,
    required this.controladorJustificativa,
    required this.aoSelecionarValidade,
    required this.aoSelecionarLote,
    required this.aoEditarCampo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dados.ehEntrada) ..._camposDeEntrada() else ..._camposDeSaida(),
        const AppRotuloCampo('Observação'),
        const SizedBox(height: 8),
        AppCampoFormulario(
          controlador: controladorJustificativa,
          dica: 'Motivo ou observação...',
          maxLinhas: 3,
        ),
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
        if (validacao.mensagem != null) const SizedBox(height: 16),
        ResumoMovimentacao(dados: dados),
      ],
    );
  }

  List<Widget> _camposDeEntrada() {
    final erroValidade = validacao.erroEm(CampoMovimentacao.validade);
    final erroCusto = validacao.erroEm(CampoMovimentacao.custoUnitario);

    return [
      const AppRotuloCampo('Validade', obrigatorio: true),
      const SizedBox(height: 8),
      AppCampoData(
        valor: dados.validade,
        erro: erroValidade,
        textoAjuda: 'Validade do lote',
        aoSelecionar: aoSelecionarValidade,
      ),
      AppMensagemErroCampo(
        'Informe a validade do lote.',
        visivel: erroValidade,
      ),
      const SizedBox(height: 16),
      const AppRotuloCampo('Custo unitário', obrigatorio: true),
      const SizedBox(height: 8),
      AppCampoFormulario(
        controlador: controladorCusto,
        dica: '0,00',
        tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
        preco: true,
        erro: erroCusto,
        aoAlterar: (_) => aoEditarCampo(CampoMovimentacao.custoUnitario),
      ),
      AppMensagemErroCampo('Informe o custo unitário.', visivel: erroCusto),
      const SizedBox(height: 16),
      const AppRotuloCampo('Código do lote'),
      const SizedBox(height: 8),
      AppCampoFormulario(
        controlador: controladorCodigoLote,
        dica: 'Ex.: NF-8821',
      ),
      const SizedBox(height: 16),
      const AppCartaoAviso.dica(
        'Novo lote será criado com a validade e custo informados.',
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _camposDeSaida() {
    return [
      SeletorLote(
        lotes: lotes,
        selecionado: dados.lote,
        erro: validacao.erroEm(CampoMovimentacao.lote),
        aoSelecionar: aoSelecionarLote,
      ),
      const SizedBox(height: 16),
    ];
  }
}
