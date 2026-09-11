import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

/// Estado dos filtros da listagem de categorias.
///
/// Objeto de valor puro (sem Flutter). O recorte é em memória: a página
/// carrega a lista inteira (`apenasAtivos: false`) e peneira aqui, para o
/// filtro "Inativas" ter o que mostrar.
class FiltroCategorias {
  /// Termo digitado. Confere nome e descrição.
  final String texto;

  /// Recorte por soft delete (RNF08).
  final SituacaoCadastro situacao;

  const FiltroCategorias({
    this.texto = '',
    this.situacao = SituacaoCadastro.todos,
  });

  /// Nenhum recorte ativo.
  bool get vazio => texto.trim().isEmpty && situacao == SituacaoCadastro.todos;

  FiltroCategorias copiarCom({String? texto, SituacaoCadastro? situacao}) =>
      FiltroCategorias(
        texto: texto ?? this.texto,
        situacao: situacao ?? this.situacao,
      );

  List<Categoria> aplicar(List<Categoria> categorias) => categorias
      .where((c) => _combinaTexto(c) && situacao.aceita(c.ativo))
      .toList();

  bool _combinaTexto(Categoria c) {
    if (texto.trim().isEmpty) return true;
    return contemTextoBr(c.nome, texto) || contemTextoBr(c.descricao, texto);
  }
}
