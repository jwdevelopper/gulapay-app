import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/telefone_formatter.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_create_request.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_response.dart';
import 'package:my_app_teste/modules/entregador/dto/entregador_update_request.dart';
import 'package:my_app_teste/modules/entregador/service/entregador_service.dart';

class EntregadorFormPage extends StatefulWidget {
  final EntregadorResponse? entregador;
  final EntregadorService? service;

  const EntregadorFormPage({super.key, this.entregador, this.service});

  bool get isEditing => entregador != null;

  @override
  State<EntregadorFormPage> createState() => _EntregadorFormPageState();
}

class _EntregadorFormPageState extends State<EntregadorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final EntregadorService _service;

  bool _active = true;
  bool _loading = false;

  static final RegExp _phonePattern = RegExp(r'^\+?[0-9 ()-]{8,20}$');

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EntregadorService();
    final entregador = widget.entregador;
    if (entregador != null) {
      _nameController.text = entregador.nome;
      _phoneController.text = TelefoneFormatter.formatar(entregador.telefone);
      _active = entregador.ativo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    setState(() => _loading = true);

    try {
      if (widget.isEditing) {
        await _service.atualizar(
          widget.entregador!.id!,
          EntregadorUpdateRequest(nome: name, telefone: phone, ativo: _active),
        );
      } else {
        await _service.criar(
          EntregadorCreateRequest(nome: name, telefone: phone),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao salvar o entregador.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe o nome';
    if (name.length < 2) return 'Mínimo de 2 caracteres';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Informe o telefone';
    if (!_phonePattern.hasMatch(phone)) {
      return 'Use de 8 a 20 caracteres: números, espaços, +, ( ), ou -';
    }
    return null;
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
              widget.isEditing ? 'Editar entregador' : 'Novo entregador',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            Text(
              widget.isEditing ? 'Cadastro · Edição' : 'Cadastro · Novo',
              style: const TextStyle(
                fontSize: 12,
                color: AppTema.textoSecundario,
              ),
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppRotulo('Nome completo *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _nameController,
                        dica: 'Ex.: Carlos Silva',
                        tamanhoMax: 120,
                        prefixo: const Icon(Icons.person_outline_rounded),
                        validador: _validateName,
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Telefone *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _phoneController,
                        dica: 'Ex.: (11) 99999-0000',
                        tamanhoMax: TelefoneFormatter.maxCaracteresFormatados,
                        tipoTeclado: TextInputType.phone,
                        prefixo: const Icon(Icons.phone_outlined),
                        formatadores: const [TelefoneFormatter()],
                        validador: _validatePhone,
                      ),
                      if (widget.isEditing) ...[
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTema.cartao,
                            border: Border.all(color: AppTema.bordaCampo),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SwitchListTile.adaptive(
                            value: _active,
                            onChanged: (value) =>
                                setState(() => _active = value),
                            activeTrackColor: AppTema.primaria,
                            title: const Text(
                              'Entregador ativo',
                              style: TextStyle(
                                color: AppTema.textoEscuro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _active
                                  ? 'Disponível para operações de entrega'
                                  : 'Não aparecerá na listagem operacional',
                              style: const TextStyle(
                                color: AppTema.textoSecundario,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!widget.isEditing) ...[
                        const SizedBox(height: 18),
                        const AppDica(
                          'Novos entregadores são criados ativos. A criação envia apenas nome e telefone.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.isEditing ? 'Atualizar' : 'Salvar',
              iconeConfirmar: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
              ),
              carregando: _loading,
              aoCancelar: () => Navigator.pop(context),
              aoConfirmar: _save,
            ),
          ],
        ),
      ),
    );
  }
}
