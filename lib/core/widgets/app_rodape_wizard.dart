import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Par de botões fixos no rodapé do formulário (voltar/avançar).
class AppRodapeWizard extends StatelessWidget {
  final String rotuloEsquerda;
  final String rotuloDireita;
  final IconData iconeDireita;
  final bool carregando;
  final VoidCallback aoVoltar;
  final VoidCallback aoAvancar;

  const AppRodapeWizard({
    super.key,
    required this.rotuloEsquerda,
    required this.rotuloDireita,
    required this.iconeDireita,
    required this.aoVoltar,
    required this.aoAvancar,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: aoVoltar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTema.texto,
                  backgroundColor: AppTema.superficieAlt,
                  side: const BorderSide(color: AppTema.borda),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(rotuloEsquerda),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: carregando ? null : aoAvancar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTema.primaria,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTema.primariaSuave.withValues(
                    alpha: 0.55,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                  elevation: 4,
                  shadowColor: AppTema.primariaPressionada.withValues(
                    alpha: 0.35,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: carregando
                    ? const AppCarregando.emBotao()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(rotuloDireita),
                          const SizedBox(width: 8),
                          Icon(iconeDireita, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
