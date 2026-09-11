import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_menu_ativacao.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/rotulos_unidade.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

/// Linha da listagem de unidades de medida.
///
/// Segue o padrão de cards do app — tocar edita, arrastar inativa, menu de
/// 3 pontos como alternativa acessível —, com uma diferença: unidade de
/// medida não é excluída, é **inativada** (RNF08), e uma inativa pode ser
/// reativada. Por isso o menu troca "Inativar" por "Ativar" conforme o
/// estado, e o arrastar só existe para as ativas.
class CartaoUnidade extends StatelessWidget {
  final UnidadeMedidaResponse unidade;

  /// Abre o formulário de edição.
  final VoidCallback aoEditar;

  /// Pede a inativação (a confirmação é de quem chama).
  final VoidCallback aoInativar;

  /// Pede a reativação.
  final VoidCallback aoReativar;

  /// Confirmação do arrastar. Devolve `true` para o card sumir da lista.
  final Future<bool> Function() aoConfirmarArrastar;

  const CartaoUnidade({
    super.key,
    required this.unidade,
    required this.aoEditar,
    required this.aoInativar,
    required this.aoReativar,
    required this.aoConfirmarArrastar,
  });

  bool get _ativa => unidade.ativo ?? true;

  /// O símbolo encolhe conforme cresce, para caber no quadrado sem cortar
  /// ("kg" e "cx6" ocupam larguras bem diferentes).
  double get _tamanhoSimbolo {
    final tamanho = unidade.simbolo?.length ?? 1;
    if (tamanho <= 2) return 16;
    if (tamanho <= 4) return 13;
    return 10;
  }

  @override
  Widget build(BuildContext context) {
    final corTipo = RotulosUnidade.corTipo(unidade.tipoMedida);
    return Dismissible(
      key: ValueKey('unidade_${unidade.id ?? unidade.simbolo}'),
      direction: _ativa ? DismissDirection.endToStart : DismissDirection.none,
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
                _selo(corTipo),
                const SizedBox(width: 12),
                Expanded(child: _descricao(corTipo)),
                _menu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        Icon(Icons.block, color: Colors.white, size: 18),
      ],
    ),
  );

  /// Quadrado com o símbolo — é por ele que a unidade é reconhecida.
  Widget _selo(Color corTipo) => Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: corTipo.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: corTipo.withValues(alpha: 0.30), width: 1.5),
    ),
    child: Text(
      unidade.simbolo ?? '?',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: corTipo,
        fontSize: _tamanhoSimbolo,
      ),
    ),
  );

  Widget _descricao(Color corTipo) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        unidade.nome ?? '—',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: _ativa ? AppTema.texto : AppTema.textoSecundario,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        RotulosUnidade.descricao(unidade),
        style: const TextStyle(color: AppTema.textoSecundario, fontSize: 12),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          AppTag(
            RotulosUnidade.tipo(unidade.tipoMedida),
            fundo: corTipo.withValues(alpha: 0.10),
            cor: corTipo,
          ),
          if (RotulosUnidade.ehBase(unidade))
            const AppTag(
              'BASE',
              fundo: AppTema.avisoFundo,
              cor: AppTema.primariaEscura,
            ),
          if (!_ativa)
            const AppTag(
              'Inativa',
              fundo: AppTema.erroFundo,
              cor: AppTema.erro,
            ),
        ],
      ),
    ],
  );

  Widget _menu() => AppMenuAtivacao(
    ativo: _ativa,
    aoEditar: aoEditar,
    aoInativar: aoInativar,
    aoReativar: aoReativar,
  );
}
