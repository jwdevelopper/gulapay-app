import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

class AppBarraAcoes extends StatelessWidget {
  final String textoConfirmar;
  final Widget? iconeConfirmar;
  final VoidCallback? aoCancelar;
  final VoidCallback? aoConfirmar;
  final bool carregando;
  final String textoCancelar;

  const AppBarraAcoes({
    super.key,
    required this.textoConfirmar,
    this.aoCancelar,
    this.aoConfirmar,
    this.iconeConfirmar,
    this.carregando = false,
    this.textoCancelar = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTema.fundo,
        border: Border(top: BorderSide(color: AppTema.bordaCampo)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: carregando ? null : aoCancelar,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTema.cartao,
                foregroundColor: AppTema.textoEscuro,
                side: const BorderSide(color: AppTema.bordaCampo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(textoCancelar,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: carregando ? null : aoConfirmar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTema.primaria,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: carregando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textoConfirmar,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        if (iconeConfirmar != null) ...[
                          const SizedBox(width: 8),
                          iconeConfirmar!,
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
