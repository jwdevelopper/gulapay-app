import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widget/table_status_badge.dart';

class PainelInformacoesMesa extends StatelessWidget {
  const PainelInformacoesMesa({
    super.key,
    required this.nomeArea,
    required this.mesa,
    required this.situacao,
    required this.mesasDoContexto,
    required this.totalCadeiras,
    required this.pessoasSentadas,
    required this.quantidadeItens,
    required this.totalParcial,
    required this.ultimoPedidoEm,
    required this.nomeCliente,
    required this.mesasCompativeis,
    required this.aoAbrirComanda,
    required this.aoEditar,
    required this.aoLiberar,
    required this.aoUnirCom,
    this.aoSepararGrupo,
  });

  final String nomeArea;
  final MesaRestaurante mesa;
  final SituacaoMesa situacao;
  final List<MesaRestaurante> mesasDoContexto;
  final int totalCadeiras;
  final int pessoasSentadas;
  final int quantidadeItens;
  final double totalParcial;
  final DateTime? ultimoPedidoEm;
  final String? nomeCliente;
  final List<MesaRestaurante> mesasCompativeis;
  final VoidCallback aoAbrirComanda;
  final VoidCallback aoEditar;
  final VoidCallback aoLiberar;
  final ValueChanged<String> aoUnirCom;
  final VoidCallback? aoSepararGrupo;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final temComandaAtiva = mesasDoContexto.any(
      (item) => item.idComandaAtiva != null,
    );

    return Container(
      decoration: const BoxDecoration(
        color: GulaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 22 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: GulaColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mesa.codigo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nomeArea,
                        style: const TextStyle(
                          color: GulaColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IndicadorSituacaoMesa(situacao: situacao),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CartaoInformacao(
                  rotulo: 'Capacidade',
                  valor: '$totalCadeiras lugares',
                ),
                _CartaoInformacao(
                  rotulo: 'Pessoas',
                  valor: '$pessoasSentadas sentadas',
                ),
                _CartaoInformacao(
                  rotulo: 'Itens',
                  valor: '$quantidadeItens em aberto',
                ),
                _CartaoInformacao(
                  rotulo: 'Parcial',
                  valor: 'R\$ ${totalParcial.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CartaoInformacao(
              rotulo: 'Ultimo movimento',
              valor: _formatarUltimoEvento(ultimoPedidoEm),
              larguraTotal: true,
            ),
            const SizedBox(height: 12),
            _CartaoInformacao(
              rotulo: 'Cliente',
              valor: nomeCliente ?? 'Nao informado',
              larguraTotal: true,
            ),
            if (mesasDoContexto.length > 1) ...[
              const SizedBox(height: 12),
              _CartaoInformacao(
                rotulo: 'Mesas no grupo',
                valor: mesasDoContexto.map((item) => item.codigo).join(', '),
                larguraTotal: true,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: aoAbrirComanda,
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(temComandaAtiva ? 'Ver comanda' : 'Abrir pedido'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: aoEditar,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: aoLiberar,
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: const Text('Liberar'),
                  ),
                ),
              ],
            ),
            if (mesasCompativeis.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Unir com outra mesa da area',
                style: TextStyle(
                  color: GulaColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mesasCompativeis
                    .map(
                      (candidata) => ActionChip(
                        label: Text(candidata.codigo),
                        onPressed: () => aoUnirCom(candidata.id),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (aoSepararGrupo != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: aoSepararGrupo,
                  icon: const Icon(Icons.call_split_outlined),
                  label: const Text('Desfazer mistura'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarUltimoEvento(DateTime? value) {
    if (value == null) {
      return 'Sem historico recente';
    }

    final tempoDecorrido = DateTime.now().difference(value);
    if (tempoDecorrido.inMinutes < 1) {
      return 'Agora mesmo';
    }
    if (tempoDecorrido.inMinutes < 60) {
      return '${tempoDecorrido.inMinutes} min atras';
    }
    return '${tempoDecorrido.inHours} h atras';
  }
}

class _CartaoInformacao extends StatelessWidget {
  const _CartaoInformacao({
    required this.rotulo,
    required this.valor,
    this.larguraTotal = false,
  });

  final String rotulo;
  final String valor;
  final bool larguraTotal;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GulaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              color: GulaColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (larguraTotal) {
      return SizedBox(width: double.infinity, child: child);
    }

    return SizedBox(width: 150, child: child);
  }
}
