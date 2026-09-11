import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Indicador de carregamento do app.
///
/// Fonte única do "aguarde". Substituiu o `CircularProgressIndicator`
/// instanciado à mão em 21 arquivos, onde metade esquecia de passar a cor
/// e herdava o azul do `ColorScheme` global.
///
/// ## Exemplos
///
/// Centralizado, enquanto a listagem carrega:
///
/// ```dart
/// if (_carregando) return const AppCarregando();
/// ```
///
/// Com mensagem, em carga demorada:
///
/// ```dart
/// const AppCarregando(mensagem: 'Carregando lotes...')
/// ```
///
/// Dentro de um botão (veja também [AppCarregando.emBotao]):
///
/// ```dart
/// child: _salvando ? const AppCarregando.emBotao() : const Text('Salvar')
/// ```
class AppCarregando extends StatelessWidget {
  /// Texto opcional abaixo do indicador. Use quando a espera passa de
  /// alguns segundos e vale explicar o que está acontecendo.
  final String? mensagem;

  /// Diâmetro do indicador.
  final double tamanho;

  /// Espessura do traço.
  final double espessura;

  /// Cor do traço. O padrão é [AppTema.primaria]; use branco quando o
  /// indicador estiver sobre um fundo preenchido (botão primário).
  final Color cor;

  /// Centraliza o conteúdo no espaço disponível. Desligue quando o
  /// indicador já estiver dentro de um contêiner dimensionado.
  final bool centralizado;

  const AppCarregando({
    super.key,
    this.mensagem,
    this.tamanho = 32,
    this.espessura = 3,
    this.cor = AppTema.primaria,
    this.centralizado = true,
  });

  /// Variante compacta para dentro de botões: 18px, traço fino e branco,
  /// sem centralização (o botão já centraliza o filho).
  const AppCarregando.emBotao({super.key})
    : mensagem = null,
      tamanho = 18,
      espessura = 2,
      cor = Colors.white,
      centralizado = false;

  @override
  Widget build(BuildContext context) {
    final indicador = SizedBox(
      width: tamanho,
      height: tamanho,
      child: CircularProgressIndicator(strokeWidth: espessura, color: cor),
    );

    if (mensagem == null) {
      return centralizado ? Center(child: indicador) : indicador;
    }

    final conteudo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicador,
        const SizedBox(height: 14),
        Text(
          mensagem!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTema.textoSecundario,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return centralizado ? Center(child: conteudo) : conteudo;
  }
}
