/// Campos do formulário de produto que podem receber marcação de erro.
enum CampoProduto { nome, preco, categoria, tipo, setor }

/// Retrato dos dados do formulário de produto em um dado momento.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e seleções, e o [ValidadorProduto] decide se a etapa pode
/// avançar. Mantém a regra fora da árvore de widgets e permite testar a
/// validação sem renderizar nada.
class DadosProduto {
  final String nome;
  final String descricao;
  final String preco;
  final int? categoriaId;
  final String? tipo;
  final String? setor;
  final bool ativo;

  const DadosProduto({
    this.nome = '',
    this.descricao = '',
    this.preco = '',
    this.categoriaId,
    this.tipo,
    this.setor,
    this.ativo = true,
  });

  /// Preço em número. Aceita vírgula como separador decimal e ignora o
  /// ponto de milhar, que é como o usuário digita em pt-BR.
  double get precoNumerico {
    final limpo = preco.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(limpo) ?? 0;
  }

  /// Payload de `POST /produtos` e `PUT /produtos/{id}`.
  ///
  /// [paraEdicao] inclui o campo `ativo` — a criação não o envia, porque o
  /// backend já nasce com `true`.
  Map<String, dynamic> paraPayload({bool paraEdicao = false}) {
    final payload = <String, dynamic>{
      'nome': nome.trim(),
      'descricao': descricao.trim().isEmpty ? null : descricao.trim(),
      'preco': precoNumerico,
      'tipoProduto': tipo,
      'setorProducao': setor,
      'categoriaId': categoriaId,
    };
    if (paraEdicao) payload['ativo'] = ativo;
    return payload;
  }
}

/// Resultado de uma validação de etapa.
class ResultadoValidacaoProduto {
  final Set<CampoProduto> camposComErro;
  final String? mensagem;

  const ResultadoValidacaoProduto({
    this.camposComErro = const {},
    this.mensagem,
  });

  const ResultadoValidacaoProduto.ok()
    : camposComErro = const {},
      mensagem = null;

  bool get valido => camposComErro.isEmpty && mensagem == null;

  bool erroEm(CampoProduto campo) => camposComErro.contains(campo);

  /// Cópia sem a marcação de [campo] — usado quando o usuário corrige o
  /// campo e o erro deve sumir na hora.
  ResultadoValidacaoProduto sem(CampoProduto campo) {
    if (!erroEm(campo)) return this;
    final restantes = Set<CampoProduto>.from(camposComErro)..remove(campo);
    if (restantes.isEmpty) return const ResultadoValidacaoProduto.ok();
    return ResultadoValidacaoProduto(camposComErro: restantes);
  }
}

/// Regras de preenchimento obrigatório por etapa do formulário de produto.
///
/// Cada campo marcado com `*` na interface tem aqui a checagem
/// correspondente:
///
///  * etapa 0 (identidade) — nome;
///  * etapa 1 (preço) — preço maior que zero e categoria;
///  * etapa 2 (produção) — tipo de produto e setor.
class ValidadorProduto {
  const ValidadorProduto._();

  static ResultadoValidacaoProduto validarEtapa(int etapa, DadosProduto d) {
    switch (etapa) {
      case 0:
        return _resultado({if (d.nome.trim().isEmpty) CampoProduto.nome});
      case 1:
        return _resultado({
          if (d.precoNumerico <= 0) CampoProduto.preco,
          if (d.categoriaId == null) CampoProduto.categoria,
        });
      default:
        return _resultado({
          if (d.tipo == null) CampoProduto.tipo,
          if (d.setor == null) CampoProduto.setor,
        });
    }
  }

  static ResultadoValidacaoProduto _resultado(Set<CampoProduto> erros) {
    if (erros.isEmpty) return const ResultadoValidacaoProduto.ok();
    return ResultadoValidacaoProduto(
      camposComErro: erros,
      mensagem: mensagemPendencias(erros.length),
    );
  }

  /// Mensagem do banner de erro, no singular ou plural.
  static String mensagemPendencias(int quantidade) => quantidade == 1
      ? '1 campo obrigatório precisa ser preenchido antes de continuar.'
      : '$quantidade campos obrigatórios precisam ser preenchidos '
            'antes de continuar.';
}
