import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../util/rateio_formato.dart';

class RateioDivisaoRapida extends StatelessWidget {
  const RateioDivisaoRapida({
    super.key,
    required this.controller,
    required this.aoConfirmar,
  });

  final RateioController controller;
  final VoidCallback aoConfirmar;

  @override
  Widget build(BuildContext context) {
    final pessoas = controller.quantidadePessoas;
    final habilitado = !controller.executando;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const AppDica(
          'Esta comanda ainda não tem ninguém na divisão. Informe quantas '
          'pessoas vão dividir e o app cria uma comanda para cada uma.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: EstoquePalette.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EstoquePalette.border),
          ),
          child: Row(
            children: [
              _passo(Icons.remove_rounded, habilitado && pessoas > 2, -1),
              Expanded(
                child: Column(
                  children: [
                    Text('$pessoas',
                        style: const TextStyle(
                            color: EstoquePalette.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    Text('≈ ${moeda(controller.totalLiquido / pessoas)} cada',
                        style: const TextStyle(
                            color: EstoquePalette.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              _passo(Icons.add_rounded,
                  habilitado && pessoas < RateioController.maximoPessoas, 1),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: habilitado ? aoConfirmar : null,
          icon: const Icon(Icons.call_split_rounded, size: 18),
          label: Text('Dividir entre $pessoas pessoas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EstoquePalette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _passo(IconData icone, bool habilitado, int delta) => IconButton(
        onPressed:
            habilitado ? () => controller.ajustarQuantidadePessoas(delta) : null,
        icon: Icon(icone),
        color: EstoquePalette.primary,
        style: IconButton.styleFrom(
          backgroundColor: EstoquePalette.inputFill,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
