import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_status_validade.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/widgets/detalhe/cartoes_lote.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/dto/movimentacao_estoque.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/service/movimentacao_estoque_service.dart';

/// Detalhe de um lote: identificação, atributos e histórico de
/// movimentações.
///
/// Cuida de estado, carga e navegação; o que a tela mostra vive em
/// `widgets/detalhe/cartoes_lote.dart`.
///
/// O histórico vem de `GET /movimentacoes-estoque?insumoId=X` filtrado
/// pelo lote — a API não expõe um filtro por lote, e o volume por insumo é
/// pequeno o bastante para peneirar aqui.
class LoteDetalhesPage extends StatefulWidget {
  final LoteResponse lote;
  final InsumoResponse? insumo;

  const LoteDetalhesPage({super.key, required this.lote, this.insumo});

  @override
  State<LoteDetalhesPage> createState() => _LoteDetalhesPageState();
}

class _LoteDetalhesPageState extends State<LoteDetalhesPage> {
  final _loteService = LoteService();
  final _movimentacaoService = MovimentacaoEstoqueService();

  late LoteResponse _lote;

  /// Marca que algo mudou, para a listagem de origem recarregar ao voltar.
  bool _alterou = false;

  List<MovimentacaoEstoque> _movimentacoes = [];
  bool _carregandoMovimentacoes = true;
  String? _erroMovimentacoes;

  @override
  void initState() {
    super.initState();
    _lote = widget.lote;
    _carregarMovimentacoes();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _recarregarLote() async {
    final id = _lote.id;
    if (id == null) return;
    try {
      final atualizado = await _loteService.buscarPorId(id);
      if (mounted) setState(() => _lote = atualizado);
    } catch (_) {
      // Mantém os dados atuais caso a releitura falhe — o usuário acabou de
      // salvar e veria a tela esvaziar sem motivo.
    }
  }

  Future<void> _carregarMovimentacoes() async {
    final loteId = _lote.id;
    final insumoId = _lote.insumoId ?? widget.insumo?.id;
    if (loteId == null || insumoId == null) {
      setState(() {
        _carregandoMovimentacoes = false;
        _movimentacoes = [];
      });
      return;
    }

    setState(() {
      _carregandoMovimentacoes = true;
      _erroMovimentacoes = null;
    });
    try {
      final brutas = await _movimentacaoService.listarMovimentacoes(insumoId);
      if (!mounted) return;
      setState(() {
        _movimentacoes = brutas
            .whereType<Map>()
            .map(
              (m) => MovimentacaoEstoque.fromJson(Map<String, dynamic>.from(m)),
            )
            .where((m) => m.loteId == loteId)
            .toList();
      });
    } on ApiError catch (e) {
      if (mounted) setState(() => _erroMovimentacoes = e.message);
    } catch (e) {
      if (mounted) {
        setState(
          () => _erroMovimentacoes = 'Erro ao carregar movimentações: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoMovimentacoes = false);
    }
  }

  Future<void> _editar() async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormPage(lote: _lote, insumoInicial: widget.insumo),
      ),
    );
    if (alterou == true) {
      _alterou = true;
      await _recarregarLote();
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final status = LoteStatusValidade.calcular(_lote.validade);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _alterou);
      },
      child: Scaffold(
        backgroundColor: AppTema.fundo,
        appBar: AppBar(
          backgroundColor: AppTema.fundo,
          foregroundColor: AppTema.texto,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTema.primariaEscura),
          title: const Text(
            'Detalhe do lote',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTema.texto),
          ),
          actions: [
            IconButton(
              tooltip: 'Editar lote',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _editar,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            HeroiLote(lote: _lote),
            if (status.exigeAtencao) ...[
              const SizedBox(height: 14),
              AvisoValidadeLote(lote: _lote),
            ],
            const SizedBox(height: 20),
            _tituloSecao('Atributos'),
            const SizedBox(height: 8),
            AtributosLote(lote: _lote),
            const SizedBox(height: 20),
            _tituloSecao('Movimentações'),
            const SizedBox(height: 8),
            _historico(),
          ],
        ),
      ),
    );
  }

  Widget _tituloSecao(String titulo) => Text(
    titulo,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: AppTema.texto,
      fontSize: 15,
    ),
  );

  Widget _historico() {
    if (_carregandoMovimentacoes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: AppCarregando(),
      );
    }
    if (_erroMovimentacoes != null) {
      return _moldura(
        AppEstadoVazio(
          icone: Icons.cloud_off_rounded,
          titulo: 'Histórico indisponível',
          mensagem: _erroMovimentacoes!,
          rotuloBotao: 'Tentar novamente',
          iconeBotao: Icons.refresh_rounded,
          secundario: true,
          aoTocarBotao: _carregarMovimentacoes,
        ),
      );
    }
    if (_movimentacoes.isEmpty) {
      return _moldura(
        const AppEstadoVazio(
          icone: Icons.receipt_long_outlined,
          mensagem: 'Nenhuma movimentação registrada para este lote.',
        ),
      );
    }

    return _moldura(
      Column(
        children: [
          for (var i = 0; i < _movimentacoes.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTema.borda),
            LinhaMovimentacaoLote(movimentacao: _movimentacoes[i]),
          ],
        ],
      ),
      comRecuo: false,
    );
  }

  /// Cartão que envolve o histórico, para os três estados terem a mesma
  /// moldura.
  Widget _moldura(Widget filho, {bool comRecuo = true}) => Container(
    padding: comRecuo
        ? const EdgeInsets.symmetric(vertical: 24, horizontal: 16)
        : EdgeInsets.zero,
    decoration: BoxDecoration(
      color: AppTema.superficie,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTema.borda),
    ),
    child: filho,
  );
}
