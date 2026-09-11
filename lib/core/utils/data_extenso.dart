/// Formatação de datas para agrupamento e exibição em listas.
///
/// Trabalha com a string ISO que a API devolve (`dataHora`), tolerando
/// `null` e texto inválido — devolve string vazia em vez de lançar, porque
/// o chamador é sempre uma árvore de widgets.
///
/// Extraído de `estoque_page.dart`, onde os três formatadores viviam como
/// métodos privados do `State`.
class DataExtenso {
  const DataExtenso._();

  static const _meses = [
    '',
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];

  /// Cabeçalho de grupo de uma lista cronológica.
  ///
  /// Devolve `HOJE` e `ONTEM` para os dois últimos dias, `12 MAR` dentro do
  /// ano corrente e `12 MAR 2025` para anos anteriores.
  static String cabecalho(String? dataHoraIso) {
    final data = _parse(dataHoraIso);
    if (data == null) return '';

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(data.year, data.month, data.day);
    final diferenca = hoje.difference(dia).inDays;

    if (diferenca == 0) return 'HOJE';
    if (diferenca == 1) return 'ONTEM';

    final mes = _meses[data.month];
    return data.year == agora.year
        ? '${data.day} $mes'
        : '${data.day} $mes ${data.year}';
  }

  /// Hora no formato `HH:mm`.
  static String hora(String? dataHoraIso) {
    final data = _parse(dataHoraIso);
    if (data == null) return '';
    final h = data.hour.toString().padLeft(2, '0');
    final m = data.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Chave de agrupamento por dia (`aaaa-mm-dd`).
  ///
  /// Diferente de [cabecalho], que é texto para o usuário: esta é estável
  /// e serve para comparar se dois registros caem no mesmo dia.
  static String chaveDoDia(String? dataHoraIso) {
    final data = _parse(dataHoraIso);
    if (data == null) return '';
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '${data.year}-$mes-$dia';
  }

  /// Data curta para exibição em campo (`dd/mm/aaaa`).
  static String curta(DateTime? data, {String sePadrao = 'Selecionar'}) {
    if (data == null) return sePadrao;
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  static DateTime? _parse(String? iso) {
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }
}
