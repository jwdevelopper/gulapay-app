import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/paleta_app.dart';
import 'package:my_app_teste/core/widgets/app_menu_acoes.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

import 'produto_card_container.dart';
import 'produto_tag.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final String subtitle;
  final String categoriaNome;
  final IconData icon;
  final Color accentColor;
  final String sectorLabel;
  final Color sectorColor;
  final String priceText;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  /// Mesma função usada pelo [Dismissible] no swipe-to-delete e pelo PopupMenu
  /// "Excluir produto". O parent é responsável por mostrar a confirmação,
  /// chamar a API e devolver [true] quando o card pode ser removido da lista.
  final Future<bool> Function() onConfirmDelete;

  const ProdutoCard({
    super.key,
    required this.produto,
    required this.subtitle,
    required this.categoriaNome,
    required this.icon,
    required this.accentColor,
    required this.sectorLabel,
    required this.sectorColor,
    required this.priceText,
    required this.onTap,
    required this.onEdit,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ProdutoCardContainer(
      onTap: onTap,
      dismissibleKey: (produto.id ?? produto.nome).toString(),
      onConfirmDelete: onConfirmDelete,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: PaletaApp.text, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    color: PaletaApp.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PaletaApp.textMuted,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ProdutoTag(label: sectorLabel, color: sectorColor),
                    if (categoriaNome.isNotEmpty)
                      ProdutoTag(
                        label: categoriaNome,
                        color: PaletaApp.primary,
                        filled: false,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                priceText,
                style: const TextStyle(
                  color: PaletaApp.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppMenuAcoes(
                onEditar: onEdit,
                // Fallback ao swipe: mesma função de confirmação + delete.
                onExcluir: () => onConfirmDelete(),
                rotuloEditar: 'Editar produto',
                rotuloExcluir: 'Excluir produto',
                tooltip: 'Ações do produto',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
