import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';

class CategoriaFiltros extends StatelessWidget {
  const CategoriaFiltros({
    super.key,
    required this.controleBusca,
    required this.filtroStatus,
    required this.aoMudarBusca,
    required this.aoMudarStatus,
  });

  static const _opcoesStatus = <String>['TODAS', 'ATIVAS', 'INATIVAS'];

  final TextEditingController controleBusca;
  final String filtroStatus;
  final ValueChanged<String> aoMudarBusca;
  final ValueChanged<String> aoMudarStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AppCampoBusca(
            controle: controleBusca,
            dica: 'Buscar por nome ou descrição...',
            aoMudar: aoMudarBusca,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _opcoesStatus.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final opcao = _opcoesStatus[index];
                final selecionada = filtroStatus == opcao;
                return ChoiceChip(
                  label: Text(opcao),
                  selected: selecionada,
                  onSelected: (_) => aoMudarStatus(opcao),
                  selectedColor: AppTema.primaria,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selecionada ? Colors.white : AppTema.textoEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                  side: const BorderSide(color: AppTema.bordaCampo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
