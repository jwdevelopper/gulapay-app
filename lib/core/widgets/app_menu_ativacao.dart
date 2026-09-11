import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Menu de 3 pontos dos cadastros com soft delete.
///
/// Irmão do [AppMenuAcoes]: aquele oferece **Editar / Excluir**, para
/// registros que somem de verdade; este oferece **Editar** e, conforme o
/// estado, **Inativar** ou **Ativar** — o par certo para os cadastros que
/// usam `ativo` em vez de excluir (RNF08), porque a operação é reversível e
/// o rótulo precisa dizer qual das duas vai acontecer.
///
/// Fonte única desse menu, que existia copiado em Cliente e em Unidade de
/// Medida (e reaparecia em cada cadastro novo).
///
/// ```dart
/// AppMenuAtivacao(
///   ativo: cliente.ativo ?? true,
///   aoEditar: () => _abrirFormulario(cliente: cliente),
///   aoInativar: () => _inativar(cliente),
///   aoReativar: () => _reativar(cliente),
///   rotuloInativar: 'Inativar cliente',
/// )
/// ```
class AppMenuAtivacao extends StatelessWidget {
  /// Estado atual do registro. Decide qual das duas ações aparece.
  final bool ativo;

  /// Abre a edição.
  final VoidCallback aoEditar;

  /// Pede a inativação. A confirmação é responsabilidade de quem chama —
  /// este widget só dispara a intenção.
  final VoidCallback aoInativar;

  /// Pede a reativação.
  final VoidCallback aoReativar;

  /// Texto do item de inativar. Personalize quando "Inativar" sozinho for
  /// ambíguo na tela.
  final String rotuloInativar;

  /// Texto do item de ativar.
  final String rotuloAtivar;

  /// Ícone do item de inativar.
  final IconData iconeInativar;

  /// Ícone do item de ativar.
  final IconData iconeAtivar;

  const AppMenuAtivacao({
    super.key,
    required this.ativo,
    required this.aoEditar,
    required this.aoInativar,
    required this.aoReativar,
    this.rotuloInativar = 'Inativar',
    this.rotuloAtivar = 'Ativar',
    this.iconeInativar = Icons.block,
    this.iconeAtivar = Icons.check_circle_outline,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_AcaoAtivacao>(
    tooltip: 'Ações',
    icon: const FaIcon(
      FontAwesomeIcons.ellipsisVertical,
      size: 16,
      color: AppTema.primariaEscura,
    ),
    color: AppTema.superficie,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    onSelected: (acao) => switch (acao) {
      _AcaoAtivacao.editar => aoEditar(),
      _AcaoAtivacao.inativar => aoInativar(),
      _AcaoAtivacao.ativar => aoReativar(),
    },
    itemBuilder: (_) => [
      const PopupMenuItem(
        value: _AcaoAtivacao.editar,
        child: _Item(
          icone: FaIcon(
            FontAwesomeIcons.penToSquare,
            size: 14,
            color: AppTema.primariaEscura,
          ),
          rotulo: 'Editar',
          cor: AppTema.texto,
        ),
      ),
      if (ativo)
        PopupMenuItem(
          value: _AcaoAtivacao.inativar,
          child: _Item(
            icone: Icon(iconeInativar, size: 14, color: AppTema.erro),
            rotulo: rotuloInativar,
            cor: AppTema.erro,
          ),
        )
      else
        PopupMenuItem(
          value: _AcaoAtivacao.ativar,
          child: _Item(
            icone: Icon(iconeAtivar, size: 14, color: AppTema.sucesso),
            rotulo: rotuloAtivar,
            cor: AppTema.sucesso,
          ),
        ),
    ],
  );
}

enum _AcaoAtivacao { editar, inativar, ativar }

class _Item extends StatelessWidget {
  final Widget icone;
  final String rotulo;
  final Color cor;

  const _Item({required this.icone, required this.rotulo, required this.cor});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      icone,
      const SizedBox(width: 10),
      Text(rotulo, style: TextStyle(color: cor)),
    ],
  );
}
