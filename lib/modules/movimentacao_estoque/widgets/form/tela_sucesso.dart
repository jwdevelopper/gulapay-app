import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/validacao_movimentacao.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/form/resumo_movimentacao.dart';

/// Tela exibida após o registro bem-sucedido da movimentação.
class TelaSucessoMovimentacao extends StatelessWidget {
  final DadosMovimentacao dados;
  final VoidCallback aoConcluir;

  const TelaSucessoMovimentacao({
    super.key,
    required this.dados,
    required this.aoConcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTema.primaria,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Movimentação registrada!',
                style: TextStyle(
                  color: AppTema.texto,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ResumoMovimentacao(dados: dados),
              const Spacer(),
              SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: aoConcluir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTema.primaria,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTema.primariaPressionada.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Concluído'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
