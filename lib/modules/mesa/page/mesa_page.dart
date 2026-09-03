import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/gula_theme.dart';
import 'package:my_app_teste/modules/mesa/controller/floor_plan_controller.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_form_page.dart';
import 'package:my_app_teste/modules/mesa/page/mesa_order_page.dart';
import 'package:my_app_teste/modules/mesa/widget/floor_plan_canvas.dart';
import 'package:my_app_teste/modules/mesa/widget/restaurant_area_tab.dart';
import 'package:my_app_teste/modules/mesa/widget/table_info_sheet.dart';
import 'package:my_app_teste/modules/mesa/widget/table_legend.dart';

class MesaPagina extends StatefulWidget {
  const MesaPagina({super.key});

  @override
  State<MesaPagina> createState() => _MesaPaginaState();
}

class _MesaPaginaState extends State<MesaPagina> {
  late final ControladorMapaMesas _controlador;
  bool _modoEdicao = false;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorMapaMesas()..carregar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final area = _controlador.areaSelecionada;
        if (_controlador.estaCarregando || area == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final compacto = MediaQuery.sizeOf(context).width < 520;

        return Scaffold(
          backgroundColor: GulaColors.background,
          body: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compacto ? 12 : 16,
                10,
                compacto ? 12 : 16,
                12,
              ),
              child: Column(
                children: [
                  _construirSeletorArea(area, compacto: compacto),
                  const SizedBox(height: 10),
                  Expanded(child: _construirMapaOperacional(area)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _construirSeletorArea(
    AreaRestaurante areaSelecionada, {
    required bool compacto,
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: compacto ? 64 : 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _controlador.areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _controlador.areas[index];
                return AbaAreaRestaurante(
                  area: item,
                  selecionada: item.id == areaSelecionada.id,
                  compacto: true,
                  aoTocar: () => _controlador.selecionarArea(item.id),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        _BotaoMenuMapa(
          aoExibirLegenda: _exibirLegendaMapa,
          aoRestaurar: _restaurarMapa,
        ),
      ],
    );
  }

  Widget _construirMapaOperacional(AreaRestaurante area) {
    final ocupadas = area.quantidadeOcupadas;
    final alertas = area.mesas.where((mesa) {
      final situacao = _controlador.resolverSituacao(mesa);
      return situacao == SituacaoMesa.semPedidoHa30Min ||
          situacao == SituacaoMesa.aguardandoLiberacaoHa1H ||
          situacao == SituacaoMesa.atencao;
    }).length;

    return Stack(
      children: [
        Positioned.fill(
          child: CanvasMapaMesas(
            area: area,
            controlador: _controlador,
            modoEdicao: _modoEdicao,
            aoAlternarModoEdicao: () {
              setState(() => _modoEdicao = !_modoEdicao);
            },
            aoAdicionarMesa: () => _exibirEditorMesa(),
            aoUnirSugeridas: _unirMesasSugeridas,
            aoEditarMesa: (mesa) => _exibirEditorMesa(mesa: mesa),
            aoAbrirMesa: _exibirInformacoesMesa,
            aoAbrirComanda: (mesa) => _abrirComanda(mesa.id),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: IgnorePointer(
            child: _ResumoMapa(
              nomeArea: area.nome,
              total: area.totalMesas,
              ocupadas: ocupadas,
              alertas: alertas,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _exibirLegendaMapa() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LegendaMesas(compacto: true),
        ),
      ),
    );
  }

  Future<void> _restaurarMapa() async {
    await _controlador.restaurarDadosIniciais();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mapa restaurado para a base inicial.')),
    );
  }

  Future<void> _unirMesasSugeridas() async {
    final erro = await _controlador.unirMesasSugeridas();
    if (!mounted) {
      return;
    }
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mesas unidas com sucesso.')));
  }

  Future<void> _exibirEditorMesa({MesaRestaurante? mesa}) async {
    final idArea = mesa?.idArea ?? (_controlador.areaSelecionada?.id ?? '');
    final rascunho = await Navigator.push<RascunhoMesa>(
      context,
      MaterialPageRoute(
        builder: (context) => MesaFormularioPagina(
          areas: _controlador.areas,
          idAreaInicial: idArea,
          mesa: mesa,
        ),
      ),
    );

    if (rascunho == null) {
      return;
    }

    await _controlador.salvarMesa(rascunho);
    _exibirErroControladorSeNecessario();
  }

  Future<void> _exibirInformacoesMesa(MesaRestaurante mesa) async {
    final mesaAtualizada = _controlador.buscarMesaPorId(mesa.id);
    if (mesaAtualizada == null) {
      return;
    }

    final area = _controlador.buscarAreaPorId(mesaAtualizada.idArea);
    if (area == null) {
      return;
    }

    final mesasDoContexto = _controlador.mesasDoContexto(mesaAtualizada.id);
    final situacao = _controlador.resolverSituacao(mesaAtualizada);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (contextoPainel) => PainelInformacoesMesa(
        nomeArea: area.nome,
        mesa: mesaAtualizada,
        situacao: situacao,
        mesasDoContexto: mesasDoContexto,
        totalCadeiras: _controlador.quantidadeCadeirasGrupo(mesaAtualizada.id),
        pessoasSentadas: _controlador.quantidadePessoasGrupo(mesaAtualizada.id),
        quantidadeItens: _controlador.quantidadeItensGrupo(mesaAtualizada.id),
        totalParcial: _controlador.totalParcialGrupo(mesaAtualizada.id),
        ultimoPedidoEm: _controlador.ultimoPedidoDoContexto(mesaAtualizada.id),
        nomeCliente: _controlador.nomeClienteGrupo(mesaAtualizada.id),
        mesasCompativeis: _controlador.mesasCompativeisParaUniao(
          mesaAtualizada.id,
        ),
        aoAbrirComanda: () {
          Navigator.pop(contextoPainel);
          _abrirComanda(mesaAtualizada.id);
        },
        aoEditar: () {
          Navigator.pop(contextoPainel);
          _exibirEditorMesa(mesa: mesaAtualizada);
        },
        aoLiberar: () {
          Navigator.pop(contextoPainel);
          _confirmarELiberar(mesaAtualizada.id);
        },
        aoUnirCom: (idMesaAlvo) async {
          Navigator.pop(contextoPainel);
          final erro = await _controlador.unirMesas(
            idMesaOrigem: mesaAtualizada.id,
            idMesaAlvo: idMesaAlvo,
          );
          if (!mounted) {
            return;
          }
          if (erro != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(erro)));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mesas unidas com sucesso.')),
          );
        },
        aoSepararGrupo: mesaAtualizada.idGrupoUniao == null
            ? null
            : () {
                Navigator.pop(contextoPainel);
                _confirmarESeparar(mesaAtualizada.idGrupoUniao!);
              },
      ),
    );
  }

  Future<void> _abrirComanda(String idMesa) async {
    final resultado = await _controlador.abrirComandaDaMesa(idMesa);
    if (!mounted || resultado == null) {
      return;
    }

    if (!resultado.reutilizouComandaExistente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nova comanda aberta para a mesa.')),
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComandaMesaPagina(
          controlador: _controlador,
          idMesa: resultado.idsMesas.first,
        ),
      ),
    );
  }

  Future<void> _confirmarELiberar(String idMesa) async {
    final confirmado = await _confirmarAcao(
      titulo: 'Liberar mesa',
      mensagem:
          'Essa ação encerra o estado atual da mesa e limpa a comanda em aberto.',
    );
    if (confirmado != true) {
      return;
    }

    await _controlador.liberarMesa(idMesa);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mesa liberada com sucesso.')));
  }

  Future<void> _confirmarESeparar(String idGrupo) async {
    final confirmado = await _confirmarAcao(
      titulo: 'Separar grupo',
      mensagem:
          'As mesas voltarão a operar individualmente. A comanda do grupo será preservada.',
    );
    if (confirmado != true) {
      return;
    }

    final erro = await _controlador.separarGrupo(idGrupo);
    if (!mounted) {
      return;
    }
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grupo separado com sucesso.')),
    );
  }

  Future<bool?> _confirmarAcao({
    required String titulo,
    required String mensagem,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GulaColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: GulaColors.border),
        ),
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _exibirErroControladorSeNecessario() {
    final erro = _controlador.erroUltimaAcao;
    if (erro == null || erro.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
  }
}

class _ResumoMapa extends StatelessWidget {
  const _ResumoMapa({
    required this.nomeArea,
    required this.total,
    required this.ocupadas,
    required this.alertas,
  });

  final String nomeArea;
  final int total;
  final int ocupadas;
  final int alertas;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: GulaColors.surfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GulaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomeArea,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GulaColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _ValorResumoMapa(
                icone: Icons.table_restaurant_outlined,
                valor: '$total mesas',
              ),
              _ValorResumoMapa(
                icone: Icons.people_outline_rounded,
                valor: '$ocupadas em uso',
              ),
              if (alertas > 0)
                _ValorResumoMapa(
                  icone: Icons.priority_high_rounded,
                  valor: '$alertas alerta${alertas == 1 ? '' : 's'}',
                  cor: GulaColors.critical,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValorResumoMapa extends StatelessWidget {
  const _ValorResumoMapa({required this.icone, required this.valor, this.cor});

  final IconData icone;
  final String valor;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final corTexto = cor ?? GulaColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: corTexto),
        const SizedBox(width: 4),
        Text(
          valor,
          style: TextStyle(
            color: corTexto,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BotaoMenuMapa extends StatelessWidget {
  const _BotaoMenuMapa({
    required this.aoExibirLegenda,
    required this.aoRestaurar,
  });

  final VoidCallback aoExibirLegenda;
  final VoidCallback aoRestaurar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AcaoMenuMapa>(
      tooltip: 'Opções do mapa',
      onSelected: (action) {
        switch (action) {
          case _AcaoMenuMapa.legenda:
            aoExibirLegenda();
          case _AcaoMenuMapa.restaurar:
            aoRestaurar();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AcaoMenuMapa.legenda,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Legenda operacional'),
          ),
        ),
        PopupMenuItem(
          value: _AcaoMenuMapa.restaurar,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.restart_alt_rounded),
            title: Text('Restaurar mapa inicial'),
          ),
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: GulaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GulaColors.border),
        ),
        child: const Icon(Icons.more_horiz_rounded, color: GulaColors.text),
      ),
    );
  }
}

enum _AcaoMenuMapa { legenda, restaurar }

// Compatibilidade com a rota registrada fora deste modulo.
typedef MesaPage = MesaPagina;
