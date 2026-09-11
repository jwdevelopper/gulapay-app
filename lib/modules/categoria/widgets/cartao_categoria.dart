import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_menu_ativacao.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

/// Linha da listagem de categorias.
///
/// Segue o padrão de cards do app — tocar edita, arrastar troca a situação,
/// menu de 3 pontos como alternativa acessível. Categoria não é excluída:
/// produtos já cadastrados apontam para ela, então o registro é inativado
/// (RNF08) e pode voltar.
///
/// Diferente dos outros cards, o arrastar funciona nos dois sentidos de
/// situação: numa categoria inativa ele **reativa**, e o fundo verde diz
/// isso — reativar é a única forma de trazer a categoria de volta sem abrir
/// o formulário.
class CartaoCategoria extends StatelessWidget {
  final Categoria categoria;

  /// Abre o formulário de edição.
  final VoidCallback aoEditar;

  /// Pede a inativação (a confirmação é de quem chama).
  final VoidCallback aoInativar;

  /// Pede a reativação.
  final VoidCallback aoReativar;

  /// Ação do arrastar. Devolve sempre `false` para o card permanecer na
  /// lista — a categoria não sai dela, só troca de situação.
  final Future<bool> Function() aoArrastar;

  const CartaoCategoria({
    super.key,
    required this.categoria,
    required this.aoEditar,
    required this.aoInativar,
    required this.aoReativar,
    required this.aoArrastar,
  });

  bool get _ativa => categoria.ativo ?? true;

  String get _inicial {
    final nome = categoria.nome.trim();
    return nome.isEmpty ? '?' : nome.characters.first.toUpperCase();
  }

  String get _descricao => (categoria.descricao?.trim().isNotEmpty ?? false)
      ? categoria.descricao!
      : 'Sem descrição';

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey('categoria_${categoria.id ?? categoria.nome}'),
    direction: DismissDirection.endToStart,
    background: _fundoArrastar(),
    confirmDismiss: (_) => aoArrastar(),
    child: Material(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoEditar,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTema.borda),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTema.avisoFundo,
                child: Text(
                  _inicial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.primaria,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _texto()),
              AppMenuAtivacao(
                ativo: _ativa,
                aoEditar: aoEditar,
                aoInativar: aoInativar,
                aoReativar: aoReativar,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _fundoArrastar() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: _ativa ? AppTema.erro : AppTema.sucesso,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _ativa ? 'Inativar' : 'Reativar',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        FaIcon(
          _ativa ? FontAwesomeIcons.ban : FontAwesomeIcons.arrowRotateLeft,
          color: Colors.white,
          size: 18,
        ),
      ],
    ),
  );

  Widget _texto() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        categoria.nome,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: _ativa ? AppTema.texto : AppTema.textoSecundario,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        _descricao,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppTema.textoSecundario, fontSize: 13),
      ),
      if (!_ativa) ...[
        const SizedBox(height: 6),
        const AppTag('Inativa', fundo: AppTema.erroFundo, cor: AppTema.erro),
      ],
    ],
  );
}
