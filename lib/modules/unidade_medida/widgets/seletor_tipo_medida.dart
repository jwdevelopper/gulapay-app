import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/rotulos_unidade.dart';

/// Escolha do tipo de medida, em três cartões lado a lado.
///
/// Não é um dropdown de propósito: são só três opções, elas não mudam, e
/// cada uma tem cor e ícone próprios — mostrá-las abertas deixa a diferença
/// entre massa, volume e contagem visível de uma vez.
///
/// Passe [habilitado] como falso na edição: o tipo é imutável depois do
/// cadastro, porque mudá-lo reinterpretaria todo saldo já gravado naquela
/// unidade.
class SeletorTipoMedida extends StatelessWidget {
  /// Tipo escolhido (`MASSA`, `VOLUME`, `UNIDADE`) ou `null`.
  final String? selecionado;

  /// Chamado com o tipo escolhido.
  final ValueChanged<String> aoSelecionar;

  /// Falso deixa os cartões visíveis, porém inertes e esmaecidos.
  final bool habilitado;

  const SeletorTipoMedida({
    super.key,
    required this.selecionado,
    required this.aoSelecionar,
    this.habilitado = true,
  });

  static IconData _icone(String tipo) => switch (tipo) {
    'MASSA' => Icons.monitor_weight_outlined,
    'VOLUME' => Icons.water_drop_outlined,
    'UNIDADE' => Icons.tag_rounded,
    _ => Icons.straighten_rounded,
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !habilitado,
    child: Opacity(
      opacity: habilitado ? 1 : 0.5,
      child: Row(
        children: [
          for (final tipo in RotulosUnidade.tipos)
            Expanded(
              child: _Cartao(
                tipo: tipo,
                selecionado: selecionado == tipo,
                aoTocar: () => aoSelecionar(tipo),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Cartao extends StatelessWidget {
  final String tipo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _Cartao({
    required this.tipo,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = RotulosUnidade.corTipo(tipo);
    return GestureDetector(
      onTap: aoTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selecionado ? cor : AppTema.superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? cor : AppTema.borda,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SeletorTipoMedida._icone(tipo),
              color: selecionado ? Colors.white : cor,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              RotulosUnidade.tipo(tipo),
              style: TextStyle(
                color: selecionado ? Colors.white : AppTema.texto,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
