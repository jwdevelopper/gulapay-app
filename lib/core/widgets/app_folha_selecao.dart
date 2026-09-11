import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Abre uma folha inferior (bottom sheet) com a moldura padrão do app.
///
/// Fonte única da casca das folhas de seleção: alça de arraste, título,
/// botão de fechar, subtítulo opcional e área rolável. Esse bloco estava
/// copiado em 11 arquivos, com ~50 linhas cada e divergências de raio e
/// espaçamento.
///
/// [altura] é a fração da tela ocupada (0 a 1). Referências úteis:
/// `0.4` para listas curtas, `0.55` para médias, `0.72` para longas.
///
/// ## Exemplo
///
/// ```dart
/// await abrirFolhaSelecao(
///   context,
///   titulo: 'Escolher insumo',
///   altura: 0.72,
///   construirConteudo: (ctx) => ListView.separated(
///     itemCount: insumos.length,
///     separatorBuilder: (_, __) => const SizedBox(height: 10),
///     itemBuilder: (_, i) => AppItemSelecionavel(
///       selecionado: insumos[i].id == escolhido?.id,
///       aoTocar: () {
///         aoSelecionar(insumos[i]);
///         Navigator.pop(ctx);
///       },
///       filho: Text(insumos[i].nome),
///     ),
///   ),
/// );
/// ```
///
/// Veja também:
///  * [AppItemSelecionavel], para os itens da lista.
///  * [AppListaVazia], para o caso de a lista vir sem elementos.
Future<T?> abrirFolhaSelecao<T>(
  BuildContext context, {
  required String titulo,
  required double altura,
  required WidgetBuilder construirConteudo,
  String? subtitulo,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => FractionallySizedBox(
      heightFactor: altura,
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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTema.bordaSuave,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          color: AppTema.texto,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTema.texto,
                    ),
                  ],
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Expanded(child: construirConteudo(ctx)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Item de lista com estado de selecionado.
///
/// Usado dentro das folhas de seleção e também em listas embutidas na
/// página (seleção de lote, de tipo de movimentação). Quando
/// [selecionado] é `true`, troca fundo e borda para o destaque laranja.
///
/// ```dart
/// AppItemSelecionavel(
///   selecionado: unidade.id == escolhida?.id,
///   aoTocar: () => aoSelecionar(unidade),
///   filho: Text(unidade.nome),
/// )
/// ```
class AppItemSelecionavel extends StatelessWidget {
  /// Estado visual de destaque.
  final bool selecionado;

  /// Ação ao tocar. Em folhas, lembre de fechar com `Navigator.pop`.
  final VoidCallback aoTocar;

  /// Conteúdo do item — normalmente uma `Row` com ícone, textos e a marca
  /// de seleção.
  final Widget filho;

  /// Espaçamento interno.
  final EdgeInsets padding;

  /// Raio dos cantos. `18` nas folhas, `16` nas listas embutidas.
  final double raio;

  const AppItemSelecionavel({
    super.key,
    required this.selecionado,
    required this.aoTocar,
    required this.filho,
    this.padding = const EdgeInsets.all(14),
    this.raio = 18,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(raio),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: selecionado ? AppTema.avisoFundo : AppTema.superficieAlt,
          borderRadius: BorderRadius.circular(raio),
          border: Border.all(
            color: selecionado ? AppTema.primaria : AppTema.borda,
          ),
        ),
        child: filho,
      ),
    );
  }
}

/// Mensagem centralizada para listas sem elementos dentro de uma folha.
///
/// Diferente de [AppEstadoVazio], que é para a tela toda: esta é a versão
/// enxuta, sem ícone nem botão, para o interior de uma folha de seleção.
class AppListaVazia extends StatelessWidget {
  final String texto;

  const AppListaVazia(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTema.textoSecundario,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
