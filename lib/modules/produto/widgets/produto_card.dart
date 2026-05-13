import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

import 'produto_card_container.dart';
import 'produto_tag.dart';
import 'produtos_palette.dart';

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
  final VoidCallback onDelete;

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
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ProdutoCardContainer(
      onTap: onTap,
      actions: [
        ProdutoCardAction(
          label: 'Excluir',
          icon: Icons.delete_outline_rounded,
          backgroundColor: ProdutosPalette.primaryPressed,
          foregroundColor: Colors.white,
          onTap: onDelete,
        ),
      ],
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
            child: Icon(icon, color: ProdutosPalette.text, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    color: ProdutosPalette.text,
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
                    color: ProdutosPalette.textMuted,
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
                        color: ProdutosPalette.primary,
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
                  color: ProdutosPalette.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              PopupMenuButton<String>(
                tooltip: 'Acoes do produto',
                padding: EdgeInsets.zero,
                offset: const Offset(0, 8),
                color: ProdutosPalette.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: ProdutosPalette.borderSoft),
                ),
                constraints: const BoxConstraints(minWidth: 176),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: ProdutosPalette.text,
                        ),
                        SizedBox(width: 12),
                        Text('Editar produto'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: ProdutosPalette.primaryPressed,
                        ),
                        SizedBox(width: 12),
                        Text('Excluir produto'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: ProdutosPalette.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
