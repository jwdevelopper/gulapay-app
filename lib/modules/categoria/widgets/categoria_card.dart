import 'package:flutter/material.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel.dart';
import 'package:my_app_teste/core/utils/cartao_deslizavel/app_cartao_deslizavel_acao.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_card_conteudo.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_menu_acoes.dart';

class CategoriaCard extends StatelessWidget {
  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.aoAbrir,
    required this.aoAlternarStatus,
    required this.aoStatusAlterado,
  });

  final Categoria categoria;
  final VoidCallback aoAbrir;
  final Future<bool> Function() aoAlternarStatus;
  final VoidCallback aoStatusAlterado;

  @override
  Widget build(BuildContext context) {
    final ativa = categoria.ativo ?? true;

    return AppCartaoDeslizavel(
      chave: 'categoria_${categoria.id ?? categoria.nome}',
      raioBorda: 12,
      acao: AppCartaoDeslizavelAcao(
        rotulo: ativa ? 'Inativar' : 'Reativar',
        icone: ativa ? Icons.block : Icons.restart_alt,
        cor: ativa ? const Color(0xFFE53935) : const Color(0xFF2E8B57),
        corProfunda: ativa ? const Color(0xFFB71C1C) : const Color(0xFF17663C),
      ),
      aoConfirmarAcao: aoAlternarStatus,
      aoConcluir: aoStatusAlterado,
      child: CategoriaCardConteudo(
        categoria: categoria,
        aoAbrir: aoAbrir,
        acoes: CategoriaMenuAcoes(
          ativa: ativa,
          aoSelecionar: (acao) => _executarAcao(acao),
        ),
      ),
    );
  }

  Future<void> _executarAcao(CategoriaAcaoMenu acao) async {
    if (acao == CategoriaAcaoMenu.editar) {
      aoAbrir();
      return;
    }

    if (await aoAlternarStatus()) {
      aoStatusAlterado();
    }
  }
}
