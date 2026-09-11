import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

/// Regras de preenchimento do formulário de categoria.
///
/// Sem Flutter, para poder ser testado sem renderizar nada. Os limites de
/// tamanho espelham as colunas do backend.
class ValidadorCategoria {
  const ValidadorCategoria._();

  static const nomeTamanhoMinimo = 2;
  static const nomeTamanhoMaximo = 100;
  static const descricaoTamanhoMaximo = 255;

  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome da categoria.';
    if (nome.length < nomeTamanhoMinimo) {
      return 'O nome deve ter no mínimo $nomeTamanhoMinimo caracteres.';
    }
    return null;
  }

  /// Monta a categoria a enviar, preservando id e situação do registro
  /// original ([base]) — o formulário não mexe em `ativo`, isso é da
  /// listagem.
  ///
  /// Descrição em branco vira `null`: o backend distingue "sem descrição"
  /// de "descrição vazia".
  static Categoria montar({
    required String nome,
    required String descricao,
    Categoria? base,
  }) => Categoria(
    id: base?.id,
    nome: nome.trim(),
    descricao: descricao.trim().isEmpty ? null : descricao.trim(),
    ativo: base?.ativo,
  );
}
