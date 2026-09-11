import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_botao_icone.dart';
import 'package:my_app_teste/core/widgets/app_campo_formulario.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_rotulo_campo.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_patch_request.dart';
import 'package:my_app_teste/modules/comanda/dto/comanda_response.dart';
import 'package:my_app_teste/modules/comanda/service/comanda_service.dart';
import 'package:my_app_teste/modules/comanda/widgets/comanda_search_selector.dart';
import 'package:my_app_teste/modules/usuario/dto/rotulos_usuario.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';

/// Edição do que a API deixa mudar numa comanda aberta.
///
/// O `PATCH /comandas/{id}` aceita pouca coisa: observação e, em comandas
/// de mesa, o garçom responsável. Cliente, mesa e canal são decididos na
/// abertura e não mudam depois — trocá-los reescreveria a venda.
///
/// A troca de garçom é restrita a Administrador e Caixa: ela move a
/// comissão da venda de uma pessoa para outra (seção 4.2), então não é
/// decisão do próprio garçom.
class ComandaEditPage extends StatefulWidget {
  const ComandaEditPage({
    super.key,
    required this.comanda,
    required this.perfil,
  });

  final ComandaResponse comanda;

  /// Perfil do usuário logado, vindo do JWT.
  final String? perfil;

  @override
  State<ComandaEditPage> createState() => _ComandaEditPageState();
}

class _ComandaEditPageState extends State<ComandaEditPage> {
  final _service = ComandaService();
  final _observacao = TextEditingController();

  List<UsuarioResposta> _garcons = [];
  int? _garcomId;
  bool _salvando = false;
  String? _erro;

  /// Trocar o garçom move a comissão da venda — só caixa e admin podem.
  bool get _podeTrocarGarcom =>
      widget.perfil == RotulosUsuario.administrador ||
      widget.perfil == RotulosUsuario.caixa;

  /// O campo de garçom só existe em comanda de mesa: nos outros canais não
  /// há garçom responsável.
  bool get _mostraGarcom =>
      widget.comanda.tipoOrigem == 'MESA' && _podeTrocarGarcom;

  @override
  void initState() {
    super.initState();
    _observacao.text = widget.comanda.observacao ?? '';
    _garcomId = widget.comanda.garcomId;
    _carregarGarcons();
  }

  @override
  void dispose() {
    _observacao.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregarGarcons() async {
    try {
      final usuarios = await UsuarioServico().listar(
        perfil: RotulosUsuario.garcom,
      );
      if (!mounted) return;
      setState(
        () => _garcons = usuarios
            .where((u) => u.id != null && u.ativo != false)
            .toList(),
      );
    } catch (_) {
      // Sem a lista, o campo continua mostrando o garçom atual e o resto
      // da edição segue funcionando.
    }
  }

  UsuarioResposta? get _garcomSelecionado {
    for (final garcom in _garcons) {
      if (garcom.id == _garcomId) return garcom;
    }
    return null;
  }

  /// Nome do garçom escolhido. Cai no nome que veio na comanda enquanto a
  /// lista de garçons não chegou.
  String get _rotuloGarcom =>
      _garcomSelecionado?.nome ??
      _garcomSelecionado?.login ??
      widget.comanda.garcomNome ??
      '';

  Future<void> _abrirGarcom() async {
    final garcom = await abrirSeletorComBusca<UsuarioResposta>(
      context: context,
      titulo: 'Escolher garçom',
      itens: _garcons,
      tituloItem: (item) => item.nome ?? item.login ?? 'Garçom ${item.id}',
      subtituloItem: (item) => item.login ?? '',
      icone: Icons.person_outline_rounded,
      selecionado: _garcomSelecionado,
    );
    if (garcom != null && mounted) setState(() => _garcomId = garcom.id);
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await _service.patch(
        widget.comanda.id!,
        ComandaPatchRequest(
          observacao: _observacao.text.trim(),
          // Só envia o garçom quando ele de fato mudou: o PATCH trata
          // campo ausente como "não mexer".
          garcomId: _mostraGarcom && _garcomId != widget.comanda.garcomId
              ? _garcomId
              : null,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    body: SafeArea(
      child: Column(
        children: [
          _cabecalho(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                _tituloSecao('INFORMAÇÕES EDITÁVEIS'),
                const SizedBox(height: 10),
                const AppRotuloCampo('Observação'),
                const SizedBox(height: 8),
                AppCampoFormulario(
                  controlador: _observacao,
                  dica: 'Ex.: sem cebola, separar bebidas',
                  maxLinhas: 4,
                ),
                if (_mostraGarcom) ...[
                  const SizedBox(height: 18),
                  CampoSeletorComanda(
                    rotulo: 'Garçom responsável',
                    valor: _rotuloGarcom,
                    icone: Icons.person_outline_rounded,
                    aoTocar: _abrirGarcom,
                  ),
                ],
                const SizedBox(height: 18),
                const AppCartaoAviso.dica(
                  'Cliente, mesa e canal são definidos na abertura da '
                  'comanda e não mudam depois.',
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 14),
                  AppCartaoAviso.erro(_erro),
                ],
              ],
            ),
          ),
          _rodape(),
        ],
      ),
    ),
  );

  Widget _cabecalho() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Row(
      children: [
        AppBotaoIcone(
          icone: Icons.arrow_back_rounded,
          aoTocar: () => Navigator.pop(context, false),
          dicaAcessibilidade: 'Voltar',
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar comanda',
                style: TextStyle(
                  color: AppTema.texto,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.comanda.codigo,
                style: const TextStyle(
                  color: AppTema.textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tituloSecao(String titulo) => Text(
    titulo,
    style: const TextStyle(
      color: AppTema.textoSecundario,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    ),
  );

  Widget _rodape() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _salvando ? null : _salvar,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salvar alterações'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTema.primaria,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    ),
  );
}
