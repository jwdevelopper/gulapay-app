class ItemComandaResponse {
  ItemComandaResponse.fromJson(Map<String, dynamic> json)
      : id = _int(json['id']),
        produtoNome = json['produtoNome']?.toString() ?? json['nome']?.toString() ?? 'Item',
        quantidade = _num(json['quantidade']),
        precoUnitario = _double(json['precoUnitario'] ?? json['preco']),
        total = _double(json['total'] ?? json['subtotal']);

  final int? id;
  final String produtoNome;
  final double quantidade;
  final double precoUnitario;
  final double total;

  static int? _int(dynamic value) => value == null ? null : int.tryParse(value.toString());
  static double _double(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  static double _num(dynamic value) => _double(value ?? 0);
}

class ComandaResponse {
  ComandaResponse.fromJson(Map<String, dynamic> json)
      : id = _int(json['id']),
        codigo = json['codigo']?.toString() ?? '',
        tipoOrigem = json['tipoOrigem']?.toString() ?? '',
        escopo = json['escopo']?.toString(),
        status = json['status']?.toString() ?? '',
        clienteId = _int(json['clienteId']),
        clienteNome = json['clienteNome']?.toString(),
        clienteTelefone = json['clienteTelefone']?.toString(),
        linkWhatsApp = json['linkWhatsApp']?.toString(),
        mesaId = _int(json['mesaId']),
        mesaNumero = json['mesaNumero']?.toString(),
        garcomId = _int(json['garcomId']),
        garcomNome = json['garcomNome']?.toString(),
        enderecoEntregaId = _int(json['enderecoEntregaId']),
        observacao = json['observacao']?.toString(),
        totalBruto = _double(json['totalBruto']),
        totalDescontos = _double(json['totalDescontos']),
        totalAcrescimos = _double(json['totalAcrescimos']),
        totalLiquido = _double(json['totalLiquido']),
        dataAbertura = DateTime.tryParse(json['dataAbertura']?.toString() ?? ''),
        dataFechamento = DateTime.tryParse(json['dataFechamento']?.toString() ?? ''),
        itens = (json['itens'] is List ? json['itens'] as List : const [])
            .whereType<Map>()
            .map((e) => ItemComandaResponse.fromJson(Map<String, dynamic>.from(e)))
            .toList();

  final int? id;
  final String codigo;
  final String tipoOrigem;
  final String? escopo;
  final String status;
  final int? clienteId;
  final String? clienteNome;
  final String? clienteTelefone;
  final String? linkWhatsApp;
  final int? mesaId;
  final String? mesaNumero;
  final int? garcomId;
  final String? garcomNome;
  final int? enderecoEntregaId;
  final String? observacao;
  final double totalBruto;
  final double totalDescontos;
  final double totalAcrescimos;
  final double totalLiquido;
  final DateTime? dataAbertura;
  final DateTime? dataFechamento;
  final List<ItemComandaResponse> itens;

  static int? _int(dynamic value) => value == null ? null : int.tryParse(value.toString());
  static double _double(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}
