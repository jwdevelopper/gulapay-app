import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';

class RateioParticipantesLista extends StatelessWidget {
  const RateioParticipantesLista({
    super.key,
    required this.controller,
    required this.aoAdicionarPessoa,
    required this.aoSalvar,
  });

  final RateioController controller;
  final VoidCallback aoAdicionarPessoa;
  final VoidCallback aoSalvar;

  @override
  Widget build(BuildContext context) {
    final habilitado = !controller.executando;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...controller.participantes.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: EstoquePalette.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: EstoquePalette.borderSoft),
              ),
              child: CheckboxListTile(
                value: controller.marcado(p.comandaIndividualId),
                onChanged: habilitado
                    ? (_) => controller
                        .alternarParticipante(p.comandaIndividualId)
                    : null,
                activeColor: EstoquePalette.primary,
                title: Text(controller.nomeDe(p),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: EstoquePalette.text)),
                subtitle: Text(
                  '${p.codigo} · itens próprios ${moeda(p.valorProprio)}',
                  style: const TextStyle(
                      color: EstoquePalette.textMuted, fontSize: 12),
                ),
              ),
            )),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: habilitado ? aoAdicionarPessoa : null,
            icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
            label: const Text('Adicionar pessoa'),
            style:
                TextButton.styleFrom(foregroundColor: EstoquePalette.primary),
          ),
        ),
        if (controller.mudouParticipantes) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: habilitado ? aoSalvar : null,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Salvar participantes'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EstoquePalette.primary,
              side: const BorderSide(color: EstoquePalette.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }
}
