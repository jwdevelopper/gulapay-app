import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Campo da tela de login.
///
/// Tem moldura própria — arredondada, clara e sem borda em repouso — porque
/// fica sobre a foto de fundo, onde a moldura padrão dos formulários
/// (superfície clara sobre fundo claro) sumiria.
///
/// Recebe os ícones como widget, e não como `IconData`, para aceitar tanto
/// `Icon` quanto `FaIcon` — o Font Awesome usa um tipo de dado próprio.
class CampoLogin extends StatelessWidget {
  final TextEditingController controle;

  /// Texto exibido enquanto o campo está vazio.
  final String dica;

  /// Ícone à esquerda, identificando o campo.
  final Widget icone;

  /// Esconde o que é digitado.
  final bool ocultarTexto;

  /// Ícone do botão à direita. Sem ele o campo não desenha ação.
  final Widget? iconeAcao;

  /// Ação do botão à direita (limpar o campo, mostrar a senha).
  final VoidCallback? aoTocarAcao;

  /// Descrição do botão de ação, para leitores de tela.
  final String? dicaAcao;

  /// Enviar do teclado.
  final VoidCallback? aoEnviar;

  const CampoLogin({
    super.key,
    required this.controle,
    required this.dica,
    required this.icone,
    this.ocultarTexto = false,
    this.iconeAcao,
    this.aoTocarAcao,
    this.dicaAcao,
    this.aoEnviar,
  });

  /// Creme translúcido: legível sobre a foto de fundo sem escondê-la.
  static const _fundo = Color(0xF2FFF5DC);

  @override
  Widget build(BuildContext context) => TextField(
    controller: controle,
    obscureText: ocultarTexto,
    onSubmitted: aoEnviar == null ? null : (_) => aoEnviar!(),
    style: const TextStyle(color: AppTema.texto),
    decoration: InputDecoration(
      filled: true,
      fillColor: _fundo,
      hintText: dica,
      hintStyle: const TextStyle(color: AppTema.textoSecundario),
      border: _moldura(),
      enabledBorder: _moldura(),
      focusedBorder: _moldura(cor: AppTema.primaria),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: icone,
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: iconeAcao == null
          ? null
          : IconButton(
              tooltip: dicaAcao,
              onPressed: aoTocarAcao,
              icon: iconeAcao!,
            ),
    ),
  );

  OutlineInputBorder _moldura({Color? cor}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: cor == null ? BorderSide.none : BorderSide(color: cor),
  );
}
