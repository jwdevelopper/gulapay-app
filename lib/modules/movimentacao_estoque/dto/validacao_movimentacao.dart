import 'package:my_app_teste/core/widgets/app_data.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/unidade_medida.dart';

/// Campos do formulário que podem receber marcação visual de erro.
enum CampoMovimentacao {
  tipo,
  insumo,
  quantidade,
  unidade,
  validade,
  custoUnitario,
  lote,
}

/// Retrato dos dados do formulário em um dado momento.
///
/// É um objeto de valor puro (sem Flutter): a página monta a partir dos
/// seus controllers e seleções, e o [ValidadorMovimentacao] decide se a
/// etapa pode avançar. Isso mantém a regra fora da árvore de widgets e
/// permite testar a validação sem renderizar nada.
class DadosMovimentacao {
  final String? tipo;
  final Insumo? insumo;
  final UnidadeMedida? unidade;
  final Lote? lote;
  final String quantidade;
  final DateTime? validade;
  final String custoUnitario;
  final String codigoLote;
  final String justificativa;

  /// Há lotes carregados para o insumo escolhido? Uma saída só pode ser
  /// lançada contra um lote existente.
  final bool possuiLotes;

  const DadosMovimentacao({
    this.tipo,
    this.insumo,
    this.unidade,
    this.lote,
    this.quantidade = '',
    this.validade,
    this.custoUnitario = '',
    this.codigoLote = '',
    this.justificativa = '',
    this.possuiLotes = false,
  });

  static const Set<String> _tiposEntrada = {'ENTRADA_COMPRA', 'ENTRADA_TROCA'};

  /// Entradas criam lote novo (pedem validade e custo); as demais baixam
  /// de um lote existente.
  bool get ehEntrada => _tiposEntrada.contains(tipo);

  double get quantidadeNumerica => _paraDouble(quantidade);
  double get custoNumerico => _paraDouble(custoUnitario);

  /// Aceita vírgula como separador decimal (padrão pt-BR).
  static double _paraDouble(String valor) =>
      double.tryParse(valor.trim().replaceAll(',', '.')) ?? 0;

  /// Payload do `POST /movimentacoes-estoque`. Campos opcionais só entram
  /// quando preenchidos; a validade vai no formato ISO esperado pela API.
  Map<String, dynamic> paraPayload() {
    final payload = <String, dynamic>{
      'tipo': tipo,
      'insumoId': insumo?.id,
      'unidadeId': unidade?.id,
      'quantidade': quantidadeNumerica,
    };
    if (lote != null) payload['loteId'] = lote!.id;
    if (custoNumerico > 0) payload['custoUnitario'] = custoNumerico;
    if (validade != null) payload['validade'] = formatarDataIso(validade!);
    if (codigoLote.trim().isNotEmpty) payload['codigoLote'] = codigoLote.trim();
    if (justificativa.trim().isNotEmpty) {
      payload['justificativa'] = justificativa.trim();
    }
    return payload;
  }
}

/// Resultado de uma validação de etapa.
class ResultadoValidacao {
  final Set<CampoMovimentacao> camposComErro;
  final String? mensagem;

  const ResultadoValidacao({this.camposComErro = const {}, this.mensagem});

  const ResultadoValidacao.ok() : camposComErro = const {}, mensagem = null;

  bool get valido => camposComErro.isEmpty && mensagem == null;

  bool erroEm(CampoMovimentacao campo) => camposComErro.contains(campo);

  /// Devolve uma cópia sem a marcação de [campo] — usado quando o usuário
  /// corrige o campo e o erro deve sumir na hora.
  ResultadoValidacao sem(CampoMovimentacao campo) {
    if (!erroEm(campo)) return this;
    final restantes = Set<CampoMovimentacao>.from(camposComErro)..remove(campo);
    if (restantes.isEmpty) return const ResultadoValidacao.ok();
    return ResultadoValidacao(camposComErro: restantes);
  }
}

/// Regras de preenchimento obrigatório por etapa do formulário.
///
/// Cada campo marcado com `*` na interface tem aqui a checagem
/// correspondente — o asterisco do rótulo e esta classe são as duas
/// metades da mesma regra.
class ValidadorMovimentacao {
  const ValidadorMovimentacao._();

  static ResultadoValidacao validarEtapa(int etapa, DadosMovimentacao dados) {
    switch (etapa) {
      case 0:
        return _validarTipo(dados);
      case 1:
        return _validarInsumoEQuantidade(dados);
      default:
        return _validarLoteEDetalhes(dados);
    }
  }

  static ResultadoValidacao _validarTipo(DadosMovimentacao dados) {
    if (dados.tipo == null) {
      return const ResultadoValidacao(
        camposComErro: {CampoMovimentacao.tipo},
        mensagem: 'Selecione o tipo de movimentação.',
      );
    }
    return const ResultadoValidacao.ok();
  }

  static ResultadoValidacao _validarInsumoEQuantidade(DadosMovimentacao dados) {
    final erros = <CampoMovimentacao>{};
    if (dados.insumo == null) erros.add(CampoMovimentacao.insumo);
    if (dados.quantidadeNumerica <= 0) erros.add(CampoMovimentacao.quantidade);
    if (dados.unidade == null) erros.add(CampoMovimentacao.unidade);
    return _resultado(erros);
  }

  static ResultadoValidacao _validarLoteEDetalhes(DadosMovimentacao dados) {
    final erros = <CampoMovimentacao>{};

    if (dados.ehEntrada) {
      // Entrada cria lote novo: validade e custo são obrigatórios.
      if (dados.validade == null) erros.add(CampoMovimentacao.validade);
      if (dados.custoNumerico <= 0) erros.add(CampoMovimentacao.custoUnitario);
      return _resultado(erros);
    }

    // Saída/ajuste baixa de um lote existente.
    if (!dados.possuiLotes) {
      return const ResultadoValidacao(
        camposComErro: {CampoMovimentacao.lote},
        mensagem:
            'Nenhum lote disponível para este insumo. '
            'Registre uma entrada antes de lançar a saída.',
      );
    }
    if (dados.lote == null) erros.add(CampoMovimentacao.lote);
    return _resultado(erros);
  }

  static ResultadoValidacao _resultado(Set<CampoMovimentacao> erros) {
    if (erros.isEmpty) return const ResultadoValidacao.ok();
    return ResultadoValidacao(
      camposComErro: erros,
      mensagem: '${erros.length} campo(s) obrigatório(s).',
    );
  }
}
