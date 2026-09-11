import 'package:flutter/material.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_interruptor.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/dto/validacao_entregador.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';

/// Cadastro e edição de entregador.
///
/// Cuida de estado e envio; as regras vivem em [ValidadorEntregador].
///
/// O telefone é enviado só com dígitos: o entregador recebe a comanda
/// impressa e é contatado por esse número, e a máscara não deve virar parte
/// do dado.
class EntregadorFormPage extends StatefulWidget {
  final EntregadorResponse? entregador;

  /// Permite injetar um service nos testes.
  final EntregadorService? service;

  const EntregadorFormPage({super.key, this.entregador, this.service});

  bool get ehEdicao => entregador != null;

  @override
  State<EntregadorFormPage> createState() => _EntregadorFormPageState();
}

class _EntregadorFormPageState extends State<EntregadorFormPage> {
  late final EntregadorService _service = widget.service ?? EntregadorService();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();

  DadosEntregador _dados = const DadosEntregador();
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final entregador = widget.entregador;
    if (entregador == null) return;
    _nome.text = entregador.nome;
    _telefone.text = TelefoneFormatter.formatar(entregador.telefone);
    _dados = DadosEntregador(ativo: entregador.ativo);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  /// Junta o que está nos controllers ao que está em [_dados].
  DadosEntregador get _dadosCompletos =>
      _dados.copiarCom(nome: _nome.text, telefone: _telefone.text);

  Future<void> _salvar() async {
    final dados = _dadosCompletos;
    final erroValidacao = ValidadorEntregador.validar(dados);
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      if (widget.ehEdicao) {
        await _service.atualizar(widget.entregador!.id!, dados.paraEdicao());
      } else {
        await _service.criar(dados.paraCriacao());
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Erro inesperado ao salvar o entregador.');
      }
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
    appBar: AppBar(
      backgroundColor: AppTema.fundo,
      foregroundColor: AppTema.texto,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTema.primariaEscura),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.ehEdicao ? 'Editar entregador' : 'Novo entregador',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTema.texto,
            ),
          ),
          Text(
            widget.ehEdicao ? 'Cadastro · Edição' : 'Cadastro · Novo',
            style: const TextStyle(
              fontSize: 12,
              color: AppTema.textoSecundario,
            ),
          ),
        ],
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          const AppRotulo('Nome completo'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _nome,
            dica: 'Ex.: Carlos Silva',
            tamanhoMax: 120,
            prefixo: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(height: 14),
          const AppRotulo('Telefone'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _telefone,
            dica: 'Ex.: (11) 99999-0000',
            tamanhoMax: TelefoneFormatter.maxCaracteresFormatados,
            tipoTeclado: TextInputType.phone,
            prefixo: const Icon(Icons.phone_outlined),
            formatadores: const [TelefoneFormatter()],
          ),
          if (widget.ehEdicao) ...[
            const SizedBox(height: 18),
            AppCampoInterruptor(
              titulo: 'Entregador ativo',
              descricao: _dados.ativo
                  ? 'Disponível para operações de entrega.'
                  : 'Não aparecerá na listagem operacional.',
              valor: _dados.ativo,
              aoMudar: (v) =>
                  setState(() => _dados = _dados.copiarCom(ativo: v)),
            ),
          ] else ...[
            const SizedBox(height: 18),
            const AppDica(
              'Novos entregadores são criados ativos. A criação envia apenas '
              'nome e telefone.',
            ),
          ],
          if (_erro != null) ...[
            const SizedBox(height: 14),
            AppCartaoAviso.erro(_erro),
          ],
        ],
      ),
    ),
    bottomNavigationBar: AppBarraAcoes(
      textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
      carregando: _salvando,
      aoCancelar: () => Navigator.pop(context, false),
      aoConfirmar: _salvar,
    ),
  );
}
