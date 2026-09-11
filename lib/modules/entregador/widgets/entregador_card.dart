import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_cartao_deslizavel.dart';
import 'package:my_app_teste/core/widgets/app_menu_acoes.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';

class EntregadorCard extends StatelessWidget {
  final EntregadorResponse entregador;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<bool> Function() onConfirmDelete;

  const EntregadorCard({
    super.key,
    required this.entregador,
    required this.onTap,
    required this.onEdit,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTema.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTema.borda),
            boxShadow: const [
              BoxShadow(
                color: AppTema.sombra,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTema.primariaSuave.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: AppTema.texto,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entregador.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppTema.textoSecundario,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            TelefoneFormatter.formatar(entregador.telefone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTema.textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTema.sucesso.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ATIVO',
                        style: TextStyle(
                          color: AppTema.sucesso,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppMenuAcoes(
                onEditar: onEdit,
                onExcluir: () => onConfirmDelete(),
                rotuloEditar: 'Editar entregador',
                rotuloExcluir: 'Excluir entregador',
                tooltip: 'Ações do entregador',
              ),
            ],
          ),
        ),
      ),
    );

    return AppCartaoDeslizavel(
      chave: 'entregador_${entregador.id ?? entregador.telefone}',
      aoConfirmarExclusao: onConfirmDelete,
      child: card,
    );
  }
}
