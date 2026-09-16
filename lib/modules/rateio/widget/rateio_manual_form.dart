import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../dto/rateio_comanda_response.dart';
import '../util/rateio_formato.dart';
import 'rateio_status_box.dart';

class RateioManualForm extends StatelessWidget {
  const RateioManualForm({super.key, required this.controller});

  final RateioController controller;

  static final List<TextInputFormatter> _formatadores = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
    TextInputFormatter.withFunction((antigo, novo) =>
        RegExp(r'^\d*,?\d{0,2}$').hasMatch(novo.text) ? novo : antigo),
  ];

  @override
  Widget build(BuildContext context) {
    final participantes = controller.selecionados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDica(
          'Digite quanto cada participante paga. Use o botão ao lado do '
          'campo pra preencher com o valor que falta pra fechar o total.',
        ),
        const SizedBox(height: 12),
        if (participantes.isEmpty)
          const Text(
            'Marque ao menos 1 participante acima para informar os valores.',
            style: TextStyle(color: EstoquePalette.textMuted, fontSize: 12),
          )
        else ...[
          ...participantes.map((p) => _linha(context, p)),
          const SizedBox(height: 4),
          _resumoSoma(),
        ],
      ],
    );
  }

  Widget _linha(BuildContext context, RateioParticipanteResponse p) {
    final id = p.comandaIndividualId;
    final restante = controller.restanteCentavosPara(id);
    final podePreencher = !controller.executando && restante >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: EstoquePalette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: EstoquePalette.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.nomeDe(p),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: EstoquePalette.text)),
                  const SizedBox(height: 2),
                  Text('${p.codigo} · itens próprios ${moeda(p.valorProprio)}',
                      style: const TextStyle(
                          color: EstoquePalette.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              child: AppCampoTexto(
                controle: controller.controladorValor(id),
                dica: '0,00',
                tipoTeclado:
                    const TextInputType.numberWithOptions(decimal: true),
                formatadores: _formatadores,
                habilitado: !controller.executando,
                aoMudar: (_) => controller.valorDigitado(),
                prefixo: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 4),
                  child: Center(
                    widthFactor: 1,
                    child: Text('R\$',
                        style: TextStyle(
                            color: EstoquePalette.textMuted,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                sufixo: IconButton(
                  tooltip: podePreencher
                      ? 'Preencher restante (${moedaCentavos(restante)})'
                      : 'Os outros valores já passam do total',
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 20),
                  color: EstoquePalette.primary,
                  onPressed:
                      podePreencher ? () => controller.preencherRestante(id) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumoSoma() {
    final soma = controller.somaManualCentavos;
    final diferenca = controller.totalCentavos - soma;

    return RateioStatusBox(
      ok: diferenca == 0,
      titulo:
          'Total: ${moedaCentavos(soma)} / ${moedaCentavos(controller.totalCentavos)}',
      detalhe: switch (diferenca) {
        0 => 'A soma fecha com o total da comanda.',
        > 0 => 'Faltam ${moedaCentavos(diferenca)}',
        _ => 'Sobram ${moedaCentavos(-diferenca)}',
      },
    );
  }
}
