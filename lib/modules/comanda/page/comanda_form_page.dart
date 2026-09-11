import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_cabecalho_wizard.dart';
import 'package:my_app_teste/core/widgets/app_rodape_wizard.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';
import 'package:my_app_teste/modules/comanda/dto/validacao_comanda.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import 'package:my_app_teste/modules/comanda/widgets/comanda_search_selector.dart';
import 'package:my_app_teste/modules/comanda/widgets/form/etapas_comanda.dart';
import 'package:my_app_teste/modules/mesa/dto/mesa_dto.dart';
import 'package:my_app_teste/modules/mesa/service/mesa_service.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';

/// Abertura de comanda, em 4 etapas: canal, cliente, dados e revisão.
///
/// Esta classe cuida apenas de estado, navegação entre etapas e envio. A
/// aparência de cada etapa vive em `widgets/form/` e as regras por canal
/// em [ValidadorComanda].
class ComandaFormPage extends StatefulWidget {
  const ComandaFormPage({super.key});

  @override
  State<ComandaFormPage> createState() => _ComandaFormPageState();
}

class _ComandaFormPageState extends State<ComandaFormPage> {
  static const _totalEtapas = 4;
  static const _rotulosEtapa = [
    'Canal da venda',
    'Cliente',
    'Dados da venda',
    'Revisão',
  ];

  final _service = ComandaService();
  final _observacao = TextEditingController();

  List<MesaDto> _mesas = [];
  List<ClienteResponse> _clientes = [];
  List<UsuarioResposta> _garcons = [];

  DadosComanda _dados = const DadosComanda();
  int _etapa = 0;
  bool _salvando = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _observacao.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregarOpcoes() async {
    try {
      final resultado = await Future.wait([
        MesaService().listarMesas(),
        listarClientes(apenasAtivos: false),
        UsuarioServico().listar(perfil: 'GARCOM'),
      ]);
      if (!mounted) return;
      setState(() {
        _mesas = resultado[0] as List<MesaDto>;
        _clientes = resultado[1] as List<ClienteResponse>;
        _garcons = resultado[2] as List<UsuarioResposta>;
      });
    } catch (_) {
      _avisar('Não foi possível carregar mesas, clientes e garçons.');
    }
  }

  MesaDto? get _mesaSelecionada {
    for (final mesa in _mesas) {
      if (mesa.id == _dados.mesaId) return mesa;
    }
    return null;
  }

  UsuarioResposta? get _garcomSelecionado {
    for (final garcom in _garcons) {
      if (garcom.id == _dados.garcomId) return garcom;
    }
    return null;
  }

  String get _rotuloMesa {
    final mesa = _mesaSelecionada;
    return mesa == null ? '' : 'Mesa ${mesa.numero ?? mesa.id}';
  }

  String get _rotuloGarcom {
    final garcom = _garcomSelecionado;
    return garcom?.nome ?? garcom?.login ?? '';
  }

  // ---------------------------------------------------------------------
  // Validação e navegação
  // ---------------------------------------------------------------------

  void _atualizar(DadosComanda novo) {
    setState(() {
      _dados = novo;
      _mensagemErro = null;
    });
  }

  void _avancar() {
    final erro = ValidadorComanda.validarEtapa(_etapa, _dados);
    setState(() => _mensagemErro = erro);
    if (erro != null) return;

    if (_etapa < _totalEtapas - 1) {
      setState(() => _etapa++);
      return;
    }
    _enviar();
  }

