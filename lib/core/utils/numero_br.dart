/// Conversão entre número e o texto que o usuário brasileiro digita.
///
/// No Brasil o separador decimal é a vírgula e o ponto agrupa milhares —
/// `1.234,56`. Como os campos numéricos do app são `TextField` livres (o
/// teclado decimal não impede o usuário de digitar do jeito que quiser),
/// todo formulário precisava traduzir isso na mão. Oito arquivos tinham a
/// própria cópia de `replaceAll(',', '.')`, cada uma tratando um subconjunto
/// diferente dos casos.
///
/// Este arquivo é a fonte única dessa conversão. Não depende de Flutter,
/// então é testável direto.
library;

/// Lê um número digitado no formato brasileiro.
///
/// Devolve `null` quando o texto está vazio ou não é um número — quem
/// chama decide se isso é erro de validação ou campo opcional em branco.
///
/// ```dart
/// parseNumeroBr('1.234,56');  // 1234.56
/// parseNumeroBr('7,40');      // 7.4
/// parseNumeroBr('12');        // 12.0
/// parseNumeroBr('  ');        // null
/// parseNumeroBr('abc');       // null
/// ```
///
/// O ponto é tratado como separador de milhar e descartado; só a vírgula
/// vira separador decimal. Isso torna `1.234` igual a mil duzentos e trinta
/// e quatro, e não a 1,234 — a leitura correta para quem digitou em pt-BR.
double? parseNumeroBr(String? texto) {
  if (texto == null) return null;
  final limpo = texto.trim().replaceAll('.', '').replaceAll(',', '.');
  if (limpo.isEmpty) return null;
  return double.tryParse(limpo);
}

/// Escreve um número no formato brasileiro, sem símbolo de moeda.
///
/// [casas] fixa quantos dígitos vêm depois da vírgula. Passe `null` para
/// remover os zeros à direita — útil em quantidades, onde `5` lê melhor que
/// `5,00`, mas `2,5` precisa da casa decimal.
///
/// ```dart
/// formatarNumeroBr(7.4);              // '7,40'
/// formatarNumeroBr(5, casas: null);   // '5'
/// formatarNumeroBr(2.5, casas: null); // '2,5'
/// formatarNumeroBr(null);             // '—'
/// ```
String formatarNumeroBr(double? valor, {int? casas = 2, String vazio = '—'}) {
  if (valor == null) return vazio;
  var texto = casas == null ? valor.toString() : valor.toStringAsFixed(casas);
  if (casas == null && texto.contains('.')) {
    texto = texto.replaceFirst(RegExp(r'\.?0+$'), '');
  }
  return texto.replaceAll('.', ',');
}

/// Escreve um valor monetário em reais.
///
/// ```dart
/// formatarMoedaBr(7.4);   // 'R$ 7,40'
/// formatarMoedaBr(null);  // '—'
/// ```
String formatarMoedaBr(double? valor, {String vazio = '—'}) =>
    valor == null ? vazio : 'R\$ ${formatarNumeroBr(valor)}';
