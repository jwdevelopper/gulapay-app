import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';

/// Estado dos filtros da listagem de clientes.
///
/// Objeto de valor puro (sem Flutter). O recorte é em memória: a página
/// carrega a lista inteira e peneira aqui.
class FiltroClientes {
  /// Termo digitado. Confere nome e telefone.
  final String texto;

  /// Recorte por soft delete (RNF08).
  final SituacaoCadastro situacao;

  const FiltroClientes({
    this.texto = '',
    this.situacao = SituacaoCadastro.todos,
  });

  /// Nenhum recorte ativo.
  bool get vazio => texto.trim().isEmpty && situacao == SituacaoCadastro.todos;

  FiltroClientes copiarCom({String? texto, SituacaoCadastro? situacao}) =>
      FiltroClientes(
        texto: texto ?? this.texto,
        situacao: situacao ?? this.situacao,
      );

  List<ClienteResponse> aplicar(List<ClienteResponse> clientes) => clientes
      .where((c) => _combinaTexto(c) && situacao.aceita(c.ativo))
      .toList();

  /// A busca por telefone compara só os dígitos: o cadastro guarda
  /// `44999990000`, mas quem procura costuma digitar `(44) 99999-0000`.
  bool _combinaTexto(ClienteResponse c) {
    if (texto.trim().isEmpty) return true;
    if (contemTextoBr(c.nome, texto)) return true;

    final digitosBuscados = _digitos(texto);
    if (digitosBuscados.isEmpty) return false;
    return _digitos(c.telefone ?? '').contains(digitosBuscados);
  }

  static String _digitos(String texto) =>
      texto.replaceAll(RegExp(r'[^0-9]'), '');
}
