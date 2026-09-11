import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';

/// Estado da busca e da ordem da listagem de entregadores.
///
/// Objeto de valor puro (sem Flutter). A lista é curta — entregadores são
/// internos e pré-contratados (seção 3.5) —, então tudo é peneirado e
/// ordenado em memória.
class FiltroEntregadores {
  /// Termo digitado. Confere nome e telefone.
  final String texto;

  /// Ordem alfabética: crescente (A-Z) quando verdadeiro.
  final bool crescente;

  const FiltroEntregadores({this.texto = '', this.crescente = true});

  /// Nenhuma busca ativa. A ordem não conta: sempre há uma.
  bool get vazio => texto.trim().isEmpty;

  FiltroEntregadores copiarCom({String? texto, bool? crescente}) =>
      FiltroEntregadores(
        texto: texto ?? this.texto,
        crescente: crescente ?? this.crescente,
      );

  /// Inverte a ordem alfabética.
  FiltroEntregadores inverterOrdem() => copiarCom(crescente: !crescente);

  /// Peneira e ordena, sem alterar a lista recebida.
  List<EntregadorResponse> aplicar(List<EntregadorResponse> entregadores) {
    final lista = entregadores.where(_combinaTexto).toList();
    // compararTextoBr em vez de compareTo: sem tirar os acentos, 'Ângela'
    // cairia depois de 'Zeca' na ordem alfabética.
    lista.sort(
      (a, b) => crescente
          ? compararTextoBr(a.nome, b.nome)
          : compararTextoBr(b.nome, a.nome),
    );
    return lista;
  }

  /// A busca por telefone compara só os dígitos: o cadastro guarda
  /// `44999990000`, mas quem procura costuma digitar `(44) 99999-0000`.
  bool _combinaTexto(EntregadorResponse e) {
    if (texto.trim().isEmpty) return true;
    if (contemTextoBr(e.nome, texto)) return true;

    final procurado = _digitos(texto);
    if (procurado.isEmpty) return false;
    return _digitos(e.telefone).contains(procurado);
  }

  static String _digitos(String texto) =>
      texto.replaceAll(RegExp(r'[^0-9]'), '');
}
