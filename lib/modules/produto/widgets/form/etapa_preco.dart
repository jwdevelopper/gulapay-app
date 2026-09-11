import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';
import 'package:my_app_teste/modules/produto/widgets/form/seletor_categoria.dart';

/// Etapa 2 do cadastro de produto — preço de venda e categoria.
///
/// Extraída de `produto_form_page.dart`.
class EtapaPreco extends StatelessWidget {
  final TextEditingController controladorPreco;
  final Categoria? categoria;
  final ResultadoValidacaoProduto validacao;
  final ValueChanged<String> aoAlterarPreco;
  final VoidCallback aoAbrirCategoria;

  const EtapaPreco({
    super.key,
    required this.controladorPreco,
    required this.categoria,
    required this.validacao,
    required this.aoAlterarPreco,
    required this.aoAbrirCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final erroPreco = validacao.erroEm(CampoProduto.preco);
    final erroCategoria = validacao.erroEm(CampoProduto.categoria);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotuloCampo('Preço de venda', obrigatorio: true),
        const SizedBox(height: 8),
        AppCampoFormulario(
          controlador: controladorPreco,
          dica: '89,00',
          aoAlterar: aoAlterarPreco,
          tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          preco: true,
          erro: erroPreco,
        ),
        AppMensagemErroCampo('Informe um preço válido.', visivel: erroPreco),
        const SizedBox(height: 16),
        SeletorCategoria(
          selecionada: categoria,
          erro: erroCategoria,
          aoTocar: aoAbrirCategoria,
        ),
        AppMensagemErroCampo(
          'Selecione uma categoria.',
          visivel: erroCategoria,
        ),
        const SizedBox(height: 16),
        const AppCartaoAviso.dica(
          'Margem típica de pratos principais: 60–70%. Ajuste o preço de '
          'acordo com seu posicionamento.',
        ),
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
      ],
    );
  }
}
