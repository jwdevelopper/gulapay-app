import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/insumo/dto/insumo_response.dart';
import 'package:my_app_teste/modules/lote/dto/lote_response.dart';
import 'package:my_app_teste/modules/lote/models/lote_status_validade.dart';
import 'package:my_app_teste/modules/lote/page/lote_form_page.dart';
import 'package:my_app_teste/modules/lote/service/lote_service.dart';
import 'package:my_app_teste/modules/lote/utils/lote_formatadores.dart';
import 'package:my_app_teste/modules/lote/widgets/lote_status_tag.dart';
import 'package:my_app_teste/modules/lote/components/movimentacao_estoque_mock.dart';

class LoteDetalhesPage extends StatefulWidget {
  final LoteResponse lote;
  final InsumoResponse? insumo;

  const LoteDetalhesPage({super.key, required this.lote, this.insumo});

  @override
  State<LoteDetalhesPage> createState() => _LoteDetalhesPageState();
}

class _LoteDetalhesPageState extends State<LoteDetalhesPage> {
  final LoteService _loteService = LoteService();
  final MovimentacaoEstoqueServiceMock _movService =
      MovimentacaoEstoqueServiceMock();

  late LoteResponse _lote;
  bool _alterou = false;

  List<MovimentacaoEstoqueMock> _movimentacoes = [];
  bool _carregandoMov = true;
  String? _erroMov;

  @override
  void initState() {
    super.initState();
    _lote = widget.lote;
    _carregarMovimentacoes();
  }

  Future<void> _recarregarLote() async {
    final id = _lote.id;
    if (id == null) return;
    try {
      final atualizado = await _loteService.buscarPorId(id);
      if (!mounted) return;
      setState(() => _lote = atualizado);
    } catch (_) {
      // Mantém os dados atuais caso a releitura falhe.
    }
  }

