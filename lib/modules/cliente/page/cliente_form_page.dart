import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/cep_formatter.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/cliente/dto/validacao_cliente.dart';
import 'package:my_app_teste/modules/cliente/service/cliente_service.dart';

/// Cadastro e edição de cliente.
///
/// Cuida de estado e envio; as regras vivem em [ValidadorCliente].
///
/// Nome e telefone são obrigatórios — o telefone identifica o cliente em
/// todo pedido (seção 3.6) e é enviado só com dígitos, para o mesmo cliente
/// não entrar duas vezes por causa da máscara. O endereço é opcional, mas
/// tudo ou nada: só o canal `DELIVERY` exige um, e meio endereço não
/// entrega pedido nenhum.
class ClienteFormPage extends StatefulWidget {
  final ClienteResponse? cliente;

  const ClienteFormPage({super.key, this.cliente});

  bool get ehEdicao => cliente != null;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _cep = TextEditingController();
  final _logradouro = TextEditingController();
  final _numero = TextEditingController();
  final _complemento = TextEditingController();
  final _bairro = TextEditingController();
  final _cidade = TextEditingController();
  final _uf = TextEditingController();

  DadosCliente _dados = const DadosCliente();
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    if (cliente == null) return;

    _nome.text = cliente.nome ?? '';
    _telefone.text = TelefoneFormatter.formatar(cliente.telefone);
    _email.text = cliente.email ?? '';
    final endereco = cliente.endereco;
    if (endereco != null) {
      _cep.text = CepFormatter.formatar(endereco.cep);
      _logradouro.text = endereco.logradouro ?? '';
      _numero.text = endereco.numero ?? '';
      _complemento.text = endereco.complemento ?? '';
      _bairro.text = endereco.bairro ?? '';
      _cidade.text = endereco.cidade ?? '';
      _uf.text = endereco.uf ?? '';
    }
    _dados = DadosCliente(ativo: cliente.ativo ?? true);
  }

  @override
  void dispose() {
    for (final controle in [
      _nome,
      _telefone,
      _email,
      _cep,
      _logradouro,
      _numero,
      _complemento,
      _bairro,
      _cidade,
      _uf,
    ]) {
      controle.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  /// Lê os controllers para o objeto de valor, preservando o `ativo`.
  DadosCliente get _dadosCompletos => _dados.comCampos(
    nome: _nome.text,
    telefone: _telefone.text,
    email: _email.text,
    cep: _cep.text,
    logradouro: _logradouro.text,
    numero: _numero.text,
    complemento: _complemento.text,
    bairro: _bairro.text,
    cidade: _cidade.text,
    uf: _uf.text,
  );

  Future<void> _salvar() async {
    final dados = _dadosCompletos;
    final erroValidacao = ValidadorCliente.validar(dados);
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
        await editarCliente(widget.cliente!.id!, dados.paraEdicao());
      } else {
        await criarCliente(dados.paraCriacao());
      }
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
    appBar: AppBar(
      backgroundColor: AppTema.fundo,
      foregroundColor: AppTema.texto,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTema.primariaEscura),
      title: Text(
        widget.ehEdicao ? 'Editar cliente' : 'Novo cliente',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTema.texto,
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          _campo(
            'Nome completo',
            _nome,
            dica: 'Ex.: João da Silva',
            tamanhoMax: 120,
            formatadores: [
              FilteringTextInputFormatter.allow(ValidadorCliente.nomePermitido),
            ],
          ),
          const SizedBox(height: 14),
          _campo(
            'Telefone (WhatsApp)',
            _telefone,
            dica: 'Ex.: (11) 99999-0000',
            tipoTeclado: TextInputType.phone,
            tamanhoMax: TelefoneFormatter.maxCaracteresFormatados,
            formatadores: const [TelefoneFormatter()],
          ),
          const SizedBox(height: 14),
          _campo(
            'E-mail',
            _email,
            dica: 'Ex.: joao@email.com',
            tipoTeclado: TextInputType.emailAddress,
            tamanhoMax: 150,
            opcional: true,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTema.borda),
          const SizedBox(height: 8),
          _tituloEndereco(),
          const SizedBox(height: 14),
          _campo(
            'CEP',
            _cep,
            dica: 'Ex.: 01310-100',
            tipoTeclado: TextInputType.number,
            tamanhoMax: CepFormatter.maxCaracteresFormatados,
            formatadores: const [CepFormatter()],
            opcional: true,
          ),
          const SizedBox(height: 14),
          _campo(
            'Logradouro',
            _logradouro,
            dica: 'Ex.: Av. Paulista',
            tamanhoMax: 150,
            opcional: true,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _campo(
                  'Número',
                  _numero,
                  dica: 'Ex.: 1578',
                  tamanhoMax: 10,
                  opcional: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _campo(
                  'Complemento',
                  _complemento,
                  dica: 'Ex.: Apto 42',
                  tamanhoMax: 60,
                  opcional: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _campo(
            'Bairro',
            _bairro,
            dica: 'Ex.: Bela Vista',
            tamanhoMax: 80,
            opcional: true,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _campo(
                  'Cidade',
                  _cidade,
                  dica: 'Ex.: São Paulo',
                  tamanhoMax: 80,
                  opcional: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(
                  'UF',
                  _uf,
                  dica: 'SP',
                  tamanhoMax: 2,
                  opcional: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const AppDica(
            'O endereço só é exigido em comandas de delivery — mas, se '
            'preencher, complete: logradouro, número, bairro, cidade e UF.',
          ),
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

  Widget _tituloEndereco() => const Row(
    children: [
      FaIcon(
        FontAwesomeIcons.locationDot,
        size: 14,
        color: AppTema.primariaEscura,
      ),
      SizedBox(width: 8),
      Text(
        'Endereço',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppTema.texto),
      ),
    ],
  );

  Widget _campo(
    String rotulo,
    TextEditingController controle, {
    required String dica,
    int? tamanhoMax,
    TextInputType? tipoTeclado,
    List<TextInputFormatter>? formatadores,
    bool opcional = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRotulo(rotulo, opcional: opcional),
      const SizedBox(height: 6),
      AppCampoTexto(
        controle: controle,
        dica: dica,
        tamanhoMax: tamanhoMax,
        tipoTeclado: tipoTeclado,
        formatadores: formatadores,
      ),
    ],
  );
}
