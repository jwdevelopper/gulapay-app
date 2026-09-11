import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_botao_icone.dart';

/// Cabeçalho do formulário: botão voltar, título contextual, indicação da
/// etapa e a barra de progresso.
class AppCabecalhoWizard extends StatelessWidget {
  final String titulo;
  final int etapa;
  final int totalEtapas;
  final String rotuloEtapa;
  final VoidCallback aoVoltar;

  const AppCabecalhoWizard({
    super.key,
    required this.titulo,
    required this.etapa,
    required this.rotuloEtapa,
    required this.aoVoltar,
    this.totalEtapas = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBotaoIcone(icone: Icons.arrow_back_rounded, aoTocar: aoVoltar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Etapa ${etapa + 1} de $totalEtapas · $rotuloEtapa',
                      style: const TextStyle(
                        color: AppTema.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              totalEtapas,
              (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == totalEtapas - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: i <= etapa ? AppTema.primaria : AppTema.bordaSuave,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
