/// Cartão de um item da comanda, com menu de ações contextual.
///
/// Extraído de `comanda_detalhe_page.dart`, onde ocupava ~213 linhas como
/// método do `State`. Puramente visual: recebe as permissões já resolvidas
/// e devolve as ações por callback, sem conhecer perfil de usuário nem
/// estado da comanda.
///
/// As permissões seguem a matriz 5.2.1 do backend — editar só em
/// `EM_PREPARO`; transferir e cancelar em `ENTREGUE` apenas para
/// caixa/admin — mas quem as calcula é a página.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/comanda/dto/item_comanda_response.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';

class CartaoItemComanda extends StatelessWidget {
  /// Item exibido.
  final ItemComandaResponse item;

  /// Permite abrir o formulário de edição (item em `EM_PREPARO`).
  final bool podeEditar;

  /// Permite marcar como entregue.
  final bool podeEntregar;

  /// Permite transferir para outra comanda da mesma mesa.
  final bool podeTransferir;

  /// Permite cancelar com motivo.
  final bool podeCancelar;

  final VoidCallback aoEditar;
  final VoidCallback aoEntregar;
  final VoidCallback aoTransferir;
  final VoidCallback aoCancelar;

  /// Abre a linha do tempo de auditoria do item.
  final VoidCallback aoVerEventos;

  /// Desabilita os botões enquanto outra ação está em curso.
  final bool acaoEmAndamento;

  const CartaoItemComanda({
    super.key,
    required this.item,
    required this.podeEditar,
    required this.podeEntregar,
    required this.podeTransferir,
    required this.podeCancelar,
    required this.aoEditar,
    required this.aoEntregar,
    required this.aoTransferir,
    required this.aoCancelar,
    required this.aoVerEventos,
    this.acaoEmAndamento = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = RotulosComanda.corStatusItem(item.status);
    final menuItems = <PopupMenuEntry<String>>[
      if (podeEditar) _itemDeMenu('editar', Icons.edit_rounded, 'Editar'),
      if (podeTransferir)
        _itemDeMenu('transferir', Icons.swap_horiz_rounded, 'Transferir'),
      if (item.id != null)
        _itemDeMenu('eventos', Icons.history_rounded, 'Histórico'),
      if (podeCancelar) ...[
        const PopupMenuDivider(height: 8),
        _itemDeMenu(
          'cancelar',
          Icons.cancel_outlined,
          'Cancelar item',
          danger: true,
        ),
      ],
    ];
    final temMenu = menuItems.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppTema.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTema.borda),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTema.preenchimentoCampo,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: AppTema.primaria,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.produtoNome,
                        style: const TextStyle(
                          color: AppTema.texto,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.quantidade} × ${RotulosComanda.dinheiro(item.precoUnitario)}',
                        style: const TextStyle(
                          color: AppTema.textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                      if (item.valorDesconto > 0 ||
                          item.valorAcrescimo > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (item.valorDesconto > 0)
                              'Desc. ${RotulosComanda.dinheiro(item.valorDesconto)}',
                            if (item.valorAcrescimo > 0)
                              'Acrés. ${RotulosComanda.dinheiro(item.valorAcrescimo)}',
                          ].join(' · '),
                          style: const TextStyle(
                            color: AppTema.textoSecundario,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (item.observacao?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.observacao!,
                          maxLines: 2,
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
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      RotulosComanda.dinheiro(item.subtotal),
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppTag(
                      RotulosComanda.statusItem(item.status),
                      fundo: color.withValues(alpha: 0.12),
                      cor: color,
                    ),
                  ],
                ),
                if (temMenu)
                  PopupMenuButton<String>(
                    tooltip: 'Ações do item',
                    enabled: !acaoEmAndamento,
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 8),
                    color: AppTema.superficie,
                    surfaceTintColor: Colors.transparent,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTema.borda),
                    ),
                    constraints: const BoxConstraints(minWidth: 180),
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppTema.textoSecundario,
                      size: 22,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'editar':
                          aoEditar();
                        case 'transferir':
                          aoTransferir();
                        case 'eventos':
                          aoVerEventos();
                        case 'cancelar':
                          aoCancelar();
                      }
                    },
                    itemBuilder: (_) => menuItems,
                  ),
              ],
            ),
            if (podeEntregar) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: acaoEmAndamento ? null : () => aoEntregar(),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('Marcar como entregue'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTema.primaria,
                      side: const BorderSide(color: AppTema.primaria),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _itemDeMenu(
    String value,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    final color = danger ? AppTema.erro : AppTema.texto;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: danger ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
