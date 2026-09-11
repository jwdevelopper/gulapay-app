import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/insumo/dto/cabecalho_secao.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

/// Como a lista de insumos é ordenada e agrupada.
///
/// Algumas ordenações também agrupam: "Alerta" separa o que está abaixo do
/// mínimo do resto, "Nome A-Z" quebra por letra inicial e "Unidade" junta
/// por símbolo. O agrupamento é o que faz a lista longa continuar legível.
enum OrdenacaoInsumo {
  /// Abaixo do mínimo primeiro — a visão operacional (RF43).
  alerta('Alerta de estoque', 'Abaixo do mínimo primeiro'),
  estoqueCrescente('Estoque crescente', 'Do menor para o maior'),
  estoqueDecrescente('Estoque decrescente', 'Do maior para o menor'),
  nomeCrescente('Nome A-Z', 'Agrupado por letra inicial'),
  nomeDecrescente('Nome Z-A', 'Alfabética decrescente'),
  unidade('Por unidade de medida', 'Agrupado por kg, L, un…');

  const OrdenacaoInsumo(this.rotulo, this.descricao);

  /// Texto do item na folha de ordenação.
  final String rotulo;

  /// Explicação exibida abaixo do rótulo.
  final String descricao;

  /// Esta ordenação quebra a lista em seções?
  bool get agrupa => this == alerta || this == nomeCrescente || this == unidade;
}

/// Rótulos das duas seções da ordenação por alerta.
const _secaoAbaixoDoMinimo = 'Abaixo do mínimo';
const _secaoEstoquePadrao = 'Estoque padrão';

/// Estado da busca e da ordenação da listagem de insumos.
///
/// Objeto de valor puro (sem Flutter). Concentra três decisões que estavam
/// espalhadas entre a página e uma lista de opções com closures: o que
/// entra, em que ordem, e como as seções são montadas.
class FiltroInsumos {
  /// Termo digitado. Confere o nome do insumo.
  final String texto;

  final OrdenacaoInsumo ordenacao;

  const FiltroInsumos({
    this.texto = '',
    this.ordenacao = OrdenacaoInsumo.alerta,
  });

  /// Nenhuma busca ativa. A ordenação não conta: sempre há uma.
  bool get vazio => texto.trim().isEmpty;

  FiltroInsumos copiarCom({String? texto, OrdenacaoInsumo? ordenacao}) =>
      FiltroInsumos(
        texto: texto ?? this.texto,
        ordenacao: ordenacao ?? this.ordenacao,
      );

  /// Peneira e ordena, sem alterar a lista recebida.
  List<InsumoResponse> aplicar(List<InsumoResponse> insumos) {
    final lista = insumos.where((i) => contemTextoBr(i.nome, texto)).toList();
    lista.sort(_comparar);
    return lista;
  }

  /// A lista pronta para a tela: cabeçalhos de seção intercalados com os
  /// insumos, ou só os insumos quando a ordenação não agrupa.
  ///
  /// Devolve `Object` porque a lista é heterogênea — quem renderiza checa
  /// se o item é [CabecalhoSecao].
  List<Object> agrupar(List<InsumoResponse> insumos) {
    final ordenados = aplicar(insumos);
    if (!ordenacao.agrupa) return List<Object>.from(ordenados);

    // LinkedHashMap preserva a ordem de inserção, então as seções saem na
    // ordem em que a lista já ordenada as encontrou.
    final secoes = <String, List<InsumoResponse>>{};
    for (final insumo in ordenados) {
      secoes.putIfAbsent(_secaoDe(insumo), () => []).add(insumo);
    }

    final chaves = secoes.keys.toList()..sort(_ordemDasSecoes);
    return [
      for (final chave in chaves) ...[
        CabecalhoSecao(chave, secoes[chave]!.length),
        ...secoes[chave]!,
      ],
    ];
  }

  int _comparar(InsumoResponse a, InsumoResponse b) => switch (ordenacao) {
    OrdenacaoInsumo.estoqueCrescente => (a.estoqueAtual ?? 0).compareTo(
      b.estoqueAtual ?? 0,
    ),
    OrdenacaoInsumo.estoqueDecrescente => (b.estoqueAtual ?? 0).compareTo(
      a.estoqueAtual ?? 0,
    ),
    OrdenacaoInsumo.nomeDecrescente => compararTextoBr(b.nome, a.nome),
    // Alerta, A-Z e unidade ordenam por nome dentro de cada seção.
    _ => compararTextoBr(a.nome, b.nome),
  };

  String _secaoDe(InsumoResponse insumo) => switch (ordenacao) {
    OrdenacaoInsumo.alerta =>
      insumo.abaixoDoMinimo == true
          ? _secaoAbaixoDoMinimo
          : _secaoEstoquePadrao,
    OrdenacaoInsumo.unidade => insumo.unidadePadraoSimbolo ?? 'sem unidade',
    // Letra inicial, para a lista A-Z.
    _ =>
      (insumo.nome ?? '').trim().isEmpty
          ? '#'
          : (insumo.nome ?? '').trim()[0].toUpperCase(),
  };

  /// Ordem das seções.
  ///
  /// Na visão de alerta, "Abaixo do mínimo" vem sempre primeiro — é o que
  /// exige ação. Nas demais, ordem alfabética.
  int _ordemDasSecoes(String a, String b) {
    if (ordenacao == OrdenacaoInsumo.alerta) {
      if (a == _secaoAbaixoDoMinimo) return -1;
      if (b == _secaoAbaixoDoMinimo) return 1;
      return 0;
    }
    return compararTextoBr(a, b);
  }
}
