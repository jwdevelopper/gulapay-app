class EventoItemComandaResponse {
  EventoItemComandaResponse.fromJson(Map<String, dynamic> json)
      : id = _int(json['id']),
        itemComandaId = _int(json['itemComandaId']),
        acao = json['acao']?.toString() ?? '',
        usuarioId = _int(json['usuarioId']),
        usuarioLogin = json['usuarioLogin']?.toString(),
        usuarioNome = json['usuarioNome']?.toString(),
        motivo = json['motivo']?.toString(),
        valorAntes = json['valorAntes']?.toString(),
        valorDepois = json['valorDepois']?.toString(),
        dataHora = DateTime.tryParse(json['dataHora']?.toString() ?? '');

  final int? id;
  final int? itemComandaId;
  final String acao;
  final int? usuarioId;
  final String? usuarioLogin;
  final String? usuarioNome;
  final String? motivo;
  final String? valorAntes;
  final String? valorDepois;
  final DateTime? dataHora;

  static int? _int(dynamic value) => value == null ? null : int.tryParse(value.toString());
}
