/// Cabeçalho de uma seção da listagem de insumos.
///
/// A lista é agrupada em seções ("Abaixo do mínimo", "Em estoque") e cada
/// uma exibe o rótulo com a contagem de itens ao lado.
class CabecalhoSecao {
  final String rotulo;
  final int quantidade;

  const CabecalhoSecao(this.rotulo, this.quantidade);
}
