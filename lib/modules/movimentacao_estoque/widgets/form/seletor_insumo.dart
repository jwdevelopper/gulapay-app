import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_seletor.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';

/// Campo que exibe o insumo escolhido e abre a folha de seleção ao toque.
///
/// É o [AppCampoSeletor] com o rótulo, o ícone e o detalhe (saldo atual)
/// do insumo já preenchidos.
class SeletorInsumo extends StatelessWidget {
  final Insumo? selecionado;
  final bool erro;
  final VoidCallback aoTocar;

  const SeletorInsumo({
    super.key,
    required this.selecionado,
    required this.aoTocar,
    this.erro = false,
  });

  /// Saldo do insumo escolhido, na segunda linha do campo.
  String? get _saldo {
    final insumo = selecionado;
    if (insumo == null) return null;
    return 'Saldo atual: ${insumo.estoqueAtual?.toStringAsFixed(1) ?? '0'} '
        '${insumo.unidadePadraoSimbolo ?? ''}';
  }

  @override
  Widget build(BuildContext context) => AppCampoSeletor(
    rotulo: 'Insumo',
    obrigatorio: true,
    valor: selecionado?.nome ?? '',
    detalhe: _saldo,
    dica: 'Selecione o insumo',
    icone: Icons.inventory_2_rounded,
    erro: erro,
    aoTocar: aoTocar,
  );
}

/// Abre a folha de escolha de insumo; devolve a escolha via [aoSelecionar].
Future<void> abrirSelecaoInsumo(
  BuildContext context, {
  required List<Insumo> insumos,
  required Insumo? selecionado,
  required ValueChanged<Insumo> aoSelecionar,
}) {
  return abrirFolhaSelecao(
    context,
    titulo: 'Escolher insumo',
    altura: 0.72,
    construirConteudo: (ctx) {
      if (insumos.isEmpty) {
        return const AppListaVazia('Sem insumos cadastrados');
      }
      return ListView.separated(
        itemCount: insumos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final insumo = insumos[index];
          final marcado = insumo.id == selecionado?.id;
          return AppItemSelecionavel(
            selecionado: marcado,
            aoTocar: () {
              aoSelecionar(insumo);
              Navigator.pop(ctx);
            },
            filho: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: marcado
                        ? AppTema.primaria
                        : AppTema.preenchimentoCampo,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: marcado ? Colors.white : AppTema.primaria,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insumo.nome,
                        style: const TextStyle(
                          color: AppTema.texto,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saldo atual: '
                        '${insumo.estoqueAtual?.toStringAsFixed(1) ?? '0'} '
                        '${insumo.unidadePadraoSimbolo ?? ''}',
                        style: const TextStyle(
                          color: AppTema.textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (marcado)
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
