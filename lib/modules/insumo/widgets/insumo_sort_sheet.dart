import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/modules/insumo/dto/filtro_insumos.dart';

/// Folha de escolha da ordenação da listagem de insumos.
///
/// Usa a casca padrão de [abrirFolhaSelecao] e o [AppItemSelecionavel] do
/// core, no lugar da folha montada à mão que existia aqui.
class InsumoSortSheet {
  const InsumoSortSheet._();

  /// Abre a folha e devolve a ordenação escolhida, ou `null` se fechada.
  static Future<OrdenacaoInsumo?> mostrar(
    BuildContext context, {
    required OrdenacaoInsumo selecionada,
  }) => abrirFolhaSelecao<OrdenacaoInsumo>(
    context,
    titulo: 'Ordenar insumos',
    altura: 0.62,
    construirConteudo: (folha) => ListView.separated(
      itemCount: OrdenacaoInsumo.values.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final opcao = OrdenacaoInsumo.values[i];
        return AppItemSelecionavel(
          selecionado: opcao == selecionada,
          aoTocar: () => Navigator.pop(folha, opcao),
          filho: _Linha(opcao: opcao, selecionado: opcao == selecionada),
        );
      },
    ),
  );
}

/// Ícone de cada ordenação. Fica aqui, e não no enum, para
/// [FiltroInsumos] continuar sem depender de Flutter.
const _icones = <OrdenacaoInsumo, IconData>{
  OrdenacaoInsumo.alerta: Icons.priority_high_rounded,
  OrdenacaoInsumo.estoqueCrescente: Icons.arrow_upward_rounded,
  OrdenacaoInsumo.estoqueDecrescente: Icons.arrow_downward_rounded,
  OrdenacaoInsumo.nomeCrescente: Icons.sort_by_alpha_rounded,
  OrdenacaoInsumo.nomeDecrescente: Icons.sort_by_alpha_rounded,
  OrdenacaoInsumo.unidade: Icons.straighten_rounded,
};

class _Linha extends StatelessWidget {
  final OrdenacaoInsumo opcao;
  final bool selecionado;

  const _Linha({required this.opcao, required this.selecionado});

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
          _icones[opcao],
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
              opcao.rotulo,
              style: const TextStyle(
                color: AppTema.texto,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              opcao.descricao,
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
