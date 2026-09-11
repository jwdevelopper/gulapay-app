/// Folha com a linha do tempo de auditoria de um item da comanda.
///
/// Lista os eventos de `GET /itens-comanda/{id}/eventos` em ordem
/// decrescente — quem fez, quando e o que mudou (RNF09). Extraída de
/// `comanda_detalhe_page.dart`, onde era uma classe privada de ~190 linhas.
library;

import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/modules/comanda/dto/evento_item_comanda_response.dart';
import 'package:my_app_teste/modules/comanda/dto/rotulos_comanda.dart';
import 'package:my_app_teste/modules/comanda/service/item_comanda_service.dart';

class FolhaEventosItem extends StatefulWidget {
  const FolhaEventosItem({
    super.key,
    required this.itemId,
    required this.itemNome,
  });

  final int itemId;
  final String itemNome;

  @override
  State<FolhaEventosItem> createState() => _FolhaEventosItemState();
}

class _FolhaEventosItemState extends State<FolhaEventosItem> {
  final _service = ItemComandaService();
  bool _loading = true;
  String? _erro;
  List<EventoItemComandaResponse> _eventos = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lista = await _service.listarEventos(widget.itemId);
      if (!mounted) return;
      setState(() {
        _eventos = lista;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar os eventos.';
          _loading = false;
        });
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos — ${widget.itemNome}',
              style: const TextStyle(
                color: AppTema.texto,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Linha do tempo de auditoria',
              style: TextStyle(color: AppTema.textoSecundario, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const AppCarregando()
                  : _erro != null
                  ? Center(
                      child: Text(
                        _erro!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTema.erro),
                      ),
                    )
                  : _eventos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum evento registrado.',
                        style: TextStyle(color: AppTema.textoSecundario),
                      ),
                    )
                  : ListView.separated(
                      controller: controller,
                      itemCount: _eventos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final e = _eventos[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTema.preenchimentoCampo,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTema.borda),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppTag(
                                    RotulosComanda.acaoEvento(e.acao),
                                    fundo: AppTema.primaria.withValues(
                                      alpha: 0.12,
                                    ),
                                    cor: AppTema.primaria,
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDate(e.dataHora),
                                    style: const TextStyle(
                                      color: AppTema.textoSecundario,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.usuarioNome ?? e.usuarioLogin ?? 'Usuário',
                                style: const TextStyle(
                                  color: AppTema.texto,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (e.motivo?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Motivo: ${motivosCancelamentoItem[e.motivo!] ?? e.motivo}',
                                  style: const TextStyle(
                                    color: AppTema.textoSecundario,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              if (e.valorAntes?.isNotEmpty == true) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Antes: ${e.valorAntes}',
                                  style: const TextStyle(
                                    color: AppTema.textoSecundario,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              if (e.valorDepois?.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Depois: ${e.valorDepois}',
                                  style: const TextStyle(
                                    color: AppTema.textoSecundario,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
