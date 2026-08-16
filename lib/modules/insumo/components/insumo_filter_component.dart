import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/modules/insumo/models/insumo_list_filter.dart';

class InsumoFilterComponent extends StatefulWidget {
  final InsumosFilters initialFilter;

  const InsumoFilterComponent({super.key, required this.initialFilter});

  static Future<InsumosFilters?> show(BuildContext context, { required InsumosFilters initialFilter }) {
    return showModalBottomSheet<InsumosFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => InsumoFilterComponent(initialFilter: initialFilter),
    );
  }

  @override
  State<InsumoFilterComponent> createState() => _InsumoFilterComponentState();
}

class _InsumoFilterComponentState extends State<InsumoFilterComponent> {
  bool? _abaixoDoMinimo;
  bool? _ativo;

  @override
  void initState() {
    super.initState();
    _abaixoDoMinimo = widget.initialFilter.abaixoDoMinimo;
    _ativo = widget.initialFilter.ativo;
  }

  void _clearFilters() {
    setState(() {
      _abaixoDoMinimo = null;
      _ativo = null;
    });
  }

  void _applyFilters() {
    Navigator.pop(context,
      widget.initialFilter.copyWith(
        abaixoDoMinimo: _abaixoDoMinimo,
        clearAbaixoDoMinimo: _abaixoDoMinimo == null,
        ativo: _ativo,
        clearAtivo: _ativo == null,
      ),
    );  
  }
  

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.65,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTema.fundo,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column (
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTema.bordaCampo,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        color: AppTema.textoEscuro,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTema.textoSecundario),
                      color: AppTema.textoSecundario,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 16),
                    children: [
                      _buildSelectionTitle('Estoque'),

                      const SizedBox(height: 12),

                      _buildOptions(
                        label: 'Todos',
                        selected: _abaixoDoMinimo == null,
                        onTap: () {
                          setState(() {
                            _abaixoDoMinimo = null;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildOptions(
                        label: 'Abaixo do mínimo',
                        selected: _abaixoDoMinimo == true,
                        onTap: () {
                          setState(() {
                            _abaixoDoMinimo = true;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildSelectionTitle('Status'),

                      const SizedBox(height: 8),

                      _buildOptions(
                        label: 'Todos',
                        selected: _ativo == null,
                        onTap: () {
                          setState(() {
                            _ativo = null;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildOptions(
                        label: 'Ativo',
                        selected: _ativo == true,
                        onTap: () {
                          setState(() {
                            _ativo = true;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildOptions(
                        label: 'Inativo',
                        selected: _ativo == false,
                        onTap: () {
                          setState(() {
                            _ativo = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(color: AppTema.bordaCampo),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                        ),
                        child: const Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTema.textoSecundario,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppTema.primaria,
                          foregroundColor: AppTema.fundo,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                        ),
                        child: const Text(
                          'Aplicar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTema.fundo,
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              ],
            )
          )
        )
      ),
    );
  }

  Widget _buildSelectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTema.textoEscuro,
      ),
    );
  }

  Widget _buildOptions({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTema.primaria : AppTema.fundo,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTema.primaria : AppTema.bordaCampo,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTema.fundo : AppTema.textoSecundario,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, size: 20, color: AppTema.fundo),
          ],
        )
      ),
    );
  }
}