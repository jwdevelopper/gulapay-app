import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Cartão de resumo do pedido de uma mesa.
///
/// Mostra a identificação da mesa e os quatro números que interessam ao
/// garçom de relance: comanda, mesas do grupo, itens lançados e o parcial.
///
/// "Mesas do grupo" existe porque mesas podem ser juntadas no salão — o
/// pedido é do grupo, não de uma mesa só.
class ResumoPedidoMesa extends StatelessWidget {
  /// Código da mesa (ex.: `M12`).
  final String codigo;

  /// Nome da área do salão.
  final String? area;

  /// Etiqueta de status da mesa, montada por quem chama.
  final Widget etiquetaStatus;

  /// Código da comanda ativa, quando há uma.
  final String? comanda;

  /// Códigos das mesas que dividem este pedido.
  final List<String> mesasDoGrupo;

  /// Quantidade de itens lançados.
  final int itens;

  /// Total parcial, já formatado.
  final String parcial;

  const ResumoPedidoMesa({
    super.key,
    required this.codigo,
    required this.area,
    required this.etiquetaStatus,
    required this.comanda,
    required this.mesasDoGrupo,
    required this.itens,
    required this.parcial,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: AppTema.borda),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                codigo,
                style: const TextStyle(
                  color: AppTema.texto,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            etiquetaStatus,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          area ?? 'Área não identificada',
          style: const TextStyle(
            color: AppTema.textoSecundario,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Numero(rotulo: 'Comanda', valor: comanda ?? '—'),
            _Numero(
              rotulo: 'Mesas',
              valor: mesasDoGrupo.isEmpty ? codigo : mesasDoGrupo.join(', '),
            ),
            _Numero(rotulo: 'Itens', valor: '$itens'),
            _Numero(rotulo: 'Parcial', valor: parcial),
          ],
        ),
      ],
    ),
  );
}

class _Numero extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Numero({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTema.superficieAlt,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTema.borda),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            color: AppTema.textoSecundario,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            color: AppTema.texto,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
