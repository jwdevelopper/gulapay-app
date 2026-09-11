import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/data_extenso.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/filtro_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/movimentacao_card.dart';

/// Aba de histórico do estoque — movimentações agrupadas por dia.
///
/// Extraída de `estoque_page.dart`. Distingue três vazios diferentes, que
/// pedem mensagens diferentes: nunca houve movimentação, o filtro não
/// achou nada, ou o insumo filtrado não tem histórico.
class AbaHistorico extends StatelessWidget {
  /// Todas as movimentações carregadas, antes do filtro.
  final List<MovimentacaoEstoque> todas;

  /// Movimentações já filtradas e ordenadas — vem de
  /// [FiltroEstoque.aplicar].
  final List<MovimentacaoEstoque> visiveis;

  /// Usada só para nomear o insumo na mensagem de vazio.
  final List<Insumo> insumos;

  final FiltroEstoque filtro;
  final bool carregando;
  final VoidCallback aoRegistrar;
  final VoidCallback aoLimparFiltros;

  const AbaHistorico({
    super.key,
    required this.todas,
    required this.visiveis,
    required this.insumos,
    required this.filtro,
    required this.carregando,
    required this.aoRegistrar,
    required this.aoLimparFiltros,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) return const AppCarregando();
    if (todas.isEmpty) return _primeiroUso();
    if (visiveis.isEmpty) return _semResultado();
    return _listaAgrupada();
  }

  /// Nunca houve movimentação — orienta o primeiro passo.
  Widget _primeiroUso() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
    children: [
      AppEstadoVazio(
        icone: Icons.swap_vert_rounded,
        titulo: 'Sem movimentações ainda',
        mensagem:
            'Registre uma entrada por compra para começar a controlar o '
            'estoque do seu restaurante.',
        rotuloBotao: 'Registrar movimentação',
        aoTocarBotao: aoRegistrar,
        dica:
            'Antes da primeira movimentação, cadastre seus insumos e '
            'unidades de medida em Cadastros > Estoque.',
      ),
    ],
  );

  /// Há histórico, mas o filtro atual não devolveu nada.
  Widget _semResultado() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 96),
    children: [
      AppEstadoVazio(
        icone: Icons.filter_alt_off_rounded,
        titulo: 'Nada por aqui',
        mensagem: _mensagemDoVazio(),
        rotuloBotao: 'Limpar filtros',
        iconeBotao: Icons.filter_alt_off_rounded,
        secundario: true,
        aoTocarBotao: aoLimparFiltros,
      ),
    ],
  );

  String _mensagemDoVazio() {
    if (filtro.insumoId != null) {
      final insumo = insumos.firstWhere(
        (i) => i.id == filtro.insumoId,
        orElse: () => Insumo(nome: ''),
      );
      final nome = insumo.nome.isEmpty ? 'Este insumo' : insumo.nome;
      return '$nome não tem movimentação de estoque.';
    }
    if (filtro.de != null || filtro.ate != null) {
      return 'Nenhuma movimentação encontrada no período selecionado.';
    }
    return 'Nenhuma movimentação encontrada com os filtros aplicados.';
  }

  Widget _listaAgrupada() {
    final porDia = <String, List<MovimentacaoEstoque>>{};
    for (final mov in visiveis) {
      porDia.putIfAbsent(DataExtenso.chaveDoDia(mov.dataHora), () => []);
      porDia[DataExtenso.chaveDoDia(mov.dataHora)]!.add(mov);
    }
    final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: dias.length,
      itemBuilder: (context, indice) {
        final doDia = porDia[dias[indice]]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (indice > 0) const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                DataExtenso.cabecalho(doDia.first.dataHora),
                style: const TextStyle(
                  color: AppTema.textoSecundario,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            for (final mov in doDia)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MovimentacaoCard(
                  insumoNome: mov.insumoNome ?? 'Insumo #${mov.insumoId}',
                  tipo: mov.tipo ?? '',
                  quantidade: mov.quantidade,
                  unidadeSimbolo:
                      mov.unidadeSimbolo ?? mov.unidadePadraoSimbolo,
                  detalhes: mov.justificativa,
                  hora: DataExtenso.hora(mov.dataHora),
                  responsavel: mov.responsavel,
                ),
              ),
          ],
        );
      },
    );
  }
}
