import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_menu_acoes.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/usuario/dto/rotulos_usuario.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';

/// Linha da listagem de usuários.
///
/// Segue o padrão de cards do app: tocar edita, arrastar exclui, menu de 3
/// pontos como alternativa acessível.
///
/// Aqui a exclusão é real (não soft delete) — daí o [AppMenuAcoes], com
/// "Excluir", em vez do [AppMenuAtivacao] dos cadastros que só inativam.
class CartaoUsuario extends StatelessWidget {
  final UsuarioResposta usuario;

  /// Abre o formulário de edição.
  final VoidCallback aoEditar;

  /// Exclusão pelo menu (confirma e apaga).
  final Future<void> Function() aoExcluir;

  /// Exclusão pelo arrastar. Devolve `true` para o card sumir da lista.
  final Future<bool> Function() aoConfirmarArrastar;

  const CartaoUsuario({
    super.key,
    required this.usuario,
    required this.aoEditar,
    required this.aoExcluir,
    required this.aoConfirmarArrastar,
  });

  String get _inicial {
    final nome = usuario.nome?.trim() ?? '';
    return nome.isEmpty ? '?' : nome.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey('usuario_${usuario.id ?? usuario.login}'),
    direction: DismissDirection.endToStart,
    background: _fundoArrastar(),
    confirmDismiss: (_) => aoConfirmarArrastar(),
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
              Expanded(child: _descricao()),
              AppMenuAcoes(
                onEditar: aoEditar,
                onExcluir: aoExcluir,
                rotuloEditar: 'Editar usuário',
                rotuloExcluir: 'Excluir usuário',
                tooltip: 'Ações do usuário',
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
      color: AppTema.erro,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Excluir',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        SizedBox(width: 8),
        FaIcon(FontAwesomeIcons.trashCan, color: Colors.white, size: 20),
      ],
    ),
  );

  Widget _descricao() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        usuario.nome ?? '-',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTema.texto,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        '@${usuario.login ?? '-'}',
        style: const TextStyle(color: AppTema.textoSecundario, fontSize: 13),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          AppTag(RotulosUsuario.perfil(usuario.perfil)),
          if (usuario.ativo == false)
            const AppTag(
              'Inativo',
              fundo: AppTema.erroFundo,
              cor: AppTema.erro,
            ),
        ],
      ),
    ],
  );
}
