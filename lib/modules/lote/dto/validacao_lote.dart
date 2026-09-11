import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_create_request.dart';
import 'package:my_app_teste/modules/lote/dto/lote_update.dart';

/// Retrato dos dados do formulário de lote.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e seleções, e o [ValidadorLote] decide se dá para salvar.
///
/// O formulário atende dois casos com regras bem diferentes:
///
///  * **criação** — exige insumo, validade, quantidade, unidade e custo;
///  * **edição** — o `PUT /lotes/{id}` só aceita código, validade e
///    `ativo`, então quantidade, unidade e custo nem são pedidos. O saldo
///    restante nunca é editado direto: ele só muda por movimentação.
///
/// [ehEdicao] é o que separa os dois — daí ele ser um campo, e não um
/// parâmetro solto de cada método.
class DadosLote {
  /// Insumo dono do lote. Só usado na criação; em edição o vínculo é fixo.
  final InsumoResponse? insumo;

  /// Código de referência do lote (nota fiscal, etiqueta). Opcional.
  final String codigo;

  /// Validade do lote. Obrigatória nos dois modos — é o que ordena o FEFO.
  final DateTime? validade;

  /// Quantidade inicial, como o usuário digitou (pt-BR).
  final String quantidade;

  /// Custo unitário, como o usuário digitou (pt-BR).
  final String custo;

  /// Unidade em que a quantidade foi informada.
  final int? unidadeId;

  /// Soft delete (RNF08). Lote inativo sai do FEFO.
  final bool ativo;

  /// Verdadeiro quando a tela edita um lote existente.
  final bool ehEdicao;

  const DadosLote({
    this.insumo,
    this.codigo = '',
    this.validade,
    this.quantidade = '',
    this.custo = '',
    this.unidadeId,
    this.ativo = true,
    this.ehEdicao = false,
  });

  DadosLote copiarCom({
    InsumoResponse? insumo,
    String? codigo,
    DateTime? validade,
    String? quantidade,
    String? custo,
    int? unidadeId,
    bool? ativo,
  }) => DadosLote(
    insumo: insumo ?? this.insumo,
    codigo: codigo ?? this.codigo,
    validade: validade ?? this.validade,
    quantidade: quantidade ?? this.quantidade,
    custo: custo ?? this.custo,
    unidadeId: unidadeId ?? this.unidadeId,
    ativo: ativo ?? this.ativo,
    ehEdicao: ehEdicao,
  );

  /// Quantidade digitada, já como número. `null` quando em branco ou
  /// inválida.
  double? get quantidadeNumero => parseNumeroBr(quantidade);

  /// Custo digitado, já como número.
  double? get custoNumero => parseNumeroBr(custo);

  /// Código sem espaços, ou `null` quando em branco — o backend distingue
  /// "sem código" de "código vazio".
  String? get codigoLimpo => codigo.trim().isEmpty ? null : codigo.trim();

  /// Payload de `POST /lotes`.
  LoteCreateRequest paraCriacao() => LoteCreateRequest(
    insumoId: insumo?.id,
    codigo: codigoLimpo,
    validade: _validadeIso,
    quantidadeInicial: quantidadeNumero,
    unidadeId: unidadeId,
    custoUnitario: custoNumero,
  );

  /// Payload de `PUT /lotes/{id}` — só os três campos que ele aceita.
  LoteUpdate paraEdicao() =>
      LoteUpdate(codigo: codigoLimpo, validade: _validadeIso, ativo: ativo);

  String? get _validadeIso {
    final data = validade;
    if (data == null) return null;
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '${data.year}-$mes-$dia';
  }
}

/// Regras de preenchimento do formulário de lote.
///
/// Espelha o que o `LoteService` do backend valida, para o usuário não
/// descobrir o erro só depois do request.
class ValidadorLote {
  const ValidadorLote._();

  /// Devolve a mensagem do primeiro problema encontrado, ou `null` quando
  /// os dados podem ser enviados.
  static String? validar(DadosLote d) {
    if (!d.ehEdicao && d.insumo?.id == null) return 'Selecione o insumo.';
    if (d.validade == null) return 'Informe a validade.';
    if (d.ehEdicao) return null;

    final quantidade = d.quantidadeNumero;
    if (quantidade == null || quantidade <= 0) {
      return 'A quantidade inicial deve ser maior que zero.';
    }
    if (d.unidadeId == null) return 'Selecione a unidade.';

    final custo = d.custoNumero;
    if (custo == null || custo < 0) {
      return 'O custo unitário deve ser maior ou igual a zero.';
    }
    return null;
  }
}
