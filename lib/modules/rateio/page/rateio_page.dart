import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/movimentacao_estoque/widgets/estoque_palette.dart';
import '../controller/rateio_controller.dart';
import '../dto/rateio_comanda_request.dart';
import '../util/rateio_formato.dart';
import '../widget/rateio_divisao_rapida.dart';
import '../widget/rateio_estrategia_card.dart';
import '../widget/rateio_manual_form.dart';
import '../widget/rateio_participantes_lista.dart';
import '../widget/rateio_por_item_form.dart';
import '../widget/rateio_proporcional_previa.dart';
import '../widget/rateio_resumo.dart';

class RateioPage extends StatefulWidget {
  const RateioPage({super.key, required this.comandaId});

  final int comandaId;

  @override
  State<RateioPage> createState() => _RateioPageState();
}

class _RateioPageState extends State<RateioPage> {
  late final RateioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RateioController(comandaId: widget.comandaId);
    _controller.carregar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _executar(Future<RateioAviso?> Function() acao) async {
    final aviso = await acao();
    if (!mounted || aviso == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(aviso.mensagem),
      backgroundColor:
          aviso.sucesso ? EstoquePalette.success : EstoquePalette.error,
    ));
  }

  Future<void> _confirmarRecalculo() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EstoquePalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Recalcular rateio'),
        content: const Text(
            'Isso vai limpar o rateio já calculado. Você poderá aplicar '
            'de novo com outra estratégia. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: EstoquePalette.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Recalcular'),
          ),
        ],
      ),
    );
    if (confirmou == true) await _executar(_controller.reverter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EstoquePalette.background,
      appBar: AppBar(
        backgroundColor: EstoquePalette.surface,
        foregroundColor: EstoquePalette.text,
        elevation: 0,
        title: const Text('Dividir conta',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _corpo(),
      ),
    );
  }

  Widget _corpo() {
    if (_controller.carregando) {
      return const Center(
          child: CircularProgressIndicator(color: EstoquePalette.primary));
    }
    if (_controller.erro != null) return _estadoErro(_controller.erro!);

    return SafeArea(
      child: Column(
        children: [
          _cabecalho(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: _controller.rateioAplicado
                  ? [
                      _titulo('Valores por participante'),
                      const SizedBox(height: 8),
                      RateioResumo(
                        controller: _controller,
                        aoRecalcular: _confirmarRecalculo,
                      ),
                    ]
                  : _modoEdicao(),
            ),
          ),
          if (_controller.executando)
            const LinearProgressIndicator(
                color: EstoquePalette.primary,
                backgroundColor: EstoquePalette.borderSoft),
        ],
      ),
    );
  }

  List<Widget> _modoEdicao() {
    if (_controller.semParticipantes) {
      return [
        RateioDivisaoRapida(
          controller: _controller,
          aoConfirmar: () => _executar(() =>
              _controller.adicionarPessoas(_controller.quantidadePessoas)),
        ),
      ];
    }

    return [
      _titulo('1. Quem participa'),
      const SizedBox(height: 8),
      RateioParticipantesLista(
        controller: _controller,
        aoAdicionarPessoa: () =>
            _executar(() => _controller.adicionarPessoas(1)),
        aoSalvar: () => _executar(_controller.salvarParticipantes),
      ),
      const SizedBox(height: 24),
      _titulo('2. Como dividir'),
      const SizedBox(height: 8),
      ...EstrategiaRateio.values.map((e) => RateioEstrategiaCard(
            estrategia: e,
            selecionada: _controller.estrategia == e,
            indisponivelPor: _controller.indisponibilidade(e),
            aoSelecionar: _controller.executando
                ? null
                : () => _controller.selecionarEstrategia(e),
          )),
      ..._formularioDaEstrategia(),
      const SizedBox(height: 20),
      _botaoAplicar(),
    ];
  }

  List<Widget> _formularioDaEstrategia() => switch (_controller.estrategia) {
        EstrategiaRateio.manual => [
            const SizedBox(height: 16),
            _titulo('3. Quanto cada um paga'),
            const SizedBox(height: 8),
            RateioManualForm(controller: _controller),
          ],
        EstrategiaRateio.proporcional => [
            const SizedBox(height: 16),
            RateioProporcionalPrevia(controller: _controller),
          ],
        EstrategiaRateio.porItem => [
            const SizedBox(height: 16),
            _titulo('3. Quem consumiu cada item'),
            const SizedBox(height: 8),
            RateioPorItemForm(controller: _controller),
          ],
        _ => const [],
      };

  Widget _botaoAplicar() {
    final bloqueio = _controller.bloqueioAplicacao;
    final habilitado = bloqueio == null && !_controller.executando;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                habilitado ? () => _executar(_controller.aplicar) : null,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Aplicar rateio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EstoquePalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        if (bloqueio != null) ...[
          const SizedBox(height: 6),
          Text(bloqueio,
              style: const TextStyle(
                  color: EstoquePalette.error, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _cabecalho() {
    final r = _controller.rateio!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: EstoquePalette.surface,
        border: Border(bottom: BorderSide(color: EstoquePalette.borderSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.codigo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: EstoquePalette.text)),
          const SizedBox(height: 4),
          Text('Total: ${moeda(r.totalLiquido)}',
              style: const TextStyle(
                  color: EstoquePalette.textMuted, fontSize: 13)),
          if (r.rateioAplicado) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EstoquePalette.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: EstoquePalette.success.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Estratégia aplicada: '
                '${EstrategiaRateio.fromApi(r.estrategia)?.rotulo ?? r.estrategia}',
                style: const TextStyle(
                    color: EstoquePalette.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _estadoErro(String mensagem) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: EstoquePalette.error, size: 48),
              const SizedBox(height: 12),
              Text(mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: EstoquePalette.text)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _controller.carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar de novo'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: EstoquePalette.primary,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _titulo(String texto) => Text(texto,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: EstoquePalette.text));
}
