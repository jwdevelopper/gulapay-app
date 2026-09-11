import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Pílula de filtro selecionável das listagens.
///
/// Fonte única do chip arredondado que aparece acima das listas. Substituiu
/// três implementações independentes com a mesma aparência: os chips de
/// status/canal da página de comandas, o [TipoFilterChips] do estoque e o
/// `ProdutoCategoryChip`.
///
/// Selecionado, o chip é preenchido com [AppTema.primaria] e o texto vira
/// branco; solto, fica em [AppTema.superficieAlt] com borda. A transição
/// entre os dois estados é animada.
///
/// ## Exemplo
///
/// ```dart
/// AppChipFiltro(
///   rotulo: 'Entradas',
///   icone: Icons.arrow_downward_rounded,
///   selecionado: filtro.tipo == FiltroEstoque.entradas,
///   aoTocar: () => _aplicar(FiltroEstoque.entradas),
/// )
/// ```
///
/// Para uma fileira rolável de chips, veja [AppFileiraChips].
class AppChipFiltro extends StatelessWidget {
  /// Texto do chip.
  final String rotulo;

  /// Ícone à esquerda do texto. Sem ele o chip mostra só o rótulo.
  final IconData? icone;

  /// Estado atual. Controla preenchimento, borda e cor do texto.
  final bool selecionado;

  /// Ação ao tocar. Quem chama decide se o toque seleciona ou alterna.
  final VoidCallback aoTocar;

  /// Sombra suave quando selecionado. Use em chips que são a navegação
  /// principal da tela (categorias de produto), não em filtros discretos.
  final bool comSombra;

  const AppChipFiltro({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
    this.icone,
    this.comSombra = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: aoTocar,
    borderRadius: BorderRadius.circular(999),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selecionado ? AppTema.primaria : AppTema.superficieAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selecionado ? AppTema.primaria : AppTema.borda,
        ),
        boxShadow: comSombra && selecionado
            ? const [
                BoxShadow(
                  color: AppTema.sombraCampo,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 14,
              color: selecionado ? Colors.white : AppTema.primaria,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            rotulo,
            style: TextStyle(
              color: selecionado ? Colors.white : AppTema.texto,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Fileira horizontal rolável de [AppChipFiltro].
///
/// Cuida do que toda barra de filtros repetia: rolagem horizontal, recuo
/// lateral e espaçamento entre os chips. Passe os chips já construídos.
///
/// ```dart
/// AppFileiraChips(
///   chips: [
///     for (final s in status)
///       AppChipFiltro(rotulo: s.rotulo, selecionado: ..., aoTocar: ...),
///   ],
/// )
/// ```
class AppFileiraChips extends StatelessWidget {
  /// Os chips, na ordem de exibição.
  final List<Widget> chips;

  /// Recuo lateral da fileira.
  final double recuoLateral;

  const AppFileiraChips({
    super.key,
    required this.chips,
    this.recuoLateral = 16,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: recuoLateral),
    child: Row(
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          chips[i],
        ],
      ],
    ),
  );
}
