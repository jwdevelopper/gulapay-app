import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';

/// Etapa 1 do cadastro de produto — nome e descrição.
///
/// Extraída de `produto_form_page.dart`. Os contadores de caracteres
/// dependem do texto digitado, por isso a página reconstrói a cada
/// alteração (via [aoAlterarNome] / [aoAlterarDescricao]).
class EtapaIdentidade extends StatelessWidget {
  final TextEditingController controladorNome;
  final TextEditingController controladorDescricao;
  final ResultadoValidacaoProduto validacao;
  final ValueChanged<String> aoAlterarNome;
  final ValueChanged<String> aoAlterarDescricao;

  const EtapaIdentidade({
    super.key,
    required this.controladorNome,
    required this.controladorDescricao,
    required this.validacao,
    required this.aoAlterarNome,
    required this.aoAlterarDescricao,
  });

  @override
  Widget build(BuildContext context) {
    final erroNome = validacao.erroEm(CampoProduto.nome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRotuloCampo(
          'Nome do produto',
          obrigatorio: true,
          acessorio: _contador(controladorNome.text.length, 120),
        ),
        const SizedBox(height: 8),
        AppCampoFormulario(
          controlador: controladorNome,
          dica: 'Ex.: Picanha na chapa',
          aoAlterar: aoAlterarNome,
          erro: erroNome,
        ),
        AppMensagemErroCampo('Informe o nome do produto.', visivel: erroNome),
        const SizedBox(height: 16),
        AppRotuloCampo(
          'Descrição',
          acessorio: _contador(controladorDescricao.text.length, 500),
        ),
        const SizedBox(height: 8),
        AppCampoFormulario(
          controlador: controladorDescricao,
          dica: 'Detalhes, ingredientes, acompanhamentos...',
          aoAlterar: aoAlterarDescricao,
          maxLinhas: 5,
        ),
        const SizedBox(height: 16),
        const AppCartaoAviso.dica(
          'Use um nome curto e claro. A descrição aparece no cardápio '
          'digital pro cliente.',
        ),
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
      ],
    );
  }

  Widget _contador(int atual, int maximo) => Text(
    '$atual/$maximo',
    style: const TextStyle(color: Color(0xFF8A6A2C), fontSize: 11),
  );
}
