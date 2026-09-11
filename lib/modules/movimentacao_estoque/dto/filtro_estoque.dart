import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';

/// Filtro da listagem de movimentações de estoque.
///
/// Objeto de valor imutável (sem Flutter): a página guarda uma instância e
/// troca por outra a cada mudança, em vez de manter quatro campos soltos no
/// `State`. Como a filtragem também vive aqui, dá para testá-la sem
/// renderizar a tela.
///
/// ```dart
/// final visiveis = _filtro.aplicar(_todasMovimentacoes);
/// ```
class FiltroEstoque {
  /// Categoria do movimento: `TUDO`, `ENTRADAS`, `SAIDAS` ou `AJUSTES`.
  final String tipo;

  /// Restringe a um insumo específico. `null` = todos.
  final int? insumoId;

  /// Início do período (inclusive). `null` = sem limite inferior.
  final DateTime? de;

  /// Fim do período (inclusive). `null` = sem limite superior.
  final DateTime? ate;

  const FiltroEstoque({this.tipo = tudo, this.insumoId, this.de, this.ate});

  static const tudo = 'TUDO';
  static const entradas = 'ENTRADAS';
  static const saidas = 'SAIDAS';
  static const ajustes = 'AJUSTES';

  /// Há filtro além da categoria? É o que acende o selo no botão de
  /// filtros do cabeçalho.
  bool get temFiltroAvancado => insumoId != null || de != null || ate != null;

  /// Nenhum filtro aplicado.
  bool get vazio => tipo == tudo && !temFiltroAvancado;

  FiltroEstoque copiarCom({
    String? tipo,
    int? insumoId,
    DateTime? de,
    DateTime? ate,
    bool limparInsumo = false,
    bool limparDe = false,
    bool limparAte = false,
  }) => FiltroEstoque(
    tipo: tipo ?? this.tipo,
    insumoId: limparInsumo ? null : (insumoId ?? this.insumoId),
    de: limparDe ? null : (de ?? this.de),
    ate: limparAte ? null : (ate ?? this.ate),
  );

  /// Aplica o filtro e ordena da movimentação mais recente para a mais
  /// antiga. Registros sem data são descartados quando há filtro de
  /// período — não há como afirmar que caem dentro dele.
  List<MovimentacaoEstoque> aplicar(List<MovimentacaoEstoque> origem) {
    var lista = List<MovimentacaoEstoque>.from(origem);

    lista = switch (tipo) {
      entradas => lista.where((m) => m.isEntrada).toList(),
      saidas => lista.where((m) => m.isSaida).toList(),
      ajustes => lista.where((m) => m.isAjuste).toList(),
      _ => lista,
    };

    if (insumoId != null) {
      lista = lista.where((m) => m.insumoId == insumoId).toList();
    }

    if (de != null || ate != null) {
      lista = lista.where(_dentroDoPeriodo).toList();
    }

    lista.sort((a, b) => (b.dataHora ?? '').compareTo(a.dataHora ?? ''));
    return lista;
  }

  bool _dentroDoPeriodo(MovimentacaoEstoque m) {
    if (m.dataHora == null) return false;
    final data = DateTime.tryParse(m.dataHora!);
    if (data == null) return false;
    if (de != null && data.isBefore(de!)) return false;
    if (ate != null && data.isAfter(ate!)) return false;
    return true;
  }
}
