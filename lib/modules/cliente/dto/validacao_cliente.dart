import 'package:my_app_teste/core/utils/cep_formatter.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_create_request.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_endereco.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_update_request.dart';

/// Retrato dos dados do formulário de cliente.
///
/// Objeto de valor puro (sem Flutter): a página monta a partir dos seus
/// controllers e o [ValidadorCliente] decide se dá para salvar.
class DadosCliente {
  final String nome;

  /// Telefone como digitado, com máscara. O que vai para a API são só os
  /// dígitos — ver [telefoneParaApi].
  final String telefone;

  final String email;

  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  /// Soft delete (RNF08). Preservado na edição.
  final bool ativo;

  const DadosCliente({
    this.nome = '',
    this.telefone = '',
    this.email = '',
    this.cep = '',
    this.logradouro = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.uf = '',
    this.ativo = true,
  });

  /// Reconstrói a partir dos campos do formulário, preservando [ativo].
  DadosCliente comCampos({
    required String nome,
    required String telefone,
    required String email,
    required String cep,
    required String logradouro,
    required String numero,
    required String complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) => DadosCliente(
    nome: nome,
    telefone: telefone,
    email: email,
    cep: cep,
    logradouro: logradouro,
    numero: numero,
    complemento: complemento,
    bairro: bairro,
    cidade: cidade,
    uf: uf,
    ativo: ativo,
  );

  /// Só os dígitos — é assim que o telefone identifica o cliente na API.
  String get telefoneParaApi => TelefoneFormatter.somenteDigitos(telefone);

  /// Algum campo de endereço foi preenchido?
  ///
  /// O endereço é opcional (só `DELIVERY` exige um), mas é tudo ou nada:
  /// meio endereço não entrega pedido nenhum.
  bool get temEndereco => [
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    uf,
  ].any((campo) => campo.trim().isNotEmpty);

  /// O endereço para envio, ou `null` quando o bloco ficou em branco.
  ///
  /// O CEP vai só com os dígitos, pelo mesmo motivo do telefone: o hífen é
  /// máscara de tela, não parte do dado.
  ClienteEndereco? get endereco => temEndereco
      ? ClienteEndereco(
          cep: CepFormatter.somenteDigitos(cep),
          logradouro: logradouro.trim(),
          numero: numero.trim(),
          complemento: complemento.trim(),
          bairro: bairro.trim(),
          cidade: cidade.trim(),
          uf: uf.trim().toUpperCase(),
        )
      : null;

  String? get _emailOuNulo => email.trim().isEmpty ? null : email.trim();

  /// Payload de `POST /clientes`.
  ClienteCreateRequest paraCriacao() => ClienteCreateRequest(
    nome: nome.trim(),
    telefone: telefoneParaApi,
    email: _emailOuNulo,
    endereco: endereco,
  );

  /// Payload de `PUT /clientes/{id}`.
  ClienteUpdateRequest paraEdicao() => ClienteUpdateRequest(
    nome: nome.trim(),
    telefone: telefoneParaApi,
    email: _emailOuNulo,
    endereco: endereco,
    ativo: ativo,
  );
}

/// Regras de preenchimento do formulário de cliente.
///
/// Nome e telefone são obrigatórios sempre — o telefone é o identificador
/// do pedido em todos os canais (seção 3.6). O endereço é opcional, mas
/// **tudo ou nada**: começou a preencher, precisa completar, senão a
/// comanda de delivery falha na hora de entregar.
class ValidadorCliente {
  const ValidadorCliente._();

  static const nomeTamanhoMinimo = 3;

  /// Caracteres aceitos num nome de pessoa: letras (com acento), espaço,
  /// apóstrofo e hífen — o que aparece em "D'Ávila" e "Ana-Clara".
  /// Dígito em nome é quase sempre engano de digitação.
  static final nomePermitido = RegExp(r"[a-zA-ZÀ-ÿ\s'\-]");

  /// Menor quantidade de dígitos de um telefone brasileiro válido: DDD com
  /// dois dígitos mais oito do assinante (fixo).
  static const telefoneDigitosMinimo = 10;

  static String? validarNome(String? valor) {
    final nome = valor?.trim() ?? '';
    if (nome.isEmpty) return 'Informe o nome do cliente.';
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

  /// E-mail é opcional; quando informado, precisa ter cara de e-mail.
  static String? validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) return null;
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valido ? null : 'E-mail inválido.';
  }

  /// CEP é opcional; quando informado, precisa estar completo.
  ///
  /// Meio CEP não localiza endereço nenhum — é pior que campo vazio,
  /// porque parece preenchido.
  static String? validarCep(String? valor) {
    final digitos = CepFormatter.somenteDigitos(valor);
    if (digitos.isEmpty) return null;
    return digitos.length == CepFormatter.digitos
        ? null
        : 'CEP incompleto. Informe os ${CepFormatter.digitos} dígitos.';
  }

  /// UF é opcional; quando informada, precisa ser a sigla de duas letras.
  static String? validarUf(String? valor) {
    final uf = valor?.trim() ?? '';
    if (uf.isEmpty) return null;
    return RegExp(r'^[A-Za-z]{2}$').hasMatch(uf)
        ? null
        : 'UF deve ter 2 letras.';
  }

  /// Confere que o endereço iniciado está completo.
  ///
  /// Complemento e CEP ficam de fora: o primeiro nem sempre existe, e o
  /// segundo não é o que orienta o entregador até a porta.
  static String? validarEndereco(DadosCliente d) {
    if (!d.temEndereco) return null;
    if (d.logradouro.trim().isEmpty) return 'Informe o logradouro.';
    if (d.numero.trim().isEmpty) return 'Informe o número.';
    if (d.bairro.trim().isEmpty) return 'Informe o bairro.';
    if (d.cidade.trim().isEmpty) return 'Informe a cidade.';
    if (d.uf.trim().isEmpty) return 'Informe a UF.';
    return validarUf(d.uf) ?? validarCep(d.cep);
  }

  /// Primeiro problema encontrado, ou `null` quando dá para salvar.
  static String? validar(DadosCliente d) =>
      validarNome(d.nome) ??
      validarTelefone(d.telefone) ??
      validarEmail(d.email) ??
      validarEndereco(d);
}
