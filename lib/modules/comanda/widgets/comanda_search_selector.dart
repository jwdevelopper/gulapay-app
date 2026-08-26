import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';

Future<T?> abrirSeletorComBusca<T>({
  required BuildContext context,
  required String titulo,
  required List<T> itens,
  required String Function(T item) tituloItem,
  required IconData icone,
  String Function(T item)? subtituloItem,
  T? selecionado,
  int limiteInicial = 8,
}) {
  final ordenados = List<T>.from(itens)
    ..sort((a, b) => tituloItem(a).toLowerCase().compareTo(tituloItem(b).toLowerCase()));

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _SeletorComBusca<T>(
      titulo: titulo,
      itens: ordenados,
      tituloItem: tituloItem,
      subtituloItem: subtituloItem,
      icone: icone,
      selecionado: selecionado,
      limiteInicial: limiteInicial,
    ),
  );
}

class CampoSeletorComanda extends StatelessWidget {
  const CampoSeletorComanda({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.icone,
    required this.aoTocar,
    this.detalhe,
    this.erro = false,
  });

  final String rotulo;
  final String valor;
  final String? detalhe;
  final IconData icone;
  final VoidCallback aoTocar;
  final bool erro;

  @override
  Widget build(BuildContext context) {
    final preenchido = valor.isNotEmpty;
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EstoquePalette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: erro ? EstoquePalette.error : EstoquePalette.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: preenchido ? EstoquePalette.primary : EstoquePalette.inputFill,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icone, color: preenchido ? Colors.white : EstoquePalette.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rotulo, style: const TextStyle(color: EstoquePalette.text, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(valor.isEmpty ? 'Selecione uma opção' : valor, style: TextStyle(color: preenchido ? EstoquePalette.text : EstoquePalette.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
              if (detalhe != null && preenchido) Text(detalhe!, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: EstoquePalette.textMuted),
        ]),
      ),
    );
  }
}

class _SeletorComBusca<T> extends StatefulWidget {
  const _SeletorComBusca({
    required this.titulo,
    required this.itens,
    required this.tituloItem,
    required this.icone,
    required this.selecionado,
    required this.limiteInicial,
    this.subtituloItem,
  });

  final String titulo;
  final List<T> itens;
  final String Function(T item) tituloItem;
  final String Function(T item)? subtituloItem;
  final IconData icone;
  final T? selecionado;
  final int limiteInicial;

  @override
  State<_SeletorComBusca<T>> createState() => _SeletorComBuscaState<T>();
}

class _SeletorComBuscaState<T> extends State<_SeletorComBusca<T>> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  List<T> get _resultados {
    final termo = _busca.text.trim().toLowerCase();
    final todos = termo.isEmpty
        ? widget.itens
        : widget.itens.where((item) {
            final titulo = widget.tituloItem(item).toLowerCase();
            final subtitulo = (widget.subtituloItem?.call(item) ?? '').toLowerCase();
            return titulo.contains(termo) || subtitulo.contains(termo);
          }).toList();
    return termo.isEmpty ? todos.take(widget.limiteInicial).toList() : todos;
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: Container(
        decoration: const BoxDecoration(color: EstoquePalette.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: EstoquePalette.borderSoft, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: Text(widget.titulo, style: const TextStyle(color: EstoquePalette.text, fontSize: 18, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: EstoquePalette.text),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: _busca,
                onChanged: (_) => setState(() {}),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  prefixIcon: const Icon(Icons.search_rounded, color: EstoquePalette.textMuted),
                  filled: true,
                  fillColor: EstoquePalette.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: EstoquePalette.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              if (_busca.text.trim().isEmpty && widget.itens.length > widget.limiteInicial)
                Text('Mostrando os primeiros ${widget.limiteInicial} em ordem alfabética.', style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
              if (_busca.text.trim().isEmpty && widget.itens.length > widget.limiteInicial) const SizedBox(height: 8),
              Expanded(
                child: resultados.isEmpty
                    ? const Center(child: Text('Nenhum resultado encontrado.', style: TextStyle(color: EstoquePalette.textMuted)))
                    : ListView.separated(
                        itemCount: resultados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final item = resultados[index];
                          final selecionado = item == widget.selecionado;
                          final subtitulo = widget.subtituloItem?.call(item);
                          return InkWell(
                            onTap: () => Navigator.pop(context, item),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selecionado ? EstoquePalette.inputFill : EstoquePalette.surfaceAlt,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: selecionado ? EstoquePalette.primary : EstoquePalette.border),
                              ),
                              child: Row(children: [
                                Container(width: 40, height: 40, decoration: BoxDecoration(color: selecionado ? EstoquePalette.primary : EstoquePalette.inputFill, borderRadius: BorderRadius.circular(13)), child: Icon(widget.icone, color: selecionado ? Colors.white : EstoquePalette.primary, size: 20)),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(widget.tituloItem(item), style: const TextStyle(color: EstoquePalette.text, fontSize: 14, fontWeight: FontWeight.w700)),
                                  if (subtitulo?.isNotEmpty == true) Text(subtitulo!, style: const TextStyle(color: EstoquePalette.textMuted, fontSize: 11)),
                                ])),
                                if (selecionado) const Icon(Icons.check_circle_rounded, color: EstoquePalette.primary, size: 20),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
