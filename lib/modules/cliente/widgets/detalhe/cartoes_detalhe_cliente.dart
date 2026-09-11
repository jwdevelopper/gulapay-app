/// Peças da tela de detalhe do cliente.
///
///  * [PerfilCliente] — avatar, nome, e-mail e a etiqueta de situação;
///  * [ContatoCliente] — WhatsApp e e-mail, com o WhatsApp acionável;
///  * [EnderecoDoCliente] — o endereço montado em linhas legíveis.
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_endereco.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';

/// Cabeçalho do detalhe: quem é o cliente e se está ativo.
class PerfilCliente extends StatelessWidget {
  final ClienteResponse cliente;

  const PerfilCliente({super.key, required this.cliente});

  bool get _ativo => cliente.ativo ?? true;

  String get _inicial {
    final nome = cliente.nome?.trim() ?? '';
    return nome.isEmpty ? '?' : nome.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => _Moldura(
    recuo: const EdgeInsets.all(20),
    filho: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTema.avisoFundo,
          child: Text(
            _inicial,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTema.primaria,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cliente.nome ?? 'Sem nome',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTema.texto,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cliente.email ?? 'E-mail não informado',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTema.textoSecundario,
                ),
              ),
              const SizedBox(height: 6),
              _ativo
                  ? const AppTag(
                      'Ativo',
                      fundo: AppTema.sucessoFundo,
                      cor: AppTema.sucesso,
                    )
                  : const AppTag(
                      'Inativo',
                      fundo: AppTema.erroFundo,
                      cor: AppTema.erro,
                    ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Formas de falar com o cliente.
///
/// A linha do WhatsApp é acionável quando há telefone: é por ela que o
/// atendente confirma o pedido (RF22), e ter o número na tela sem poder
/// tocar obrigava a copiar à mão.
class ContatoCliente extends StatelessWidget {
  final ClienteResponse cliente;

  /// Abre a conversa. Nulo deixa a linha apenas informativa.
  final VoidCallback? aoAbrirWhatsApp;

  const ContatoCliente({
    super.key,
    required this.cliente,
    this.aoAbrirWhatsApp,
  });

  bool get _temTelefone => (cliente.telefone ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) => _Moldura(
    filho: Column(
      children: [
        _Linha(
          icone: const FaIcon(
            FontAwesomeIcons.whatsapp,
            size: 16,
            color: AppTema.sucesso,
          ),
          rotulo: 'WhatsApp',
          valor: _temTelefone
              ? TelefoneFormatter.formatar(cliente.telefone)
              : 'Não informado',
          aoTocar: _temTelefone ? aoAbrirWhatsApp : null,
        ),
        if ((cliente.email ?? '').isNotEmpty) ...[
          const Divider(height: 1, color: AppTema.borda),
          _Linha(
            icone: const FaIcon(
              FontAwesomeIcons.envelope,
              size: 16,
              color: AppTema.primariaEscura,
            ),
            rotulo: 'E-mail',
            valor: cliente.email!,
          ),
        ],
      ],
    ),
  );
}

/// Endereço do cliente, montado em linhas legíveis.
///
/// Cada linha só aparece se tiver conteúdo — endereço parcial é comum em
/// cliente que só compra no balcão.
class EnderecoDoCliente extends StatelessWidget {
  final ClienteEndereco endereco;

  const EnderecoDoCliente({super.key, required this.endereco});

  /// As linhas do endereço, na ordem de um envelope.
  List<String> get linhas {
    final numero = (endereco.numero ?? '').isEmpty
        ? ''
        : ', ${endereco.numero}';
    final uf = (endereco.uf ?? '').isEmpty ? '' : ' - ${endereco.uf}';
    return [
      if ((endereco.logradouro ?? '').isNotEmpty)
        '${endereco.logradouro}$numero',
      if ((endereco.complemento ?? '').isNotEmpty) endereco.complemento!,
      if ((endereco.bairro ?? '').isNotEmpty) endereco.bairro!,
      if ((endereco.cidade ?? '').isNotEmpty) '${endereco.cidade}$uf',
      if ((endereco.cep ?? '').isNotEmpty) 'CEP ${endereco.cep}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = linhas;
    if (conteudo.isEmpty) return const SizedBox.shrink();

    return _Moldura(
      recuo: const EdgeInsets.all(16),
      filho: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FaIcon(
            FontAwesomeIcons.locationDot,
            size: 16,
            color: AppTema.primariaEscura,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endereço',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTema.textoSecundario,
                  ),
                ),
                const SizedBox(height: 4),
                for (final linha in conteudo)
                  Text(linha, style: const TextStyle(color: AppTema.texto)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão branco com borda — a moldura comum dos três blocos.
class _Moldura extends StatelessWidget {
  final Widget filho;
  final EdgeInsets? recuo;

  const _Moldura({required this.filho, this.recuo});

  @override
  Widget build(BuildContext context) => Container(
    padding: recuo,
    decoration: BoxDecoration(
      color: AppTema.superficie,
      border: Border.all(color: AppTema.borda),
      borderRadius: BorderRadius.circular(12),
    ),
    child: filho,
  );
}

/// Linha "ícone → rótulo → valor" do cartão de contato.
class _Linha extends StatelessWidget {
  final Widget icone;
  final String rotulo;
  final String valor;
  final VoidCallback? aoTocar;

  const _Linha({
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.aoTocar,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: aoTocar,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          icone,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTema.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTema.texto,
                  ),
                ),
              ],
            ),
          ),
          if (aoTocar != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTema.textoSecundario,
            ),
        ],
      ),
    ),
  );
}
