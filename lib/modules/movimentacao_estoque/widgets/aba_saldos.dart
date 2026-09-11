import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/insumo.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/insumo_saldo_card.dart';

/// Aba de saldos do estoque — insumos em duas seções, os abaixo do mínimo
/// primeiro.
///
/// Extraída de `estoque_page.dart`. Recebe a lista já filtrada pela busca e
/// faz apenas a separação por situação de estoque.
class AbaSaldos extends StatelessWidget {
  /// Insumos visíveis, já filtrados pela busca da tela.
  final List<Insumo> insumos;

  /// Há busca ativa? Esconde o aviso de estoque mínimo, que só faz sentido
  /// na visão completa.
  final bool buscaAtiva;

  final bool carregando;

  /// Abre o formulário de entrada a partir de um insumo em falta.
  final VoidCallback aoRegistrarEntrada;

  const AbaSaldos({
    super.key,
    required this.insumos,
    required this.buscaAtiva,
    required this.carregando,
    required this.aoRegistrarEntrada,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) return const AppCarregando();

    final abaixo = insumos.where((i) => i.abaixoDoMinimo == true).toList();
    final emEstoque = insumos.where((i) => i.abaixoDoMinimo != true).toList();

    if (abaixo.isEmpty && emEstoque.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 96),
        children: [
          AppEstadoVazio(
            icone: buscaAtiva
                ? Icons.search_off_rounded
                : Icons.inventory_2_outlined,
            mensagem: buscaAtiva
                ? 'Nenhum insumo encontrado para a busca.'
                : 'Nenhum insumo cadastrado.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (abaixo.isNotEmpty && !buscaAtiva) ...[
          AppCartaoAviso.dica(_avisoEstoqueMinimo(abaixo.length)),
          const SizedBox(height: 16),
        ],
        if (abaixo.isNotEmpty) ...[
          const _TituloSecao('ABAIXO DO MÍNIMO'),
          for (final insumo in abaixo)
            _cartao(insumo, aoTocar: aoRegistrarEntrada),
          const SizedBox(height: 8),
        ],
        if (emEstoque.isNotEmpty) ...[
          const _TituloSecao('EM ESTOQUE'),
          for (final insumo in emEstoque) _cartao(insumo),
        ],
      ],
    );
  }

  String _avisoEstoqueMinimo(int quantidade) {
    final sujeito = quantidade == 1
        ? '1 insumo abaixo'
        : '$quantidade insumos abaixo';
    return '$sujeito do estoque mínimo.\n'
        'Toque no insumo para registrar entrada por compra.';
  }

  Widget _cartao(Insumo insumo, {VoidCallback? aoTocar}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InsumoSaldoCard(
      nome: insumo.nome,
      estoqueMinimo: insumo.estoqueMinimo,
      estoqueAtual: insumo.estoqueAtual,
      unidadeSimbolo: insumo.unidadePadraoSimbolo,
      percentAbaixo: insumo.percentAbaixo,
      onTap: aoTocar,
    ),
  );
}

class _TituloSecao extends StatelessWidget {
  final String texto;

  const _TituloSecao(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      texto,
      style: const TextStyle(
        color: AppTema.textoSecundario,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}
