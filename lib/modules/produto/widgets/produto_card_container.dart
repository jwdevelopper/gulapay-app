import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_cartao_deslizavel.dart';

import 'produtos_palette.dart';

/// Envolve o conteúdo visual do card de produto com a interação de swipe-to-delete
/// no padrão da tela de Usuário: [Dismissible] com background vermelho + ícone de
/// lixeira, confirmação delegada ao parent (via [onConfirmDelete]).
///
/// O visual interno do card (Material, borda, sombra, padding e InkWell) é mantido
/// idêntico à versão anterior — só o comportamento de swipe mudou.
class ProdutoCardContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Chave estável usada pelo [Dismissible] para identificar o card na lista.
  final String dismissibleKey;

  /// Callback chamado quando o usuário desliza o card para a esquerda. O parent
  /// deve mostrar a confirmação e executar a exclusão; devolve [true] se a
  /// remoção pode prosseguir (o [Dismissible] anima a saída do card), ou
  /// [false] caso contrário (cancelamento ou erro).
  final Future<bool> Function()? onConfirmDelete;

  const ProdutoCardContainer({
    super.key,
    required this.child,
    required this.onTap,
    required this.dismissibleKey,
    this.onLongPress,
    this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: ProdutosPalette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ProdutosPalette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ProdutosPalette.border),
            boxShadow: const [
              BoxShadow(
                color: ProdutosPalette.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onConfirmDelete == null) {
      return card;
    }

    return AppCartaoDeslizavel(
      chave: 'produto_$dismissibleKey',
      aoConfirmarExclusao: onConfirmDelete!,
      child: card,
    );
  }
}
