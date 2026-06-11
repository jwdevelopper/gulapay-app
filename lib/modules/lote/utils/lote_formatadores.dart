/// Formatadores simples (sem dependência de `intl`) para datas, quantidades e
/// moeda, no padrão pt-BR usado nas telas de Lote.
class LoteFormatadores {
  LoteFormatadores._();

  static const List<String> _mesesAbreviados = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  /// Converte uma data ISO (`yyyy-MM-dd`, como o backend devolve `LocalDate`)
  /// em [DateTime]. Retorna `null` quando o valor é nulo ou inválido.
  static DateTime? parseData(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso.trim());
  }

  /// `25/05/2026`. Quando não há data, devolve `'—'`.
  static String formatarData(String? iso) {
    final data = parseData(iso);
    if (data == null) return '—';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  /// `25 mai` — versão curta usada nos cards e no herói do detalhe.
  static String formatarDataCurta(String? iso) {
    final data = parseData(iso);
    if (data == null) return '—';
    final mes = _mesesAbreviados[data.month - 1];
    return '${data.day} $mes';
  }

  /// Dia isolado (`25`) — usado no bloco de código do card.
  static String diaDoMes(String? iso) {
    final data = parseData(iso);
    if (data == null) return '--';
    return data.day.toString().padLeft(2, '0');
  }

  /// Mês abreviado isolado (`mai`) — usado no bloco de código do card.
  static String mesAbreviado(String? iso) {
    final data = parseData(iso);
    if (data == null) return '';
    return _mesesAbreviados[data.month - 1];
  }

  /// Quantidade no padrão pt-BR: vírgula decimal, sem zeros desnecessários
  /// (`5`, `2,4`, `18`). Símbolo da unidade é responsabilidade da UI.
  static String formatarQuantidade(double? valor) {
    if (valor == null) return '0';
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }
    return valor
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'[.,]$'), '')
        .replaceAll('.', ',');
  }

  /// `R$ 78,00`.
  static String formatarMoeda(double? valor) {
    final v = valor ?? 0;
    return 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
