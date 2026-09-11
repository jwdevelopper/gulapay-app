import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/core/utils/texto_br.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

/// Estado dos filtros da listagem de unidades de medida.
///
/// Objeto de valor puro (sem Flutter): a página guarda uma instância e a
/// troca a cada toque. `GET /unidades-medida` devolve tudo de uma vez, sem
/// query params, então o recorte é todo em memória — daí o [aplicar].
class FiltroUnidades {
  /// Termo digitado. Confere nome e símbolo.
  final String texto;

  /// Recorte por soft delete (RNF08).
  final SituacaoCadastro situacao;

  /// Tipo de medida (`MASSA`, `VOLUME`, `UNIDADE`) ou `null` para todos.
  final String? tipo;

  const FiltroUnidades({
    this.texto = '',
    this.situacao = SituacaoCadastro.todos,
    this.tipo,
  });

  /// Nenhum recorte ativo.
  bool get vazio =>
      texto.trim().isEmpty &&
      situacao == SituacaoCadastro.todos &&
      tipo == null;

  FiltroUnidades copiarCom({
    String? texto,
    SituacaoCadastro? situacao,
    String? tipo,
    bool limparTipo = false,
  }) => FiltroUnidades(
    texto: texto ?? this.texto,
    situacao: situacao ?? this.situacao,
    tipo: limparTipo ? null : (tipo ?? this.tipo),
  );

  /// Alterna o tipo: tocar no que já está escolhido volta para "todos".
  FiltroUnidades alternarTipo(String valor) =>
      tipo == valor ? copiarCom(limparTipo: true) : copiarCom(tipo: valor);

  List<UnidadeMedidaResponse> aplicar(List<UnidadeMedidaResponse> unidades) =>
      unidades
          .where(
            (u) =>
                _combinaTexto(u) &&
                situacao.aceita(u.ativo) &&
                (tipo == null || u.tipoMedida == tipo),
          )
          .toList();

  bool _combinaTexto(UnidadeMedidaResponse u) {
    if (texto.trim().isEmpty) return true;
    return contemTextoBr(u.nome, texto) || contemTextoBr(u.simbolo, texto);
  }
}