  Future<void> _carregarMovimentacoes() async {
    final loteId = _lote.id;
    if (loteId == null) {
      setState(() {
        _carregandoMov = false;
        _movimentacoes = [];
      });
      return;
    }
    setState(() {
      _carregandoMov = true;
      _erroMov = null;
    });
    try {
      final todas = await _movService.listarPorLote(loteId);
      if (!mounted) return;
      setState(() {
        _movimentacoes = todas.where((m) => m.loteId == loteId).toList();
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _erroMov = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroMov = 'Erro ao carregar movimentações: $e');
    } finally {
      if (mounted) setState(() => _carregandoMov = false);
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

  double get _valorEmEstoque =>
      (_lote.quantidadeRestante ?? 0) * (_lote.custoUnitario ?? 0);

  @override
  Widget build(BuildContext context) {
    final status = LoteStatusValidade.calcular(_lote.validade);
    final simbolo = _lote.unidadePadraoSimbolo ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _alterou);
      },
      child: Scaffold(
        backgroundColor: AppTema.fundo,
        appBar: AppBar(
          backgroundColor: AppTema.fundo,
          foregroundColor: AppTema.textoEscuro,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTema.primariaEscura),
          title: const Text(
            'Detalhe do lote',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTema.textoEscuro,
            ),
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
            _heroi(status, simbolo),
            if (status.exigeAtencao) ...[
              const SizedBox(height: 14),
              _bannerAtencao(status),
            ],
            const SizedBox(height: 20),
            _secao('Atributos'),
            const SizedBox(height: 8),
            _atributos(simbolo),
            const SizedBox(height: 20),
            _secao('Movimentações'),
            const SizedBox(height: 8),
            _listaMovimentacoes(),
          ],
        ),
      ),
    );
  }

  Widget _heroi(LoteStatusValidade status, String simbolo) {
    final codigo = (_lote.codigo ?? '').trim();
    final titulo = codigo.isNotEmpty ? 'Lote $codigo' : 'Lote ${_lote.id ?? ''}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTema.cartao,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTema.fundoDica,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month,
                    color: AppTema.primariaEscura),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTema.textoEscuro,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lote.insumoNome ?? 'Insumo',
                      style: const TextStyle(color: AppTema.textoSecundario),
                    ),
                  ],
                ),
              ),
              LoteStatusTag(status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Restante',
                  '${LoteFormatadores.formatarQuantidade(_lote.quantidadeRestante)} $simbolo'.trim()),
              _stat('Inicial',
                  '${LoteFormatadores.formatarQuantidade(_lote.quantidadeInicial)} $simbolo'.trim()),
              _stat(
                'Validade',
                LoteFormatadores.formatarDataCurta(_lote.validade),
                cor: status.exigeAtencao ? status.cor : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String rotulo, String valor, {Color? cor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 11,
              color: AppTema.textoSecundario,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: cor ?? AppTema.textoEscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerAtencao(LoteStatusValidade status) {
    final descricao = LoteStatusValidade.descricaoVencimento(_lote.validade);
    final mensagem = status == LoteStatusValidade.vencido
        ? '$descricao. Avalie descarte ou ajuste de inventário.'
        : '$descricao. Priorize na produção ou avalie uma promoção.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.fundo,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: status.cor, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            status == LoteStatusValidade.vencido
                ? Icons.error_outline
                : Icons.warning_amber_rounded,
            color: status.cor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(color: status.cor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _atributos(String simbolo) {
    final sufixoCusto = simbolo.isNotEmpty ? ' / $simbolo' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTema.cartao,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: Column(
        children: [
          _linhaAtributo(
            'Custo unitário',
            '${LoteFormatadores.formatarMoeda(_lote.custoUnitario)}$sufixoCusto',
          ),
          _divisor(),
          _linhaAtributo(
            'Valor em estoque',
            LoteFormatadores.formatarMoeda(_valorEmEstoque),
          ),
          _divisor(),
          _linhaAtributo(
            'Validade',
            LoteFormatadores.formatarData(_lote.validade),
          ),
          _divisor(),
          _linhaAtributo(
            'Situação',
            (_lote.ativo ?? true) ? 'Ativo' : 'Inativo',
          ),
        ],
      ),
    );
  }

  Widget _linhaAtributo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: AppTema.primariaEscura,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divisor() => const Divider(height: 1, color: AppTema.bordaCampo);

  Widget _secao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppTema.textoEscuro,
        fontSize: 15,
      ),
    );
  }

  Widget _listaMovimentacoes() {
    if (_carregandoMov) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppTema.primaria)),
      );
    }

    if (_erroMov != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTema.cartao,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTema.bordaCampo),
        ),
        child: Column(
          children: [
            AppEstadoVazio(icone: Icons.error_outline, mensagem: _erroMov!),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _carregarMovimentacoes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_movimentacoes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTema.cartao,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTema.bordaCampo),
        ),
        child: const AppEstadoVazio(
          icone: Icons.receipt_long_outlined,
          mensagem: 'Nenhuma movimentação registrada para este lote.',
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTema.cartao,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTema.bordaCampo),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _movimentacoes.length; i++) ...[
            if (i > 0) _divisor(),
            _itemMovimentacao(_movimentacoes[i]),
          ],
        ],
      ),
    );
  }

  Widget _itemMovimentacao(MovimentacaoEstoqueMock mov) {
    final tipo = mov.tipo.toUpperCase();
    final entrada = tipo.contains('ENTRADA') || tipo.contains('COMPRA');
    final corQtd = entrada ? const Color(0xFF2E8B57) : const Color(0xFFC0392B);
    final sinal = entrada ? '+' : '−';
    final simbolo = mov.unidadeSimbolo;
    final quantidade = LoteFormatadores.formatarQuantidade(mov.quantidade);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entrada ? const Color(0xFFE3F1E8) : AppTema.fundoDica,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              entrada ? Icons.south_west : Icons.north_east,
              size: 18,
              color: corQtd,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rotuloTipo(tipo),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTema.textoEscuro,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    LoteFormatadores.formatarData(_apenasData(mov.dataHora)),
                    if (mov.responsavel.isNotEmpty) mov.responsavel,
                  ].join(' · '),
                  style: const TextStyle(
                    color: AppTema.textoSecundario,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sinal$quantidade ${simbolo.trim()}'.trim(),
            style: TextStyle(
              color: corQtd,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _rotuloTipo(String tipo) {
    switch (tipo) {
      case 'ENTRADA_COMPRA':
        return 'Entrada por compra';
      case 'SAIDA_VENDA':
        return 'Saída por venda';
      case 'PERDA':
        return 'Perda';
      case 'AJUSTE_INVENTARIO':
        return 'Ajuste de inventário';
      default:
        return tipo.isEmpty ? 'Movimentação' : tipo;
    }
  }

  String? _apenasData(String? dataHora) {
    if (dataHora == null) return null;
    return dataHora.length >= 10 ? dataHora.substring(0, 10) : dataHora;
  }
}
