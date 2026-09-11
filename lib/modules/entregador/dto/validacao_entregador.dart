import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_create_request.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_update_request.dart';

/// Retrato dos dados do formulário de entregador.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e o [ValidadorEntregador] decide se dá para salvar.
class DadosEntregador {
  final String nome;

  /// Telefone como digitado, com máscara. O que vai para a API são só os
  /// dígitos — ver [telefoneParaApi].
  final String telefone;

  /// Soft delete (RNF08). Só a edição envia este campo; entregador nasce
  /// ativo.
  final bool ativo;

  const DadosEntregador({
    this.nome = '',
    this.telefone = '',
    this.ativo = true,
  });

  DadosEntregador copiarCom({String? nome, String? telefone, bool? ativo}) =>
      DadosEntregador(
        nome: nome ?? this.nome,
        telefone: telefone ?? this.telefone,
        ativo: ativo ?? this.ativo,
      );

  /// Só os dígitos: `(44) 99999-0000` e `44999990000` precisam chegar ao
  /// backend como o mesmo valor.
  String get telefoneParaApi => TelefoneFormatter.somenteDigitos(telefone);

  /// Payload de `POST /entregadores`.
  EntregadorCreateRequest paraCriacao() =>
      EntregadorCreateRequest(nome: nome.trim(), telefone: telefoneParaApi);

  /// Payload de `PUT /entregadores/{id}`.
  EntregadorUpdateRequest paraEdicao() => EntregadorUpdateRequest(
    nome: nome.trim(),
    telefone: telefoneParaApi,
    ativo: ativo,
  );
}

/// Regras de preenchimento do formulário de entregador.
class ValidadorEntregador {
  const ValidadorEntregador._();

  static const nomeTamanhoMinimo = 2;

  /// Menor quantidade de dígitos de um telefone brasileiro válido: DDD com
  /// dois dígitos mais oito do assinante (fixo).
  static const telefoneDigitosMinimo = 10;

  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome.';
    if (nome.length < nomeTamanhoMinimo) {
      return 'O nome deve ter no mínimo $nomeTamanhoMinimo caracteres.';
    }
    return null;
  }

  static String? validarTelefone(String? valor) {
    final digitos = TelefoneFormatter.somenteDigitos(valor);
    if (digitos.isEmpty) return 'Informe o telefone.';
    if (digitos.length < telefoneDigitosMinimo) {
      return 'Telefone incompleto. Informe DDD e número.';
    }
    return null;
  }

  /// Primeiro problema encontrado, ou `null` quando dá para salvar.
  static String? validar(DadosEntregador d) =>
      validarNome(d.nome) ?? validarTelefone(d.telefone);
}
