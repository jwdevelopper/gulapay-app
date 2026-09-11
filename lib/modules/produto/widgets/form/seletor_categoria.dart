import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_seletor.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

/// Campo que exibe a categoria escolhida e abre a folha de seleção ao
/// toque.
///
/// É o [AppCampoSeletor] com o rótulo e o ícone da categoria. Extraído de
/// `produto_form_page.dart`, onde o campo e a folha somavam ~265 linhas
/// dentro do `State` — a folha era montada à mão, com a mesma casca que
/// [abrirFolhaSelecao] fornece.
class SeletorCategoria extends StatelessWidget {
  final Categoria? selecionada;
  final bool erro;
  final VoidCallback aoTocar;

  const SeletorCategoria({
    super.key,
    required this.selecionada,
    required this.aoTocar,
    this.erro = false,
  });

  @override
  Widget build(BuildContext context) => AppCampoSeletor(
    rotulo: 'Categoria',
    obrigatorio: true,
    valor: selecionada?.nome ?? '',
    dica: 'Selecione a categoria',
    icone: selecionada == null
        ? Icons.category_rounded
        : iconeDaCategoria(selecionada!.nome),
    erro: erro,
    aoTocar: aoTocar,
  );
}

/// Abre a folha de escolha de categoria; devolve a escolha por
/// [aoSelecionar].
Future<void> abrirSelecaoCategoria(
  BuildContext context, {
  required List<Categoria> categorias,
  required int? categoriaSelecionadaId,
  required ValueChanged<Categoria> aoSelecionar,
}) {
  return abrirFolhaSelecao(
    context,
    titulo: 'Escolher categoria',
    altura: 0.72,
    construirConteudo: (ctx) {
      if (categorias.isEmpty) {
        return const AppListaVazia(
          'Nenhuma categoria cadastrada.\n'
          'Cadastre uma categoria antes de criar o produto.',
        );
      }
      return ListView.separated(
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final marcada = categoria.id == categoriaSelecionadaId;
          return AppItemSelecionavel(
            selecionado: marcada,
            aoTocar: () {
              aoSelecionar(categoria);
              Navigator.pop(ctx);
            },
            filho: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: marcada
                        ? AppTema.primaria
                        : AppTema.preenchimentoCampo,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    iconeDaCategoria(categoria.nome),
                    color: marcada ? Colors.white : AppTema.primaria,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nome,
                        style: const TextStyle(
                          color: AppTema.texto,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((categoria.descricao ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          categoria.descricao!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTema.textoSecundario,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (marcada)
                  const Icon(Icons.check_rounded, color: AppTema.primaria)
                else
                  const SizedBox(width: 18),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Ícone sugerido pelo nome da categoria — heurística visual, sem
/// significado de negócio.
IconData iconeDaCategoria(String nome) {
  final texto = nome.toLowerCase();
  if (texto.contains('beb')) return Icons.local_bar_rounded;
  if (texto.contains('sob')) return Icons.cake_rounded;
  if (texto.contains('entr')) return Icons.ramen_dining_rounded;
  if (texto.contains('por')) return Icons.fastfood_rounded;
  return Icons.restaurant_rounded;
}
