import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/modules/produto/dto/filtro_produtos.dart';

/// Folha de escolha da ordenação da vitrine.
///
/// Usa a casca padrão de [abrirFolhaSelecao] e o [AppItemSelecionavel] do
/// core — antes montava a própria folha à mão, repetindo alça, cabeçalho e
/// item selecionado.
class ProdutoSortSheet {
  const ProdutoSortSheet._();

  /// Abre a folha e devolve a ordenação escolhida, ou `null` se fechada.
  static Future<OrdenacaoProduto?> mostrar(
    BuildContext context, {
    required OrdenacaoProduto selecionada,
  }) => showModalBottomSheet<OrdenacaoProduto>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (contexto) => _Folha(selecionada: selecionada),
  );
}

/// Ícone e explicação de cada ordenação. Ficam aqui, e não no enum, para
/// [FiltroProdutos] continuar sem depender de Flutter.
const _detalhes = <OrdenacaoProduto, ({IconData icone, String descricao})>{
  OrdenacaoProduto.destaque: (
    icone: Icons.local_fire_department_rounded,
    descricao: 'Ordem padrão da lista',
  ),
  OrdenacaoProduto.precoCrescente: (
    icone: Icons.arrow_upward_rounded,
    descricao: 'Do menor para o maior',
  ),
  OrdenacaoProduto.precoDecrescente: (
    icone: Icons.arrow_downward_rounded,
    descricao: 'Do maior para o menor',
  ),
  OrdenacaoProduto.nomeCrescente: (
    icone: Icons.sort_by_alpha_rounded,
    descricao: 'Alfabética crescente',
  ),
  OrdenacaoProduto.nomeDecrescente: (
    icone: Icons.sort_by_alpha_rounded,
    descricao: 'Alfabética decrescente',
  ),
};

class _Folha extends StatelessWidget {
  final OrdenacaoProduto selecionada;

  const _Folha({required this.selecionada});

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: 0.56,
    child: Container(
      decoration: const BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Alca(),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ordenar produtos',
                      style: TextStyle(
                        color: AppTema.texto,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppTema.texto,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: OrdenacaoProduto.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final opcao = OrdenacaoProduto.values[i];
                    final detalhe = _detalhes[opcao]!;
                    return AppItemSelecionavel(
                      selecionado: opcao == selecionada,
                      aoTocar: () => Navigator.pop(context, opcao),
                      filho: _Linha(
                        icone: detalhe.icone,
                        titulo: opcao.rotulo,
                        descricao: detalhe.descricao,
                        selecionado: opcao == selecionada,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Alca extends StatelessWidget {
  const _Alca();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTema.bordaSuave,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}

class _Linha extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final bool selecionado;

  const _Linha({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.selecionado,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selecionado ? AppTema.primaria : AppTema.preenchimentoCampo,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icone,
          color: selecionado ? Colors.white : AppTema.primaria,
          size: 20,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: AppTema.texto,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              descricao,
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      if (selecionado)
        const Icon(Icons.check_rounded, color: AppTema.primaria)
      else
        const SizedBox(width: 18),
    ],
  );
}
