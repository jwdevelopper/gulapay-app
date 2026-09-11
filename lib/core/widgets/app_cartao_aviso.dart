import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Cartão de aviso em faixa, em três tons semânticos.
///
/// Fonte única dos avisos contextuais dos formulários. As variantes de
/// erro e de dica viviam como dois blocos `Container` idênticos copiados
/// em cada formulário — divergiam apenas no ícone e na cor da borda.
///
/// Prefira os construtores nomeados a montar a variante à mão:
///
///  * [AppCartaoAviso.erro] — resume pendências de validação da etapa.
///  * [AppCartaoAviso.dica] — explica uma consequência ou pré-condição.
///  * [AppCartaoAviso.sucesso] — confirma algo que acabou de acontecer.
///
/// ## Exemplos
///
/// ```dart
/// // Só aparece quando há mensagem — dispensa o `if` na árvore.
/// AppCartaoAviso.erro(validacao.mensagem)
///
/// const AppCartaoAviso.dica(
///   'Novo lote será criado com a validade e custo informados.',
/// )
/// ```
class AppCartaoAviso extends StatelessWidget {
  /// Texto do aviso. Quando `null`, o widget não renderiza nada — assim a
  /// tela pode passar direto uma mensagem opcional sem envolver em `if`.
  final String? mensagem;

  /// Ícone à esquerda.
  final IconData icone;

  /// Cor do ícone.
  final Color corIcone;

  /// Cor da borda — é ela que carrega o tom semântico.
  final Color corBorda;

  /// Deixa o texto em semibold. Ligado nos avisos de erro, para dar peso.
  final bool negrito;

  const AppCartaoAviso({
    super.key,
    required this.mensagem,
    required this.icone,
    required this.corIcone,
    required this.corBorda,
    this.negrito = false,
  });

  /// Aviso de erro — borda vermelha e triângulo de atenção.
  const AppCartaoAviso.erro(this.mensagem, {super.key})
    : icone = Icons.warning_amber_rounded,
      corIcone = AppTema.erro,
      corBorda = AppTema.erro,
      negrito = true;

  /// Dica informativa — borda âmbar e lâmpada.
  const AppCartaoAviso.dica(this.mensagem, {super.key})
    : icone = Icons.lightbulb_outline_rounded,
      corIcone = AppTema.primaria,
      corBorda = AppTema.avisoBorda,
      negrito = false;

  /// Confirmação — borda verde e visto.
  const AppCartaoAviso.sucesso(this.mensagem, {super.key})
    : icone = Icons.check_circle_outline_rounded,
      corIcone = AppTema.sucesso,
      corBorda = AppTema.sucesso,
      negrito = false;

  @override
  Widget build(BuildContext context) {
    if (mensagem == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTema.avisoFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corBorda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icone, color: corIcone, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem!,
              style: TextStyle(
                color: AppTema.texto,
                fontSize: 12,
                height: 1.35,
                fontWeight: negrito ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
