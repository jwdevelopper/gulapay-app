import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_status_validade.dart';

/// Janela de validade usada para filtrar os lotes de um insumo.
///
/// O backend já devolve os lotes em ordem FEFO; este filtro só recorta a
/// lista no cliente, para o usuário achar rápido o que está vencendo.
enum JanelaValidade {
  /// Sem recorte.
  todos('Todos'),

  /// Só o que já passou da validade — o que precisa de
  /// `SAIDA_PERDA_VALIDADE`.
  vencidos('⏰ Vencidos'),

  /// Vence nos próximos 7 dias.
  ate7Dias('⚠️ 7d'),

  /// Vence nos próximos 30 dias (inclui a janela de 7).
  ate30Dias('📅 30d');

  const JanelaValidade(this.rotulo);

  /// Texto do chip.
  final String rotulo;
}

/// Estado dos filtros da listagem de lotes.
///
/// Objeto de valor puro (sem Flutter): guarda o termo de busca e a janela
/// de validade, e sabe aplicá-los sobre a lista carregada. Fica fora da
/// árvore de widgets para poder ser testado sem renderizar nada.
class FiltroLotes {
  /// Termo digitado na busca. Confere código e nome do insumo.
  final String texto;

  /// Recorte por validade.
  final JanelaValidade janela;

  const FiltroLotes({this.texto = '', this.janela = JanelaValidade.todos});

  /// Nenhum recorte ativo.
  bool get vazio => texto.trim().isEmpty && janela == JanelaValidade.todos;

  FiltroLotes copiarCom({String? texto, JanelaValidade? janela}) =>
      FiltroLotes(texto: texto ?? this.texto, janela: janela ?? this.janela);

  /// Peneira a lista, preservando a ordem FEFO que veio do backend.
  List<LoteResponse> aplicar(List<LoteResponse> lotes) =>
      lotes.where((l) => _combinaTexto(l) && _combinaJanela(l)).toList();

  /// Quantos lotes da lista caem numa janela — alimenta o contador dos
  /// chips ("Vencidos · 3").
  int contar(List<LoteResponse> lotes, JanelaValidade janela) =>
      lotes.where((l) => _naJanela(l, janela)).length;

  bool _combinaTexto(LoteResponse lote) {
    if (texto.trim().isEmpty) return true;
    return contemTextoBr(lote.codigo, texto) ||
        contemTextoBr(lote.insumoNome, texto);
  }

  bool _combinaJanela(LoteResponse lote) => _naJanela(lote, janela);

  static bool _naJanela(LoteResponse lote, JanelaValidade janela) {
    final status = LoteStatusValidade.calcular(lote.validade);
    return switch (janela) {
      JanelaValidade.todos => true,
      JanelaValidade.vencidos => status == LoteStatusValidade.vencido,
      JanelaValidade.ate7Dias => status == LoteStatusValidade.ate7Dias,
      // A janela de 30 dias engloba a de 7 — quem pergunta "o que vence no
      // mês" quer ver também o que vence na semana.
      JanelaValidade.ate30Dias =>
        status == LoteStatusValidade.ate7Dias ||
            status == LoteStatusValidade.ate30Dias,
    };
  }
}
