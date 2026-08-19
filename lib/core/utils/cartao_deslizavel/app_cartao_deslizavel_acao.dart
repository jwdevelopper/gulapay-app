import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Configuração visual da ação revelada ao deslizar um cartão para a esquerda.
///
/// Permite reutilizar a mesma animação para ações destrutivas ou de status sem
/// acoplar o componente ao módulo que o consome.
class AppCartaoDeslizavelAcao {
  const AppCartaoDeslizavelAcao({
    required this.rotulo,
    required this.cor,
    this.icone,
    this.iconePersonalizado,
    this.corProfunda,
  }) : assert(icone != null || iconePersonalizado != null);

  const AppCartaoDeslizavelAcao.excluir({
    this.rotulo = 'Excluir',
    this.cor = const Color(0xFFE53935),
    this.corProfunda = const Color(0xFFB71C1C),
    this.iconePersonalizado = const FaIcon(
      FontAwesomeIcons.trashCan,
      color: Colors.white,
      size: 16,
    ),
  }) : icone = null;

  final String rotulo;
  final Color cor;
  final IconData? icone;
  final Widget? iconePersonalizado;
  final Color? corProfunda;

  Color get corProfundaResolvida =>
      corProfunda ?? Color.lerp(cor, Colors.black, 0.35)!;
}
