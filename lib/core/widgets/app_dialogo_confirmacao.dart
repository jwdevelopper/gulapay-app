import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Tom semântico do botão de confirmação.
///
/// Define a cor do botão e o ícone padrão do título.
enum TomConfirmacao {
  /// Laranja da marca, triângulo de atenção. Para decisões sem carga —
  /// sair da sessão, descartar rascunho.
  neutro,

  /// Vermelho, triângulo de atenção. Para exclusões e inativações.
  destrutivo,

  /// Verde, visto. Para reativações e confirmações que restauram algo.
  positivo,
}

/// Diálogo de confirmação padrão do app.
///
/// Fonte única do "tem certeza?". Substituiu o `AlertDialog` montado à mão
/// em 11 telas, que repetiam a mesma estrutura (ícone no título, botão de
/// cancelar discreto, botão de confirmar em destaque) com divergências de
/// cor, raio e rótulo — inclusive um que usava a paleta antiga do módulo
/// de mesas.
///
/// Devolve `true` se o usuário confirmou; `false` se cancelou; `null` se
/// dispensou tocando fora. Por isso **compare sempre com `== true`**:
///
/// ```dart
/// if (confirmou != true) return;
/// ```
///
/// Não use para diálogos que contêm formulário (campo de texto, dropdown
/// de motivo) — esses precisam de `StatefulBuilder` e estado próprio.
/// Este componente cobre apenas a pergunta binária.
///
/// ## Exemplos
///
/// Exclusão — prefira o atalho [exclusao], que já aplica o tom destrutivo
/// e anexa o aviso de irreversibilidade:
///
/// ```dart
/// final confirmou = await AppDialogoConfirmacao.exclusao(
///   context,
///   titulo: 'Excluir usuário',
///   mensagem: 'Deseja realmente excluir "${usuario.nome}"?',
/// );
/// if (confirmou != true) return;
/// await _servico.excluir(usuario.id!);
/// ```
///
/// Inativação (destrutiva, mas reversível — sem o aviso do [exclusao]):
///
/// ```dart
/// await AppDialogoConfirmacao.mostrar(
///   context,
///   titulo: 'Inativar categoria',
///   mensagem: 'Deseja inativar "${categoria.nome}"?',
///   rotuloConfirmar: 'Inativar',
///   tom: TomConfirmacao.destrutivo,
/// );
/// ```
///
/// Reativação:
///
/// ```dart
/// await AppDialogoConfirmacao.mostrar(
///   context,
///   titulo: 'Reativar cliente',
///   mensagem: 'Deseja reativar "${cliente.nome}"?',
///   rotuloConfirmar: 'Reativar',
///   tom: TomConfirmacao.positivo,
/// );
/// ```
///
/// Decisão neutra:
///
/// ```dart
/// final sair = await AppDialogoConfirmacao.mostrar(
///   context,
///   titulo: 'Sair',
///   mensagem: 'Deseja encerrar a sessão?',
///   rotuloConfirmar: 'Sair',
/// );
/// ```
class AppDialogoConfirmacao {
  const AppDialogoConfirmacao._();

  /// Abre o diálogo e resolve com a escolha do usuário.
  ///
  /// [tom] define a cor do botão de confirmar e o ícone padrão do título —
  /// veja [TomConfirmacao]. [icone] sobrescreve o ícone do tom quando a
  /// tela quiser algo mais específico.
  ///
  /// [barrierDismissible] fica `true` para confirmações comuns; passe
  /// `false` quando a decisão não puder ser adiada por um toque acidental.
  static Future<bool?> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Confirmar',
    String rotuloCancelar = 'Cancelar',
    TomConfirmacao tom = TomConfirmacao.neutro,
    IconData? icone,
    bool barrierDismissible = true,
  }) {
    final cor = _corDo(tom);

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTema.superficie,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            _iconeDo(tom, icone, cor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppTema.texto,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensagem,
          style: const TextStyle(color: AppTema.texto, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppTema.textoSecundario,
            ),
            child: Text(rotuloCancelar),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(rotuloConfirmar),
          ),
        ],
      ),
    );
  }

  /// Atalho para exclusões: tom destrutivo, rótulo "Excluir" e o aviso de
  /// que a ação não pode ser desfeita anexado à [mensagem].
  ///
  /// Para inativações (que são reversíveis) use [mostrar] com
  /// [TomConfirmacao.destrutivo], sem o aviso.
  static Future<bool?> exclusao(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Excluir',
  }) {
    return mostrar(
      context,
      titulo: titulo,
      mensagem: '$mensagem Esta ação não pode ser desfeita.',
      rotuloConfirmar: rotuloConfirmar,
      tom: TomConfirmacao.destrutivo,
    );
  }

  static Color _corDo(TomConfirmacao tom) => switch (tom) {
    TomConfirmacao.destrutivo => AppTema.erro,
    TomConfirmacao.positivo => AppTema.sucesso,
    TomConfirmacao.neutro => AppTema.primaria,
  };

  static Widget _iconeDo(TomConfirmacao tom, IconData? sobrescrito, Color cor) {
    if (sobrescrito != null) return Icon(sobrescrito, color: cor, size: 20);
    if (tom == TomConfirmacao.positivo) {
      return FaIcon(FontAwesomeIcons.circleCheck, color: cor, size: 20);
    }
    return FaIcon(FontAwesomeIcons.triangleExclamation, color: cor, size: 20);
  }
}
