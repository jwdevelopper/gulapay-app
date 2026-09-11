/// Peças visuais compartilhadas entre as etapas do formulário de comanda.
///
/// Extraídas de `comanda_form_page.dart`, onde eram métodos do `State`.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/dto/opcao_escolha.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';

/// Título e subtítulo no topo de cada etapa.
class TituloEtapa extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const TituloEtapa(this.titulo, this.subtitulo, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titulo,
        style: const TextStyle(
          color: AppTema.texto,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitulo,
        style: const TextStyle(
          color: AppTema.textoSecundario,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    ],
  );
}

/// Cartão de escolha do canal de venda, com estado de selecionado animado.
class CartaoCanal extends StatelessWidget {
  final OpcaoEscolha opcao;
  final bool selecionado;
  final VoidCallback aoTocar;

  const CartaoCanal({
    super.key,
    required this.opcao,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selecionado
                ? AppTema.preenchimentoCampo
                : AppTema.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selecionado ? AppTema.primaria : AppTema.borda,
              width: selecionado ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppTema.sombraCampo,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selecionado
                      ? AppTema.primaria
                      : AppTema.preenchimentoCampo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  opcao.icone,
                  color: selecionado ? Colors.white : AppTema.primaria,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opcao.rotulo,
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      opcao.descricao,
                      style: const TextStyle(
                        color: AppTema.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selecionado
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selecionado ? AppTema.primaria : AppTema.textoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão de confirmação do cliente escolhido — nome e telefone.
class CartaoCliente extends StatelessWidget {
  final ClienteResponse cliente;

  const CartaoCliente({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) => _CartaoInfo(
    icone: Icons.person_outline_rounded,
    titulo: cliente.nome ?? 'Cliente selecionado',
    detalhe: cliente.telefone,
  );
}

/// Cartão do endereço de entrega do cliente, no canal DELIVERY.
///
/// Quando o cliente não tem endereço, avisa em tom de erro — é
/// pré-requisito que o backend exige para abrir a comanda.
class CartaoEndereco extends StatelessWidget {
  final ClienteResponse? cliente;

  const CartaoEndereco({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    final endereco = cliente?.endereco;
    if (endereco == null) {
      return const _CartaoInfo(
        icone: Icons.location_off_outlined,
        titulo: 'Cliente sem endereço cadastrado',
        detalhe: 'Cadastre um endereço para abrir uma comanda de delivery.',
        alerta: true,
      );
    }

    final linha = [
      endereco.logradouro,
      endereco.numero,
      endereco.bairro,
    ].where((p) => (p ?? '').isNotEmpty).join(', ');

    return _CartaoInfo(
      icone: Icons.location_on_outlined,
      titulo: linha.isEmpty ? 'Endereço cadastrado' : linha,
      detalhe: [
        endereco.cidade,
        endereco.uf,
      ].where((p) => (p ?? '').isNotEmpty).join(' · '),
    );
  }
}

/// Base dos dois cartões acima: ícone à esquerda, título e detalhe.
class _CartaoInfo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? detalhe;
  final bool alerta;

  const _CartaoInfo({
    required this.icone,
    required this.titulo,
    this.detalhe,
    this.alerta = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = alerta ? AppTema.erro : AppTema.primaria;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alerta ? AppTema.erro : AppTema.borda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppTema.texto,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if ((detalhe ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    detalhe!,
                    style: const TextStyle(
                      color: AppTema.textoSecundario,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
