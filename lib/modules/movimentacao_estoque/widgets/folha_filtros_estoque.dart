import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/core/utils/data_extenso.dart';
import 'package:my_app_teste/core/widgets/app_data.dart';
import 'package:my_app_teste/core/widgets/app_folha_selecao.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/filtro_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';

/// Abre a folha de filtros do histórico de movimentações.
///
/// Devolve o [FiltroEstoque] escolhido, ou `null` se o usuário fechar sem
/// aplicar. O filtro em edição vive dentro da folha (`StatefulBuilder`), de
/// modo que fechar sem aplicar não altera a listagem.
///
/// Extraída de `estoque_page.dart`, onde `_openFiltersSheet` ocupava ~310
/// linhas remontando à mão a casca que [abrirFolhaSelecao] fornece.
Future<FiltroEstoque?> abrirFolhaFiltrosEstoque(
  BuildContext context, {
  required FiltroEstoque filtroAtual,
  required List<Insumo> insumos,
}) {
  var filtro = filtroAtual;

  return abrirFolhaSelecao<FiltroEstoque>(
    context,
    titulo: 'Filtrar movimentações',
    altura: 0.78,
    construirConteudo: (ctx) => StatefulBuilder(
      builder: (ctx, redesenhar) {
        void alterar(FiltroEstoque novo) => redesenhar(() => filtro = novo);

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const AppRotuloCampo('Tipo de movimentação'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final opcao in _tiposFiltro.entries)
                        _ChipTipo(
                          rotulo: opcao.value,
                          selecionado: filtro.tipo == opcao.key,
                          aoTocar: () =>
                              alterar(filtro.copiarCom(tipo: opcao.key)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const AppRotuloCampo('Insumo'),
                  const SizedBox(height: 8),
                  _SeletorInsumoFiltro(
                    insumos: insumos,
                    selecionadoId: filtro.insumoId,
                    aoSelecionar: (id) => alterar(
                      id == null
                          ? filtro.copiarCom(limparInsumo: true)
                          : filtro.copiarCom(insumoId: id),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AppRotuloCampo('Período'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _CampoData(
                          rotulo: 'De',
                          valor: filtro.de,
                          aoSelecionar: (data) => alterar(
                            filtro.copiarCom(
                              de: DateTime(data.year, data.month, data.day),
                            ),
                          ),
                          aoLimpar: () =>
                              alterar(filtro.copiarCom(limparDe: true)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CampoData(
                          rotulo: 'Até',
                          valor: filtro.ate,
                          // Fim do dia, para incluir o próprio dia escolhido.
                          aoSelecionar: (data) => alterar(
                            filtro.copiarCom(
                              ate: DateTime(
                                data.year,
                                data.month,
                                data.day,
                                23,
                                59,
                                59,
                              ),
                            ),
                          ),
                          aoLimpar: () =>
                              alterar(filtro.copiarCom(limparAte: true)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, const FiltroEstoque()),
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, filtro),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

const _tiposFiltro = <String, String>{
  FiltroEstoque.tudo: 'Tudo',
  FiltroEstoque.entradas: 'Entradas',
  FiltroEstoque.saidas: 'Saídas',
  FiltroEstoque.ajustes: 'Ajustes',
};

class _ChipTipo extends StatelessWidget {
  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ChipTipo({
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppTema.primaria : AppTema.superficieAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selecionado ? AppTema.primaria : AppTema.borda,
          ),
        ),
        child: Text(
          rotulo,
          style: TextStyle(
            color: selecionado ? Colors.white : AppTema.texto,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SeletorInsumoFiltro extends StatelessWidget {
  final List<Insumo> insumos;
  final int? selecionadoId;
  final ValueChanged<int?> aoSelecionar;

  const _SeletorInsumoFiltro({
    required this.insumos,
    required this.selecionadoId,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: DecoracoesApp.campoPlano(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selecionadoId,
          isExpanded: true,
          borderRadius: BorderRadius.circular(DecoracoesApp.raioCampo),
          dropdownColor: AppTema.superficie,
          style: const TextStyle(color: AppTema.texto, fontSize: 14),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todos os insumos'),
            ),
            for (final insumo in insumos)
              DropdownMenuItem<int?>(
                value: insumo.id,
                child: Text(
                  insumo.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: aoSelecionar,
        ),
      ),
    );
  }
}

/// Campo de data do filtro: mostra a data escolhida e permite limpá-la.
class _CampoData extends StatelessWidget {
  final String rotulo;
  final DateTime? valor;
  final ValueChanged<DateTime> aoSelecionar;
  final VoidCallback aoLimpar;

  const _CampoData({
    required this.rotulo,
    required this.valor,
    required this.aoSelecionar,
    required this.aoLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final preenchido = valor != null;
    return InkWell(
      onTap: () async {
        final escolhida = await abrirSeletorData(
          context,
          dataInicial: valor,
          dataMinima: DateTime(2020),
          dataMaxima: DateTime(2100),
          textoAjuda: rotulo == 'De' ? 'Data inicial' : 'Data final',
        );
        if (escolhida != null) aoSelecionar(escolhida);
      },
      borderRadius: BorderRadius.circular(DecoracoesApp.raioCampo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: DecoracoesApp.campoPlano(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DataExtenso.curta(valor),
                    style: TextStyle(
                      color: preenchido
                          ? AppTema.texto
                          : AppTema.textoSecundario,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (preenchido)
                  InkWell(
                    onTap: aoLimpar,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppTema.textoSecundario,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
