import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';

/// Faixa que identifica de qual insumo são os lotes listados.
///
/// A listagem de lotes só existe no contexto de um insumo (o backend expõe
/// `GET /lotes?insumoId=X`), então esta faixa fica fixa no topo com o nome,
/// a unidade base e o atalho para trocar de insumo sem sair da tela.
class CabecalhoInsumoLotes extends StatelessWidget {
  /// Insumo cujos lotes estão sendo exibidos.
  final InsumoResponse insumo;

  /// Abre o seletor para trocar de insumo.
  final VoidCallback aoTrocar;

  const CabecalhoInsumoLotes({
    super.key,
    required this.insumo,
    required this.aoTrocar,
  });

  /// Símbolo da unidade base, com o nome longo como reserva.
  String? get _unidade {
    final simbolo = insumo.unidadePadraoSimbolo ?? insumo.unidadePadrao;
    return (simbolo ?? '').isEmpty ? null : simbolo;
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTema.borda),
    ),
    child: Row(
      children: [
        const Icon(Icons.inventory_2_outlined, color: AppTema.primariaEscura),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insumo.nome ?? '—',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTema.texto,
                ),
              ),
              Text(
                _unidade == null
                    ? 'Lotes em ordem FEFO'
                    : 'Unidade base: $_unidade',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTema.textoSecundario,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: aoTrocar,
          style: TextButton.styleFrom(foregroundColor: AppTema.primaria),
          child: const Text('Trocar'),
        ),
      ],
    ),
  );
}
