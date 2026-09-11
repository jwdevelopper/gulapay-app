import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_response.dart';
import 'package:my_app_teste/modules/comanda/dto/filtro_comandas.dart';
import 'package:my_app_teste/modules/comanda/page/comanda_detalhe_page.dart';
import 'package:my_app_teste/modules/comanda/page/comanda_form_page.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import 'package:my_app_teste/modules/comanda/widgets/cartao_comanda.dart';
import 'package:my_app_teste/modules/comanda/widgets/filtros_comandas.dart';

/// Listagem de comandas, com filtro por status e por canal de venda.
///
/// Cuida apenas de estado, carga e navegação. Os chips vivem em
/// [FiltrosComandas], cada linha em [CartaoComanda] e o filtro em si é o
/// objeto de valor [FiltroComandas].
class ComandasPage extends StatefulWidget {
  const ComandasPage({super.key});

  @override
  State<ComandasPage> createState() => _ComandasPageState();
}

class _ComandasPageState extends State<ComandasPage> {
  final _service = ComandaService();

  List<ComandaResponse> _comandas = [];
  FiltroComandas _filtro = const FiltroComandas();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  /// Recarrega a lista com o filtro atual.
  ///
  /// [mostrarCarregando] é falso no "puxar para atualizar": ali o próprio
  /// `RefreshIndicator` já dá o retorno visual, e trocar a lista pelo
  /// indicador de tela cheia faria o conteúdo piscar.
  Future<void> _carregar({bool mostrarCarregando = true}) async {
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    String? erro;
    List<ComandaResponse> comandas = const [];
    try {
      comandas = await _service.listar(
        status: _filtro.status,
        tipoOrigem: _filtro.tipoOrigem,
      );
    } on ApiError catch (e) {
      erro = e.message;
    } catch (_) {
      erro = 'Não foi possível carregar as comandas.';
    }
    if (!mounted) return;
    setState(() {
      _erro = erro;
      if (erro == null) _comandas = comandas;
      _carregando = false;
    });
  }

  void _aplicarFiltro(FiltroComandas novo) {
    setState(() => _filtro = novo);
    _carregar();
  }

  // ---------------------------------------------------------------------
  // Navegação
  // ---------------------------------------------------------------------

  Future<void> _abrirNovaComanda() async {
    final criada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ComandaFormPage()),
    );
    if (criada == true) _carregar();
  }

  Future<void> _abrirDetalhe(ComandaResponse comanda) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComandaDetalhePage(id: comanda.id!)),
    );
    if (mounted) _carregar();
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    floatingActionButton: FloatingActionButton(
      onPressed: _abrirNovaComanda,
      backgroundColor: AppTema.primaria,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          FiltrosComandas(filtro: _filtro, aoMudar: _aplicarFiltro),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _carregar(mostrarCarregando: false),
              color: AppTema.primaria,
              child: _corpo(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _corpo() {
    if (_carregando) return const AppCarregando();
    if (_erro != null) return _rolavel(_estadoErro());
    if (_comandas.isEmpty) return _rolavel(_estadoVazio());

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: _comandas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => CartaoComanda(
        comanda: _comandas[i],
        aoTocar: () => _abrirDetalhe(_comandas[i]),
      ),
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 96),
    children: [filho],
  );

  Widget _estadoErro() => AppEstadoVazio(
    icone: Icons.cloud_off_rounded,
    titulo: 'Não foi possível carregar',
    mensagem: _erro!,
    rotuloBotao: 'Tentar novamente',
    iconeBotao: Icons.refresh_rounded,
    aoTocarBotao: _carregar,
  );

  Widget _estadoVazio() => _filtro.vazio
      ? AppEstadoVazio(
          icone: Icons.receipt_long_outlined,
          titulo: 'Nenhuma comanda aberta',
          mensagem: 'Abra a primeira comanda para começar a vender.',
          rotuloBotao: 'Nova comanda',
          aoTocarBotao: _abrirNovaComanda,
        )
      : AppEstadoVazio(
          icone: Icons.search_off_rounded,
          titulo: 'Nada encontrado',
          mensagem: 'Nenhuma comanda corresponde aos filtros aplicados.',
          rotuloBotao: 'Limpar filtros',
          iconeBotao: Icons.filter_alt_off_rounded,
          secundario: true,
          aoTocarBotao: () => _aplicarFiltro(const FiltroComandas()),
        );
}
