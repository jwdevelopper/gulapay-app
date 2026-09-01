class ItemComandaResponse {
  ItemComandaResponse.fromJson(Map<String, dynamic> json)
      : id = _int(json['id']),
        comandaId = _int(json['comandaId']),
        produtoId = _int(json['produtoId']),
        produtoNome = json['produtoNome']?.toString() ?? json['nome']?.toString() ?? 'Item',
        precoUnitario = _double(json['precoUnitario'] ?? json['preco']),
        quantidade = _double(json['quantidade']),
        valorDesconto = _double(json['valorDesconto']),
        valorAcrescimo = _double(json['valorAcrescimo']),
        subtotal = _double(json['subtotal'] ?? json['total']),
        status = json['status']?.toString() ?? '',
        motivoCancelamento = json['motivoCancelamento']?.toString(),
        observacao = json['observacao']?.toString(),
        itemOrigemId = _int(json['itemOrigemId']),
        lancadoPorId = _int(json['lancadoPorId']),
        lancadoPorNome = json['lancadoPorNome']?.toString(),
        dataLancamento = DateTime.tryParse(json['dataLancamento']?.toString() ?? ''),
        dataStatus = DateTime.tryParse(json['dataStatus']?.toString() ?? '');

  final int? id;
  final int? comandaId;
  final int? produtoId;
  final String produtoNome;
  final double precoUnitario;
  final double quantidade;
  final double valorDesconto;
  final double valorAcrescimo;
  final double subtotal;

  /// Alias usado pela UI legada da comanda.
  double get total => subtotal;
  final String status;
  final String? motivoCancelamento;
  final String? observacao;
  final int? itemOrigemId;
  final int? lancadoPorId;
  final String? lancadoPorNome;
  final DateTime? dataLancamento;
  final DateTime? dataStatus;

  bool get emPreparo => status == 'EM_PREPARO';
  bool get entregue => status == 'ENTREGUE';
  bool get cancelado => status == 'CANCELADO';
  bool get transferido => status == 'TRANSFERIDO';

  static int? _int(dynamic value) => value == null ? null : int.tryParse(value.toString());
  static double _double(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
