// lib/modules/cliente/page/cliente_form_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import '../dto/cliente_create_request.dart';
import '../dto/cliente_endereco.dart';
import '../dto/cliente_response.dart';
import '../dto/cliente_update_request.dart';
import '../service/cliente_service.dart';

class ClienteFormPage extends StatefulWidget {
  final ClienteResponse? cliente;

  const ClienteFormPage({super.key, this.cliente});

  bool get ehEdicao => cliente != null;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _chaveFormulario = GlobalKey<FormState>();

  final _controleNome = TextEditingController();
  final _controleTelefone = TextEditingController();
  final _controleEmail = TextEditingController();
  final _controleCep = TextEditingController();
  final _controleLogradouro = TextEditingController();
  final _controleNumero = TextEditingController();
  final _controleComplemento = TextEditingController();
  final _controleBairro = TextEditingController();
  final _controleCidade = TextEditingController();
  final _controleUf = TextEditingController();

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    if (c != null) {
      _controleNome.text = c.nome ?? '';
      _controleTelefone.text = c.telefone ?? '';
      _controleEmail.text = c.email ?? '';
      if (c.endereco != null) {
        _controleCep.text = c.endereco!.cep ?? '';
        _controleLogradouro.text = c.endereco!.logradouro ?? '';
        _controleNumero.text = c.endereco!.numero ?? '';
        _controleComplemento.text = c.endereco!.complemento ?? '';
        _controleBairro.text = c.endereco!.bairro ?? '';
        _controleCidade.text = c.endereco!.cidade ?? '';
        _controleUf.text = c.endereco!.uf ?? '';
      }
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleTelefone.dispose();
    _controleEmail.dispose();
    _controleCep.dispose();
    _controleLogradouro.dispose();
    _controleNumero.dispose();
    _controleComplemento.dispose();
    _controleBairro.dispose();
    _controleCidade.dispose();
    _controleUf.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final endereco = ClienteEndereco(
      cep: _controleCep.text.trim(),
      logradouro: _controleLogradouro.text.trim(),
      numero: _controleNumero.text.trim(),
      complemento: _controleComplemento.text.trim(),
      bairro: _controleBairro.text.trim(),
      cidade: _controleCidade.text.trim(),
      uf: _controleUf.text.trim(),
    );

    setState(() => _carregando = true);
    try {
      if (widget.ehEdicao) {
        final dto = ClienteUpdateRequest(
          nome: _controleNome.text.trim(),
          telefone: _controleTelefone.text.trim(),
          email: _controleEmail.text.trim(),
          endereco: endereco,
          ativo: widget.cliente!.ativo ?? true,
        );
        await editarCliente(widget.cliente!.id as int, dto);
      } else {
        final dto = ClienteCreateRequest(
          nome: _controleNome.text.trim(),
          telefone: _controleTelefone.text.trim(),
          email: _controleEmail.text.trim(),
          endereco: endereco,
        );
        await criarCliente(dto);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.ehEdicao ? 'Editar cliente' : 'Novo cliente',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            Text(
              widget.ehEdicao ? 'Cadastro · Edição' : 'Cadastro · Novo',
              style: const TextStyle(
                  fontSize: 12, color: AppTema.textoSecundario),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppRotulo('Nome completo *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleNome,
                        dica: 'Ex.: João da Silva',
                        tamanhoMax: 120,
                        validador: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome';
                          if (t.length < 3) return 'Mínimo de 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Telefone (WhatsApp) *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleTelefone,
                        dica: 'Ex.: 11999990000',
                        tipoTeclado: TextInputType.phone,
                        tamanhoMax: 20,
                        validador: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o telefone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('E-mail *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleEmail,
                        dica: 'Ex.: joao@email.com',
                        tipoTeclado: TextInputType.emailAddress,
                        tamanhoMax: 150,
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppTema.bordaCampo),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          FaIcon(FontAwesomeIcons.locationDot,
                              size: 14, color: AppTema.primariaEscura),
                          SizedBox(width: 8),
                          Text('Endereço',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTema.textoEscuro)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('CEP *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleCep,
                        dica: 'Ex.: 01310-100',
                        tipoTeclado: TextInputType.number,
                        tamanhoMax: 9,
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Logradouro *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleLogradouro,
                        dica: 'Ex.: Av. Paulista',
                        tamanhoMax: 150,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppRotulo('Número *'),
                                const SizedBox(height: 6),
                                AppCampoTexto(
                                  controle: _controleNumero,
                                  dica: 'Ex.: 1578',
                                  tamanhoMax: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppRotulo('Complemento', opcional: true),
                                const SizedBox(height: 6),
                                AppCampoTexto(
                                  controle: _controleComplemento,
                                  dica: 'Ex.: Apto 42',
                                  tamanhoMax: 60,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Bairro *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleBairro,
                        dica: 'Ex.: Bela Vista',
                        tamanhoMax: 80,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppRotulo('Cidade *'),
                                const SizedBox(height: 6),
                                AppCampoTexto(
                                  controle: _controleCidade,
                                  dica: 'Ex.: São Paulo',
                                  tamanhoMax: 80,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppRotulo('UF *'),
                                const SizedBox(height: 6),
                                AppCampoTexto(
                                  controle: _controleUf,
                                  dica: 'SP',
                                  tamanhoMax: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const AppDica(
                        'Os campos são obrigatórios e devem ser peenchidos para salver o cliente. '
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
              iconeConfirmar:
                  const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              carregando: _carregando,
              aoCancelar: () => Navigator.pop(context),
              aoConfirmar: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
