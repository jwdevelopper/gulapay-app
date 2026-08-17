import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

/// ---------------------------------------------------------------------------
/// PONTO ÚNICO DE ACOPLAMENTO
///
/// Se o construtor de `UnidadeMedidaResponse` for diferente do assumido aqui,
/// ajuste APENAS este arquivo — nenhum outro teste depende do formato do DTO.
/// ---------------------------------------------------------------------------

UnidadeMedidaResponse unidadeFixture({
  int id = 1,
  String nome = 'Quilograma',
  String simbolo = 'kg',
  String tipoMedida = 'Pesagem',
  double fatorParaBase = 0.2,
  bool ativo = true,
}) {
  return UnidadeMedidaResponse(
    id: id,
    nome: nome,
    simbolo: simbolo,
    tipoMedida: tipoMedida,
    fatorParaBase: fatorParaBase,
    ativo: ativo,
  );
}

/// Lista padrão usada na maioria dos testes: 2 ativas + 1 inativa.
/// A inativa existe de propósito, para provar que o form filtra `ativo == true`.
List<UnidadeMedidaResponse> unidadesFixture() => [
      unidadeFixture(id: 1, nome: 'Quilograma', simbolo: 'kg', tipoMedida: 'Pesagem', fatorParaBase: 0.2),
      unidadeFixture(id: 2, nome: 'Litro', simbolo: 'L', tipoMedida: 'Unidade', fatorParaBase: 0.2),
      unidadeFixture(id: 3, nome: 'Caixa', simbolo: 'cx', ativo: false, tipoMedida: 'Unidade', fatorParaBase: 0.2),
    ];

InsumoResponse insumoFixture({
  int id = 1,
  String? nome = 'Tomate italiano',
  int? unidadePadraoId = 1,
  String? unidadePadraoSimbolo = 'kg',
  String? unidadePadraoNome = 'Quilograma',
  double? estoqueMinimo = 10,
  double? estoqueAtual = 25,
  bool? abaixoDoMinimo = false,
  bool? ativo = true,
}) {
  return InsumoResponse(
    id: id,
    nome: nome,
    unidadePadraoId: unidadePadraoId,
    unidadePadraoSimbolo: unidadePadraoSimbolo,
    unidadePadraoNome: unidadePadraoNome,
    estoqueMinimo: estoqueMinimo,
    estoqueAtual: estoqueAtual,
    abaixoDoMinimo: abaixoDoMinimo,
    ativo: ativo,
  );
}

/// Cenário base da listagem:
///  - Tomate italiano  → kg, ativo,  estoque OK      (25)
///  - Queijo mussarela → kg, ativo,  ABAIXO do mínimo (2 de 5)
///  - Azeite extra     → L,  INATIVO, estoque OK      (40)
///
/// Isso dá: 2 ativos · 1 abaixo do mínimo, 2 unidades distintas,
/// e ordenação por estoque com resultado inequívoco (2 < 25 < 40).
List<InsumoResponse> insumosFixture() => [
      insumoFixture(
        id: 1,
        nome: 'Tomate italiano',
        unidadePadraoId: 1,
        unidadePadraoSimbolo: 'kg',
        unidadePadraoNome: 'Quilograma',
        estoqueMinimo: 10,
        estoqueAtual: 25,
        abaixoDoMinimo: false,
        ativo: true,
      ),
      insumoFixture(
        id: 2,
        nome: 'Queijo mussarela',
        unidadePadraoId: 1,
        unidadePadraoSimbolo: 'kg',
        unidadePadraoNome: 'Quilograma',
        estoqueMinimo: 5,
        estoqueAtual: 2,
        abaixoDoMinimo: true,
        ativo: true,
      ),
      insumoFixture(
        id: 3,
        nome: 'Azeite extra virgem',
        unidadePadraoId: 2,
        unidadePadraoSimbolo: 'L',
        unidadePadraoNome: 'Litro',
        estoqueMinimo: 8,
        estoqueAtual: 40,
        abaixoDoMinimo: false,
        ativo: false,
      ),
    ];
