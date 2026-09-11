import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_menu_ativacao.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';

/// Linha da listagem de clientes.
///
/// Segue o padrão de cards do app — tocar abre o detalhe, arrastar inativa,
/// menu de 3 pontos como alternativa acessível. Cliente não é excluído: o
/// histórico de pedidos depende dele, então o registro é inativado (RNF08)
/// e pode voltar.
class CartaoCliente extends StatelessWidget {
  final ClienteResponse cliente;

  /// Abre o detalhe do cliente.
  final VoidCallback aoAbrir;

  /// Abre o formulário de edição.
  final VoidCallback aoEditar;

  /// Pede a inativação (a confirmação é de quem chama).
  final VoidCallback aoInativar;

  /// Pede a reativação.
  final VoidCallback aoReativar;

  /// Confirmação do arrastar. Devolve `true` para o card sumir da lista.
  final Future<bool> Function() aoConfirmarArrastar;

  const CartaoCliente({
    super.key,
    required this.cliente,
    required this.aoAbrir,
    required this.aoEditar,
    required this.aoInativar,
    required this.aoReativar,
    required this.aoConfirmarArrastar,
  });

  bool get _ativo => cliente.ativo ?? true;

  /// Inicial do nome para o avatar.
  String get _inicial {
    final nome = cliente.nome?.trim() ?? '';
    return nome.isEmpty ? '?' : nome.characters.first.toUpperCase();
  }

  /// Telefone é o identificador do cliente em todo pedido (seção 3.6), por
  /// isso ele vem na linha principal e a ausência é dita em voz alta.
  String get _telefone => (cliente.telefone ?? '').isEmpty
      ? 'Telefone não informado'
      : TelefoneFormatter.formatar(cliente.telefone);

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey('cliente_${cliente.id ?? cliente.telefone ?? cliente.nome}'),
    direction: _ativo ? DismissDirection.endToStart : DismissDirection.none,
    background: _fundoArrastar(),
    confirmDismiss: (_) => aoConfirmarArrastar(),
    child: Material(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoAbrir,
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
              AppMenuAtivacao(
                ativo: _ativo,
                aoEditar: aoEditar,
                aoInativar: aoInativar,
                aoReativar: aoReativar,
                iconeInativar: Icons.person_off_outlined,
                iconeAtivar: Icons.person_outline_rounded,
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
          'Inativar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        SizedBox(width: 8),
        FaIcon(FontAwesomeIcons.userSlash, color: Colors.white, size: 18),
      ],
    ),
  );

  Widget _descricao() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        cliente.nome ?? 'Sem nome',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: _ativo ? AppTema.texto : AppTema.textoSecundario,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        _telefone,
        style: const TextStyle(color: AppTema.textoSecundario, fontSize: 13),
      ),
      if ((cliente.email ?? '').isNotEmpty || !_ativo) ...[
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if ((cliente.email ?? '').isNotEmpty) AppTag(cliente.email!),
            if (!_ativo)
              const AppTag(
                'Inativo',
                fundo: AppTema.erroFundo,
                cor: AppTema.erro,
              ),
          ],
        ),
      ],
    ],
  );
}
