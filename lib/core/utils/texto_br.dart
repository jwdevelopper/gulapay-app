/// Comparação e busca de texto em português.
///
/// O `compareTo` de String compara code units, então `'Água'` fica **depois**
/// de `'Zebra'` — 'Á' é U+00C1, acima de todas as letras sem acento. Uma
/// lista de produtos ordenada assim joga tudo que começa com acento para o
/// fim, o que não é o que um usuário brasileiro espera de "ordem
/// alfabética".
///
/// Este arquivo resolve isso removendo os acentos antes de comparar. Não
/// depende de Flutter, então é testável direto.
library;

/// Cada letra acentuada e a sua forma simples.
///
/// Cobre o que aparece em português; um caractere fora da tabela passa
/// intacto, o que é o comportamento seguro (ele só não participa da
/// equivalência).
const _semAcento = <String, String>{
  'á': 'a',
  'à': 'a',
  'ã': 'a',
  'â': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'õ': 'o',
  'ô': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// Versão do texto em minúsculas e sem acentos.
///
/// É a chave usada tanto para ordenar quanto para buscar: com ela,
/// procurar por `acucar` encontra "Açúcar".
///
/// ```dart
/// normalizarTexto('Água');   // 'agua'
/// normalizarTexto('AÇÚCAR'); // 'acucar'
/// ```
String normalizarTexto(String? texto) {
  final minusculo = (texto ?? '').toLowerCase();
  final buffer = StringBuffer();
  for (final caractere in minusculo.split('')) {
    buffer.write(_semAcento[caractere] ?? caractere);
  }
  return buffer.toString();
}

/// Compara dois textos em ordem alfabética brasileira.
///
/// Use no lugar de `a.compareTo(b)` sempre que a ordem for mostrada ao
/// usuário.
///
/// ```dart
/// lista.sort((a, b) => compararTextoBr(a.nome, b.nome));
/// ```
int compararTextoBr(String? a, String? b) =>
    normalizarTexto(a).compareTo(normalizarTexto(b));

/// O texto contém o termo, ignorando acentos e maiúsculas?
///
/// Termo em branco devolve `true` — "sem filtro" não recorta nada.
bool contemTextoBr(String? texto, String? termo) {
  final procurado = normalizarTexto(termo).trim();
  if (procurado.isEmpty) return true;
  return normalizarTexto(texto).contains(procurado);
}
