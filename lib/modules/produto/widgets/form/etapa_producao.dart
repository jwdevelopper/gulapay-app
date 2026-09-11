import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/produto/dto/opcoes_produto.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';
import 'package:my_app_teste/modules/produto/widgets/form/resumo_produto.dart';

/// Etapa 3 do cadastro de produto — tipo, setor de produção e resumo.
///
/// Extraída de `produto_form_page.dart`, junto com os dois construtores de
/// opção (`_buildTypeOption` e `_buildSectorOption`) que só divergiam no
/// layout: tipo em grade de dois, setor em lista vertical.
class EtapaProducao extends StatelessWidget {
  final DadosProduto dados;
  final String nomeCategoria;
  final ResultadoValidacaoProduto validacao;
  final ValueChanged<String> aoSelecionarTipo;
  final ValueChanged<String> aoSelecionarSetor;

  const EtapaProducao({
    super.key,
    required this.dados,
    required this.nomeCategoria,
    required this.validacao,
    required this.aoSelecionarTipo,
    required this.aoSelecionarSetor,
  });

  @override
  Widget build(BuildContext context) {
    final erroTipo = validacao.erroEm(CampoProduto.tipo);
    final erroSetor = validacao.erroEm(CampoProduto.setor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppRotuloCampo('Tipo do produto', obrigatorio: true),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.25,
          children: [
            for (final opcao in tiposProduto)
              _CartaoOpcao(
                opcao: opcao,
                selecionado: dados.tipo == opcao.valor,
                erro: erroTipo,
                emGrade: true,
                aoTocar: () => aoSelecionarTipo(opcao.valor),
              ),
          ],
        ),
        AppMensagemErroCampo(
          'Selecione um tipo de produto.',
          visivel: erroTipo,
        ),
        const SizedBox(height: 18),
        const AppRotuloCampo('Setor de produção', obrigatorio: true),
        const SizedBox(height: 8),
        for (final opcao in setoresProducao)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CartaoOpcao(
              opcao: opcao,
              selecionado: dados.setor == opcao.valor,
              erro: erroSetor,
              emGrade: false,
              aoTocar: () => aoSelecionarSetor(opcao.valor),
            ),
          ),
        AppMensagemErroCampo(
          'Selecione o setor de produção.',
          visivel: erroSetor,
        ),
        const SizedBox(height: 16),
        AppCartaoAviso.erro(validacao.mensagem),
        if (validacao.mensagem != null) const SizedBox(height: 16),
        ResumoProduto(dados: dados, nomeCategoria: nomeCategoria),
      ],
    );
  }
}

/// Cartão de uma opção selecionável.
///
/// [emGrade] alterna entre os dois layouts: vertical (ícone em cima,
/// textos embaixo) para a grade de tipos, e horizontal (ícone à esquerda)
/// para a lista de setores.
class _CartaoOpcao extends StatelessWidget {
  final OpcaoEscolha opcao;
  final bool selecionado;
  final bool erro;
  final bool emGrade;
  final VoidCallback aoTocar;

  const _CartaoOpcao({
    required this.opcao,
    required this.selecionado,
    required this.erro,
    required this.emGrade,
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
        child: emGrade ? _conteudoVertical() : _conteudoHorizontal(),
      ),
    );
  }

  Widget _icone(double tamanho) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(
      color: selecionado ? AppTema.primaria : AppTema.preenchimentoCampo,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(
      opcao.icone,
      color: selecionado ? Colors.white : AppTema.primaria,
      size: tamanho * 0.5,
    ),
  );

  Widget get _rotulo => Text(
    opcao.rotulo,
    style: const TextStyle(
      color: AppTema.texto,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget get _descricao => Text(
    opcao.descricao,
    style: const TextStyle(
      color: AppTema.textoSecundario,
      fontSize: 11,
      height: 1.2,
    ),
  );

  Widget get _marca => selecionado
      ? const Icon(
          Icons.check_circle_rounded,
          color: AppTema.primaria,
          size: 18,
        )
      : const SizedBox.shrink();

  Widget _conteudoVertical() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [_icone(34), const Spacer(), _marca]),
      const SizedBox(height: 14),
      _rotulo,
      const SizedBox(height: 4),
      _descricao,
    ],
  );

  Widget _conteudoHorizontal() => Row(
    children: [
      _icone(40),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_rotulo, const SizedBox(height: 2), _descricao],
        ),
      ),
      _marca,
    ],
  );
}
