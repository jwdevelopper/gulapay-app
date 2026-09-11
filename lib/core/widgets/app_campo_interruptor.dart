import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';

/// Campo de liga/desliga dos formulários, com a moldura de campo.
///
/// Fonte única do interruptor que os formulários usam para o `ativo` do
/// soft delete (RNF08) e afins. Substituiu três `SwitchListTile` embrulhados
/// em `Container` — em Lote, Insumo e Entregador —, cada um repetindo a
/// moldura e a cor do polegar à mão.
///
/// ```dart
/// AppCampoInterruptor(
///   titulo: 'Lote ativo',
///   descricao: 'Lotes inativos não participam das saídas FEFO.',
///   valor: _ativo,
///   aoMudar: (v) => setState(() => _ativo = v),
/// )
/// ```
class AppCampoInterruptor extends StatelessWidget {
  /// Texto principal, o que está sendo ligado ou desligado.
  final String titulo;

  /// Explicação da consequência de desligar. Opcional, mas recomendada —
  /// é onde cabe a regra de negócio que o usuário não adivinha.
  final String? descricao;

  /// Estado atual.
  final bool valor;

  /// Chamado com o novo estado. `null` deixa o campo inerte (somente
  /// leitura).
  final ValueChanged<bool>? aoMudar;

  const AppCampoInterruptor({
    super.key,
    required this.titulo,
    required this.valor,
    required this.aoMudar,
    this.descricao,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: DecoracoesApp.campoPlano(),
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppTema.primaria,
      value: valor,
      onChanged: aoMudar,
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTema.texto,
        ),
      ),
      subtitle: descricao == null
          ? null
          : Text(
              descricao!,
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 12,
              ),
            ),
    ),
  );
}
