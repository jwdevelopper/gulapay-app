import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/modules/comanda/dto/filtro_comandas.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';

/// Barra de chips de filtro da listagem de comandas.
///
/// Duas famílias na mesma fileira rolável: os status (com "Todas" à
/// esquerda) e, depois de um respiro, os canais de venda. Tocar num chip já
/// escolhido o desmarca — ver [FiltroComandas.alternarStatus].
///
/// O widget não guarda estado: recebe o [filtro] atual e devolve o próximo
/// por [aoMudar], deixando a página decidir quando recarregar.
class FiltrosComandas extends StatelessWidget {
  /// Filtro em vigor.
  final FiltroComandas filtro;

  /// Chamado com o filtro já alterado.
  final ValueChanged<FiltroComandas> aoMudar;

  const FiltrosComandas({
    super.key,
    required this.filtro,
    required this.aoMudar,
  });

  @override
  Widget build(BuildContext context) => AppFileiraChips(
    chips: [
      AppChipFiltro(
        rotulo: 'Todas',
        selecionado: filtro.status == null,
        aoTocar: () => aoMudar(filtro.alternarStatus(null)),
      ),
      for (final status in FiltroComandas.statusDisponiveis)
        AppChipFiltro(
          rotulo: RotulosComanda.status(status),
          selecionado: filtro.status == status,
          aoTocar: () => aoMudar(filtro.alternarStatus(status)),
        ),
      const SizedBox(width: 4),
      for (final canal in FiltroComandas.canaisDisponiveis)
        AppChipFiltro(
          rotulo: RotulosComanda.origem(canal),
          icone: RotulosComanda.iconeOrigem(canal),
          selecionado: filtro.tipoOrigem == canal,
          aoTocar: () => aoMudar(filtro.alternarCanal(canal)),
        ),
    ],
  );
}
