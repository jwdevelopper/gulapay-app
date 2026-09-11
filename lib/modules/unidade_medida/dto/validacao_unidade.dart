import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_create_request.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_update_request.dart';

/// Retrato dos dados do formulário de unidade de medida.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e o [ValidadorUnidade] decide se dá para salvar.
///
/// Criar e editar aceitam coisas diferentes: `tipoMedida` e
/// `fatorParaBase` são **imutáveis** depois do cadastro, porque mudá-los
/// reinterpretaria em silêncio todo saldo já gravado naquela unidade
/// (seção 4.5.1). Por isso o `PUT` só leva nome, símbolo e `ativo`.
class DadosUnidade {
  final String nome;
  final String simbolo;

  /// `MASSA`, `VOLUME` ou `UNIDADE`.
  final String? tipoMedida;

  /// Quanto 1 desta unidade vale na base do seu tipo, como digitado
  /// (pt-BR). `1` define a própria unidade como base.
  final String fatorParaBase;

  /// Soft delete (RNF08). Preservado na edição.
  final bool ativo;

  const DadosUnidade({
    this.nome = '',
    this.simbolo = '',
    this.tipoMedida,
    this.fatorParaBase = '',
    this.ativo = true,
  });

  DadosUnidade copiarCom({
    String? nome,
    String? simbolo,
    String? tipoMedida,
    String? fatorParaBase,
    bool? ativo,
  }) => DadosUnidade(
    nome: nome ?? this.nome,
    simbolo: simbolo ?? this.simbolo,
    tipoMedida: tipoMedida ?? this.tipoMedida,
    fatorParaBase: fatorParaBase ?? this.fatorParaBase,
    ativo: ativo ?? this.ativo,
  );

  double? get fatorNumero => parseNumeroBr(fatorParaBase);

  String get nomeLimpo => nome.trim();
  String get simboloLimpo => simbolo.trim();

  /// Payload de `POST /unidades-medida`.
  UnidadeMedidaCreateRequest paraCriacao() => UnidadeMedidaCreateRequest(
    nome: nomeLimpo,
    simbolo: simboloLimpo,
    tipoMedida: tipoMedida ?? '',
    fatorParaBase: fatorNumero ?? 1,
  );

  /// Payload de `PUT /unidades-medida/{id}` — sem tipo nem fator.
  UnidadeMedidaUpdateRequest paraEdicao() => UnidadeMedidaUpdateRequest(
    nome: nomeLimpo,
    simbolo: simboloLimpo,
    ativo: ativo,
  );
}

/// Regras de preenchimento do formulário de unidade de medida.
class ValidadorUnidade {
  const ValidadorUnidade._();

  static const nomeTamanhoMinimo = 2;
  static const nomeTamanhoMaximo = 60;
  static const simboloTamanhoMaximo = 8;

  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome.';
    if (nome.length < nomeTamanhoMinimo) {
      return 'O nome deve ter no mínimo $nomeTamanhoMinimo caracteres.';
    }
    return null;
  }

  static String? validarSimbolo(String? valor) =>
      (valor?.trim() ?? '').isEmpty ? 'Informe o símbolo.' : null;

  /// O fator precisa ser positivo: ele multiplica a quantidade para chegar
  /// à base, e zero ou negativo tornaria a conversão sem sentido.
  static String? validarFator(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o fator.';
    final numero = parseNumeroBr(texto);
    if (numero == null || numero <= 0) {
      return 'O fator deve ser maior que zero.';
    }
    return null;
  }

  static String? validarTipo(String? valor) =>
      valor == null ? 'Selecione o tipo de medida.' : null;

  /// Primeiro problema encontrado, ou `null` quando dá para salvar.
  ///
  /// Em [ehEdicao] o tipo e o fator não são conferidos — eles nem são
  /// enviados.
  static String? validar(DadosUnidade d, {required bool ehEdicao}) {
    final basico = validarNome(d.nome) ?? validarSimbolo(d.simbolo);
    if (basico != null) return basico;
    if (ehEdicao) return null;
    return validarTipo(d.tipoMedida) ?? validarFator(d.fatorParaBase);
  }
}
