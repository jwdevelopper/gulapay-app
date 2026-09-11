/// Widgets do editor de mapa de salão.
///
/// Peças da tela de edição do plano de mesas, extraídas de `mesa_page.dart`
/// — viviam lá como classes privadas e respondiam por ~360 das 988 linhas
/// do arquivo.
///
///  * [MesaMapEditorPage] — a página de edição em si (canvas + painel).
///  * [EditorTopBar] — barra superior com título e ações.
///  * [EditorSidePanel] — painel lateral com estatísticas e dicas.
///  * [EditorMiniStat] — número + rótulo de uma métrica do painel.
///  * [EditorHint] — linha de dica sobre como manipular o mapa.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/dto/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/widgets/floor_plan_canvas.dart';

class MesaMapEditorPage extends StatelessWidget {
  const MesaMapEditorPage({
    super.key,
    required this.controller,
    required this.onNewTable,
    required this.onEditTable,
    required this.onJoinSuggested,
  });

  final FloorPlanController controller;
  final VoidCallback onNewTable;
  final ValueChanged<RestaurantTable> onEditTable;
  final VoidCallback onJoinSuggested;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final area = controller.selectedArea;
        if (area == null) {
          return const Scaffold(
            backgroundColor: AppTema.fundo,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTema.fundo,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 860;
              final bottomInset = MediaQuery.of(context).padding.bottom;

              return Stack(
                children: [
                  Positioned.fill(
                    child: FloorPlanCanvas(
                      area: area,
                      controller: controller,
                      isEditMode: true,
                      isExpanded: true,
                      borderRadius: 0,
                      showMapBadge: false,
                      onToggleEditMode: () => Navigator.pop(context),
                      onExpand: () {},
                      onJoinSuggested: onJoinSuggested,
                      onEditTable: onEditTable,
                      onOpenTable: onEditTable,
                      onOpenOrder: (_) {},
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: MediaQuery.of(context).padding.top + 8,
                    child: EditorTopBar(
                      area: area,
                      onNewTable: onNewTable,
                      onClose: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    left: isWide ? 16 : 12,
                    right: isWide ? null : 12,
                    bottom: 12 + bottomInset,
                    width: isWide ? 320 : null,
                    child: EditorSidePanel(
                      controller: controller,
                      area: area,
                      onNewTable: onNewTable,
                      onJoinSuggested: onJoinSuggested,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class EditorTopBar extends StatelessWidget {
  const EditorTopBar({
    super.key,
    required this.area,
    required this.onNewTable,
    required this.onClose,
  });

  final RestaurantArea area;
  final VoidCallback onNewTable;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTema.superficieAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTema.borda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Fechar editor',
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editor do mapa de mesas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTema.texto,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${area.name} - ${area.totalTables} mesas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTema.textoSecundario,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onNewTable,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Nova'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class EditorSidePanel extends StatelessWidget {
  const EditorSidePanel({
    super.key,
    required this.controller,
    required this.area,
    required this.onNewTable,
    required this.onJoinSuggested,
  });

  final FloorPlanController controller;
  final RestaurantArea area;
  final VoidCallback onNewTable;
  final VoidCallback onJoinSuggested;

  @override
  Widget build(BuildContext context) {
    final hasJoinSuggestion = controller.suggestedJoinTargetId != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTema.superficieAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTema.borda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_location_alt_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  area.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = controller.areas[index];
                return ChoiceChip(
                  selected: item.id == area.id,
                  label: Text(item.name),
                  avatar: Icon(
                    item.id == area.id
                        ? Icons.check_rounded
                        : Icons.location_on_outlined,
                    size: 16,
                  ),
                  onSelected: (_) => controller.selectArea(item.id),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EditorMiniStat(
                icon: Icons.table_restaurant_outlined,
                label: 'Mesas',
                value: '${area.totalTables}',
              ),
              EditorMiniStat(
                icon: Icons.people_outline,
                label: 'Uso',
                value: '${area.occupancyCount}',
              ),
              EditorMiniStat(
                icon: Icons.link,
                label: 'Grupos',
                value: '${area.joinGroups.length}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNewTable,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Mesa'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: hasJoinSuggestion ? onJoinSuggested : null,
                  icon: const Icon(Icons.call_merge_rounded),
                  label: const Text('Unir'),
                ),
              ),
            ],
          ),
          if (hasJoinSuggestion) ...[
            const SizedBox(height: 10),
            const EditorHint(
              icon: Icons.touch_app_outlined,
              text: 'Solte a mesa e toque em Unir para agrupar.',
            ),
          ],
        ],
      ),
    );
  }
}

class EditorMiniStat extends StatelessWidget {
  const EditorMiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTema.bordaSuave),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTema.textoSecundario),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTema.texto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class EditorHint extends StatelessWidget {
  const EditorHint({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTema.primaria),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
