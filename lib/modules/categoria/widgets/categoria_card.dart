import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_card_conteudo.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_gesto_status.dart';
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

    return CategoriaGestoStatus(
      chave: categoria.id ?? categoria.nome,
      ativa: ativa,
      aoConfirmar: aoAlternarStatus,
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
