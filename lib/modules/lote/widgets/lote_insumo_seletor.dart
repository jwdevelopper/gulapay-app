import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/insumo/service/insumo_service.dart';

/// Bottom sheet de seleção de insumo, usado tanto para escolher qual insumo
/// listar (LotesPage) quanto para vincular o lote na criação (LoteFormPage).
/// Reaproveita [InsumoService.listar] com `apenasAtivos: true`.
class LoteInsumoSeletor extends StatefulWidget {
  const LoteInsumoSeletor({super.key});

  static Future<InsumoResponse?> abrir(BuildContext context) {
    return showModalBottomSheet<InsumoResponse>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTema.fundo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LoteInsumoSeletor(),
    );
  }

  @override
  State<LoteInsumoSeletor> createState() => _LoteInsumoSeletorState();
}

class _LoteInsumoSeletorState extends State<LoteInsumoSeletor> {
  final InsumoService _service = InsumoService();
  final TextEditingController _busca = TextEditingController();

  List<InsumoResponse> _insumos = [];
  bool _carregando = true;
  String? _erro;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _service.listar(apenasAtivos: true);
      if (!mounted) return;
      setState(() => _insumos = lista);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao carregar insumos: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<InsumoResponse> get _filtrados {
    final termo = _filtro.trim().toLowerCase();
    if (termo.isEmpty) return _insumos;
    return _insumos
        .where((i) => (i.nome ?? '').toLowerCase().contains(termo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final alturaMax = MediaQuery.of(context).size.height * 0.8;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaMax),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTema.bordaCampo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecionar insumo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTema.textoEscuro,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: AppCampoBusca(
                controle: _busca,
                dica: 'Buscar insumo…',
                aoMudar: (valor) => setState(() => _filtro = valor),
              ),
            ),
            Flexible(child: _conteudo()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppTema.primaria),
        ),
      );
    }

    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEstadoVazio(icone: Icons.error_outline, mensagem: _erro!),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: AppEstadoVazio(
          icone: Icons.inventory_2_outlined,
          mensagem: 'Nenhum insumo encontrado.',
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      itemCount: filtrados.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppTema.bordaCampo),
      itemBuilder: (context, index) {
        final insumo = filtrados[index];
        final unidade = insumo.unidadePadraoSimbolo ?? insumo.unidadePadrao;
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppTema.fundoDica,
            child: Icon(Icons.inventory_2_outlined,
                color: AppTema.primariaEscura, size: 20),
          ),
          title: Text(
            insumo.nome ?? '—',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTema.textoEscuro,
            ),
          ),
          subtitle: unidade != null && unidade.isNotEmpty
              ? Text('Unidade base: $unidade',
                  style: const TextStyle(color: AppTema.textoSecundario))
              : null,
          onTap: () => Navigator.pop(context, insumo),
        );
      },
    );
  }
}
