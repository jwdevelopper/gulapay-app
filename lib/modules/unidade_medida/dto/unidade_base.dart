import 'package:my_app_teste/modules/unidade_medida/dto/validacao_unidade.dart';

/// Uma unidade já conhecida do sistema, oferecida como atalho no
/// cadastro.
///
/// São as seis que o backend semeia na migration V8 — as mesmas da
/// documentação (seção 4.5.1). Escolher uma preenche nome, símbolo, tipo
/// e fator de uma vez.
class UnidadeBase {
  final String nome;
  final String simbolo;

  /// `MASSA`, `VOLUME` ou `UNIDADE`.
  final String tipoMedida;

  /// Quanto 1 desta vale na base do seu tipo. `1` marca a própria base.
  final double fatorParaBase;

  const UnidadeBase({
    required this.nome,
    required this.simbolo,
    required this.tipoMedida,
    required this.fatorParaBase,
  });

  /// Esta é a unidade de referência do seu tipo?
  bool get ehBase => fatorParaBase == 1;

  /// Como o atalho se descreve na tela.
  String get descricao => ehBase
      ? 'Referência de $tipoMedida'.toLowerCase()
      : '1 $simbolo equivale a ${fatorParaBase.toInt()} na base';

  /// Preenche os dados do formulário com esta unidade.
  DadosUnidade aplicarEm(DadosUnidade dados) => dados.copiarCom(
    nome: nome,
    simbolo: simbolo,
    tipoMedida: tipoMedida,
    fatorParaBase: fatorParaBase.toInt().toString(),
  );
}

/// Os atalhos oferecidos no cadastro.
///
/// Cobrir as seis do seed resolve o caso comum sem impedir o incomum: um
/// estabelecimento que compra em caixa fechada ainda consegue cadastrar
/// `cx` preenchendo os campos à mão. O atalho é conveniência, não trava —
/// travar significaria que uma unidade legítima e ausente da lista
/// deixaria de ser cadastrável pelo app.
const unidadesBase = <UnidadeBase>[
  UnidadeBase(
    nome: 'Grama',
    simbolo: 'g',
    tipoMedida: 'MASSA',
    fatorParaBase: 1,
  ),
  UnidadeBase(
    nome: 'Quilograma',
    simbolo: 'kg',
    tipoMedida: 'MASSA',
    fatorParaBase: 1000,
  ),
  UnidadeBase(
    nome: 'Mililitro',
    simbolo: 'mL',
    tipoMedida: 'VOLUME',
    fatorParaBase: 1,
  ),
  UnidadeBase(
    nome: 'Litro',
    simbolo: 'L',
    tipoMedida: 'VOLUME',
    fatorParaBase: 1000,
  ),
  UnidadeBase(
    nome: 'Unidade',
    simbolo: 'un',
    tipoMedida: 'UNIDADE',
    fatorParaBase: 1,
  ),
  UnidadeBase(
    nome: 'Dúzia',
    simbolo: 'dz',
    tipoMedida: 'UNIDADE',
    fatorParaBase: 12,
  ),
];

/// O atalho que corresponde a estes dados, se houver.
///
/// Compara pelo símbolo, que é o identificador prático da unidade.
UnidadeBase? baseCorrespondente(String? simbolo) {
  final procurado = (simbolo ?? '').trim().toLowerCase();
  if (procurado.isEmpty) return null;
  for (final base in unidadesBase) {
    if (base.simbolo.toLowerCase() == procurado) return base;
  }
  return null;
}
