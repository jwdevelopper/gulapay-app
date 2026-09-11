import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_create_request.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_update.dart';

/// Retrato dos dados do formulário de insumo.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e o [ValidadorInsumo] decide se dá para salvar.
class DadosInsumo {
  /// Nome do insumo, como digitado.
  final String nome;

  /// Unidade em que o insumo é estocado. Define a unidade do saldo e a
  /// base de conversão de toda movimentação (seção 4.5.1).
  final int? unidadePadraoId;

  /// Estoque mínimo, como digitado (pt-BR). Alimenta o alerta do RF43.
  final String estoqueMinimo;

  /// Soft delete (RNF08).
  final bool ativo;

  const DadosInsumo({
    this.nome = '',
    this.unidadePadraoId,
    this.estoqueMinimo = '',
    this.ativo = true,
  });

  DadosInsumo copiarCom({
    String? nome,
    int? unidadePadraoId,
    String? estoqueMinimo,
    bool? ativo,
  }) => DadosInsumo(
    nome: nome ?? this.nome,
    unidadePadraoId: unidadePadraoId ?? this.unidadePadraoId,
    estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
    ativo: ativo ?? this.ativo,
  );

  /// Estoque mínimo já como número.
  double? get estoqueMinimoNumero => parseNumeroBr(estoqueMinimo);

  String get nomeLimpo => nome.trim();

  /// Payload de `POST /insumos`. Não envia `ativo` — insumo nasce ativo.
  InsumoCreateRequest paraCriacao() => InsumoCreateRequest(
    nome: nomeLimpo,
    unidadePadraoId: unidadePadraoId,
    estoqueMinimo: estoqueMinimoNumero,
  );

  /// Payload de `PUT /insumos/{id}`.
  InsumoUpdate paraEdicao() => InsumoUpdate(
    nome: nomeLimpo,
    unidadePadraoId: unidadePadraoId,
    estoqueMinimo: estoqueMinimoNumero,
    ativo: ativo,
  );
}

/// Regras de preenchimento do formulário de insumo.
///
/// Os limites de tamanho do nome espelham o `@Size` da entidade no
/// backend, para o erro aparecer antes do request.
class ValidadorInsumo {
  const ValidadorInsumo._();

  static const nomeTamanhoMinimo = 2;
  static const nomeTamanhoMaximo = 120;

  /// Mensagem de erro do nome, ou `null`.
  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome do insumo.';
    if (nome.length < nomeTamanhoMinimo) {
      return 'O nome deve ter no mínimo $nomeTamanhoMinimo caracteres.';
    }
    if (nome.length > nomeTamanhoMaximo) {
      return 'O nome deve ter no máximo $nomeTamanhoMaximo caracteres.';
    }
    return null;
  }

  /// Mensagem de erro do estoque mínimo, ou `null`.
  ///
  /// Zero é aceito — significa "não quero alerta para este insumo".
  static String? validarEstoqueMinimo(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o estoque mínimo.';
    final numero = parseNumeroBr(texto);
    if (numero == null) return 'Valor inválido.';
    if (numero < 0) return 'O estoque mínimo não pode ser negativo.';
    return null;
  }

  /// Mensagem de erro da unidade, ou `null`.
  static String? validarUnidade(int? id) =>
      id == null ? 'Selecione uma unidade de medida.' : null;

  /// Primeiro problema encontrado no conjunto, ou `null` quando dá para
  /// salvar.
  static String? validar(DadosInsumo d) =>
      validarNome(d.nome) ??
      validarUnidade(d.unidadePadraoId) ??
      validarEstoqueMinimo(d.estoqueMinimo);
}
