import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';

/// Botão compacto que mostra a unidade escolhida, ao lado da quantidade.
class SeletorUnidade extends StatelessWidget {
  final UnidadeMedida? selecionada;
  final bool erro;
  final VoidCallback aoTocar;

  const SeletorUnidade({
    super.key,
    required this.selecionada,
    required this.aoTocar,
    this.erro = false,
  });

  @override
  Widget build(BuildContext context) {
    final tem = selecionada != null;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(DecoracoesApp.raioCampo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: DecoracoesApp.campoPlano(erro: erro),
        child: Row(
          children: [
            Text(
              tem ? (selecionada!.simbolo ?? selecionada!.nome) : 'Unidade',
              style: TextStyle(
                color: tem ? AppTema.texto : AppTema.textoSecundario,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more_rounded,
              color: AppTema.textoSecundario,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Abre a folha de unidades compatíveis com o insumo escolhido.
Future<void> abrirSelecaoUnidade(
  BuildContext context, {
  required List<UnidadeMedida> unidades,
  required UnidadeMedida? selecionada,
  required String nomeInsumo,
  required String simboloInsumo,
  required ValueChanged<UnidadeMedida> aoSelecionar,
}) {
  return abrirFolhaSelecao(
    context,
    titulo: 'Unidade de medida',
    subtitulo: 'Compatíveis com $nomeInsumo ($simboloInsumo)',
    altura: 0.55,
    construirConteudo: (ctx) {
      if (unidades.isEmpty) {
        return const AppListaVazia('Nenhuma unidade compatível cadastrada');
      }
      return ListView.separated(
        itemCount: unidades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final unidade = unidades[index];
          final marcada = unidade.id == selecionada?.id;
          return AppItemSelecionavel(
            selecionado: marcada,
            aoTocar: () {
              aoSelecionar(unidade);
              Navigator.pop(ctx);
            },
            filho: Row(
              children: [
                Text(
                  unidade.simbolo ?? unidade.nome,
                  style: TextStyle(
                    color: marcada ? AppTema.primaria : AppTema.texto,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    unidade.nome,
                    style: const TextStyle(
                      color: AppTema.texto,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (marcada)
                  const Icon(Icons.check_rounded, color: AppTema.primaria),
              ],
            ),
          );
        },
      );
    },
  );
}