  void _voltar() {
    if (_etapa == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _etapa--;
      _mensagemErro = null;
    });
  }

  Future<void> _enviar() async {
    setState(() => _salvando = true);
    try {
      final dados = _dados.copiarCom(observacao: _observacao.text);
      await _service.criar(dados.paraRequisicao());
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) {
      _avisar(e.message);
    } catch (_) {
      _avisar('Não foi possível abrir a comanda.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // ---------------------------------------------------------------------
  // Seleções
  // ---------------------------------------------------------------------

  Future<void> _abrirCliente() async {
    final cliente = await abrirSeletorComBusca<ClienteResponse>(
      context: context,
      titulo: 'Escolher cliente',
      itens: _clientes.where((c) => c.id != null).toList(),
      tituloItem: (c) => c.nome ?? 'Cliente ${c.id}',
      subtituloItem: (c) => c.telefone ?? '',
      icone: Icons.person_outline_rounded,
      selecionado: _dados.cliente,
    );
    if (cliente != null && mounted) {
      _atualizar(_dados.copiarCom(cliente: cliente));
    }
  }

  Future<void> _abrirMesa() async {
    final mesa = await abrirSeletorComBusca<MesaDto>(
      context: context,
      titulo: 'Escolher mesa',
      itens: _mesas.where((m) => m.id != null).toList(),
      tituloItem: (m) => 'Mesa ${m.numero ?? m.id}',
      subtituloItem: (m) => m.descricao ?? '',
      icone: Icons.table_restaurant_rounded,
      selecionado: _mesaSelecionada,
    );
    if (mesa != null && mounted) {
      _atualizar(_dados.copiarCom(mesaId: mesa.id));
    }
  }

  Future<void> _abrirGarcom() async {
    final garcom = await abrirSeletorComBusca<UsuarioResposta>(
      context: context,
      titulo: 'Escolher garçom',
      itens: _garcons,
      tituloItem: (g) => g.nome ?? g.login ?? 'Garçom ${g.id}',
      subtituloItem: (g) => g.login ?? '',
      icone: Icons.person_outline_rounded,
      selecionado: _garcomSelecionado,
    );
    if (garcom != null && mounted) {
      _atualizar(_dados.copiarCom(garcomId: garcom.id));
    }
  }

  Future<void> _abrirEscopo() async {
    final escopo = await abrirSeletorComBusca<String>(
      context: context,
      titulo: 'Tipo de comanda',
      itens: const [
        DadosComanda.escopoIndividual,
        DadosComanda.escopoCompartilhada,
      ],
      tituloItem: rotuloEscopo,
      icone: Icons.group_outlined,
      selecionado: _dados.escopo,
      limiteInicial: 2,
    );
    if (escopo != null && mounted) {
      _atualizar(_dados.copiarCom(escopo: escopo));
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  Widget _corpoDaEtapa() {
    switch (_etapa) {
      case 0:
        return EtapaCanal(
          canalSelecionado: _dados.tipo,
          aoSelecionar: (canal) => _atualizar(_dados.copiarCom(tipo: canal)),
        );
      case 1:
        return EtapaCliente(
          dados: _dados,
          mensagemErro: _mensagemErro,
          aoAbrirCliente: _abrirCliente,
        );
      case 2:
        return EtapaDados(
          dados: _dados,
          rotuloMesa: _rotuloMesa,
          rotuloGarcom: _rotuloGarcom,
          mensagemErro: _mensagemErro,
          aoAbrirMesa: _abrirMesa,
          aoAbrirGarcom: _abrirGarcom,
          aoAbrirEscopo: _abrirEscopo,
        );
      default:
        return EtapaRevisao(
          dados: _dados,
          rotuloMesa: _rotuloMesa,
          rotuloGarcom: _rotuloGarcom,
          controladorObservacao: _observacao,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimaEtapa = _etapa == _totalEtapas - 1;
    return Scaffold(
      backgroundColor: AppTema.fundo,
      body: SafeArea(
        child: Column(
          children: [
            AppCabecalhoWizard(
              titulo: 'Nova comanda',
              etapa: _etapa,
              totalEtapas: _totalEtapas,
              rotuloEtapa: _rotulosEtapa[_etapa],
              aoVoltar: _voltar,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _corpoDaEtapa(),
              ),
            ),
            AppRodapeWizard(
              rotuloEsquerda: _etapa == 0 ? 'Cancelar' : 'Voltar',
              rotuloDireita: ultimaEtapa ? 'Abrir comanda' : 'Continuar',
              iconeDireita: ultimaEtapa
                  ? Icons.check_rounded
                  : Icons.chevron_right_rounded,
              carregando: _salvando,
              aoVoltar: _voltar,
              aoAvancar: _avancar,
            ),
          ],
        ),
      ),
    );
  }
}
