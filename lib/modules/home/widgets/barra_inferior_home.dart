import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/barra_navegacao_curvada.dart';
import 'package:my_app_teste/modules/home/dto/aba_principal.dart';

/// Barra inferior curvada da [Home].
///
/// Usa o [BarraNavegacaoCurvada] — a versão própria, escrita porque o
/// pacote original congela a quantidade de itens na primeira montagem e
/// não aceita um segundo entalhe. Aqui os dois são necessários: a barra
/// muda de itens conforme a aba aberta, e o `+` precisa do seu próprio
/// entalhe no canto.
///
/// ## O `+`
///
/// Só aparece quando a aba aberta tem cadastro. A ação vem do registro
/// global `AcoesCriacao`, preenchido por cada listagem no `initState` — é
/// o que permite o botão da barra abrir o formulário da tela certa sem que
/// a [Home] conheça nenhuma delas.
class BarraInferiorHome extends StatelessWidget {
  /// Os itens exibidos, já na ordem final. Quando a aba aberta tem
  /// cadastro, ela vem no centro.
  final List<AbaPrincipal> itens;

  /// A aba aberta — recebe a bolha da curva.
  final AbaPrincipal abaAtual;

  /// Chamado com o índice tocado, dentro de [itens].
  final ValueChanged<int> aoTocarAba;

  /// Ação do `+`. Nulo esconde o botão.
  final VoidCallback? aoTocarAdicionar;

  const BarraInferiorHome({
    super.key,
    required this.itens,
    required this.abaAtual,
    required this.aoTocarAba,
    required this.aoTocarAdicionar,
  });

  @override
  Widget build(BuildContext context) => BarraNavegacaoCurvada(
    altura: 65,
    indice: itens.indexOf(abaAtual),
    corFundo: AppTema.fundo,
    cor: Color.lerp(AppTema.fundo, Colors.black, 0.08)!,
    corBotao: AppTema.primaria,
    duracaoAnimacao: const Duration(milliseconds: 300),
    curvaAnimacao: Curves.easeInOut,
    itens: [
      for (final aba in itens)
        Icon(
          aba.icone,
          size: 30,
          color: aba == abaAtual ? Colors.white : AppTema.textoSecundario,
        ),
    ],
    aoTocar: aoTocarAba,
    acaoFinal: aoTocarAdicionar == null
        ? null
        : const Icon(Icons.add_rounded, size: 30, color: Colors.white),
    aoTocarAcaoFinal: aoTocarAdicionar,
  );
}
