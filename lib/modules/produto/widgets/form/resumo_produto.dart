import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_linha_resumo.dart';
import 'package:my_app_teste/modules/produto/dto/opcoes_produto.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';

/// Cartão de resumo exibido na última etapa do cadastro de produto.
///
/// Extraído de `produto_form_page.dart`. Usa [AppLinhaResumo], o mesmo
/// componente do resumo de movimentação de estoque.
class ResumoProduto extends StatelessWidget {
  final DadosProduto dados;

  /// Nome da categoria já resolvido pela página — o resumo não busca
  /// categoria, só exibe.
  final String nomeCategoria;

  const ResumoProduto({
    super.key,
    required this.dados,
    required this.nomeCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final preco = dados.precoNumerico;
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
            rotulo: 'Produto',
            valor: dados.nome.trim().isEmpty ? '-' : dados.nome.trim(),
          ),
          const _Separador(),
          AppLinhaResumo(rotulo: 'Categoria', valor: nomeCategoria),
          const _Separador(),
          AppLinhaResumo(
            rotulo: 'Preço',
            valor: preco <= 0
                ? '-'
                : 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
          ),
          const _Separador(),
          AppLinhaResumo(
            rotulo: 'Tipo',
            valor: rotuloDaOpcao(tiposProduto, dados.tipo),
          ),
          const _Separador(),
          AppLinhaResumo(
            rotulo: 'Setor',
            valor: rotuloDaOpcao(setoresProducao, dados.setor),
          ),
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
