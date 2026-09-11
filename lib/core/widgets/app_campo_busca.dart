import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';

/// Campo de busca padrão das listagens.
///
/// Fonte única do "buscar" no app. Substituiu quatro implementações que
/// existiam separadas — `ProdutoSearchField`, `InsumoSearchField`,
/// `EntregadorSearchField` e a versão anterior deste arquivo — todas com a
/// mesma assinatura, divergindo só no texto da dica. Duas delas ainda
/// puxavam cor de `Theme.of(context)`, que no app resolve para o azul do
/// `seedColor` e destoava do laranja das irmãs.
///
/// O botão de limpar aparece sozinho quando há texto digitado. Se
/// [aoLimpar] não for informado, o próprio widget limpa o controlador e
/// notifica [aoMudar] com string vazia — que é o comportamento desejado na
/// maioria das telas.
///
/// Exemplo em uma listagem:
///
/// ```dart
/// AppCampoBusca(
///   controle: _controladorBusca,
///   dica: 'Buscar produto...',
///   margemHorizontal: 16,
///   aoMudar: (texto) => setState(() => _busca = texto),
/// )
/// ```
///
/// Veja também:
///  * [AppCampoTexto], para entrada de texto comum em formulários.
class AppCampoBusca extends StatelessWidget {
  /// Controlador do texto digitado. A visibilidade do botão de limpar é
  /// derivada dele, então a tela precisa reconstruir a cada digitação
  /// (o que já acontece ao tratar [aoMudar] com `setState`).
  final TextEditingController controle;

  /// Texto exibido enquanto o campo está vazio. Prefira algo específico
  /// da listagem ("Buscar insumo...") a um genérico.
  final String dica;

  /// Chamado a cada alteração, inclusive ao limpar o campo.
  final ValueChanged<String> aoMudar;

  /// Ação do botão de limpar. Quando `null`, limpa [controle] e dispara
  /// `aoMudar('')`.
  final VoidCallback? aoLimpar;

  /// Margem lateral aplicada ao redor do campo. Fica em zero por padrão
  /// para que a tela controle o próprio espaçamento; as listagens que
  /// desenham o campo direto sobre o fundo costumam usar `16`.
  final double margemHorizontal;

  /// Ação do teclado. `TextInputAction.search` é o padrão em buscas.
  final TextInputAction acaoTeclado;

  const AppCampoBusca({
    super.key,
    required this.controle,
    required this.aoMudar,
    this.dica = 'Buscar...',
    this.aoLimpar,
    this.margemHorizontal = 0,
    this.acaoTeclado = TextInputAction.search,
  });

  void _limpar() {
    if (aoLimpar != null) {
      aoLimpar!();
      return;
    }
    controle.clear();
    aoMudar('');
  }

  @override
  Widget build(BuildContext context) {
    final temTexto = controle.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: margemHorizontal),
      child: Container(
        decoration: DecoracoesApp.campo(),
        child: TextField(
          controller: controle,
          onChanged: aoMudar,
          textInputAction: acaoTeclado,
          style: const TextStyle(
            color: AppTema.texto,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(color: AppTema.textoSecundario),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTema.textoSecundario,
            ),
            suffixIcon: temTexto
                ? IconButton(
                    onPressed: _limpar,
                    splashRadius: 18,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppTema.textoSecundario,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
