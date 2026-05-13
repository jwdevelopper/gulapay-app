import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_create_request.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';

class UsuarioFormularioPagina extends StatefulWidget {
  final UsuarioResposta? usuario;
  const UsuarioFormularioPagina({super.key, this.usuario});

  bool get ehEdicao => usuario != null;

  @override
  State<UsuarioFormularioPagina> createState() =>
      _UsuarioFormularioPaginaState();
}

class _UsuarioFormularioPaginaState extends State<UsuarioFormularioPagina> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _servico = UsuarioServico();

  final _controleNome = TextEditingController();
  final _controleLogin = TextEditingController();
  final _controleSenha = TextEditingController();
  final _controleComissao = TextEditingController();

  String _perfil = 'CAIXA';
  bool _ocultarSenha = true;
  bool _carregando = false;

  static const _perfis = <String>['ADMINISTRADOR', 'CAIXA', 'GARCOM'];

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    if (u != null) {
      _controleNome.text = u.nome ?? '';
      _controleLogin.text = u.login ?? '';
      _perfil = u.perfil ?? 'CAIXA';
      _controleComissao.text =
          u.percentualComissao == null ? '' : u.percentualComissao.toString();
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleLogin.dispose();
    _controleSenha.dispose();
    _controleComissao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (widget.ehEdicao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Edição de usuário ainda não disponível no backend (PUT /usuarios/{id}).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_chaveFormulario.currentState!.validate()) return;

    final comissaoTxt = _controleComissao.text.trim().replaceAll(',', '.');
    final requisicao = UsuarioCriarRequisicao(
      login: _controleLogin.text.trim(),
      nome: _controleNome.text.trim(),
      senha: _controleSenha.text,
      perfil: _perfil,
      percentualComissao: _perfil != 'GARCOM' || comissaoTxt.isEmpty
          ? null
          : double.tryParse(comissaoTxt),
    );

    setState(() => _carregando = true);
    try {
      await _servico.criar(requisicao);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro: ${e.message}'),
            backgroundColor: Colors.red),
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
              widget.ehEdicao ? 'Editar usuário' : 'Novo usuário',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            const Text(
              'Cadastro · Identidade',
              style: TextStyle(fontSize: 12, color: AppTema.textoSecundario),
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
                      const AppRotulo('Nome *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleNome,
                        dica: 'Ex.: Maria da Silva',
                        tamanhoMax: 120,
                        validador: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome';
                          if (t.length < 3) return 'Mínimo de 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Login *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleLogin,
                        dica: 'Ex.: maria.silva',
                        tamanhoMax: 60,
                        validador: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o login';
                          if (t.length < 3) return 'Mínimo de 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppRotulo(
                          widget.ehEdicao ? 'Senha (manter atual)' : 'Senha *'),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleSenha,
                        dica: 'Mínimo de 6 caracteres',
                        ocultar: _ocultarSenha,
                        tamanhoMax: 100,
                        sufixo: IconButton(
                          onPressed: () =>
                              setState(() => _ocultarSenha = !_ocultarSenha),
                          icon: FaIcon(
                            _ocultarSenha
                                ? FontAwesomeIcons.eyeSlash
                                : FontAwesomeIcons.eye,
                            color: AppTema.primariaEscura,
                            size: 18,
                          ),
                        ),
                        validador: (v) {
                          if (widget.ehEdicao) return null;
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          if (v.length < 6) return 'Mínimo de 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const AppRotulo('Perfil *'),
                      const SizedBox(height: 6),
                      _construirSeletorPerfil(),
                      if (_perfil == 'GARCOM') ...[
                        const SizedBox(height: 14),
                        const AppRotulo('Percentual de comissão',
                            opcional: true),
                        const SizedBox(height: 6),
                        AppCampoTexto(
                          controle: _controleComissao,
                          dica: '0,00 a 100,00',
                          tipoTeclado: const TextInputType.numberWithOptions(
                              decimal: true),
                          formatadores: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                          validador: (v) {
                            final t = v?.trim().replaceAll(',', '.') ?? '';
                            if (t.isEmpty) return null;
                            final n = double.tryParse(t);
                            if (n == null) return 'Valor inválido';
                            if (n < 0 || n > 100) return 'Entre 0 e 100';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      const AppDica(
                        'Apenas administradores podem cadastrar usuários. '
                        'O login deve ser único; senha mínima de 6 caracteres.',
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

  Widget _construirSeletorPerfil() {
    return Container(
      decoration: BoxDecoration(
        color: AppTema.cartao,
        border: Border.all(color: AppTema.bordaCampo),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _perfil,
          isExpanded: true,
          icon: const FaIcon(FontAwesomeIcons.chevronDown,
              size: 14, color: AppTema.primariaEscura),
          style: const TextStyle(color: AppTema.textoEscuro, fontSize: 16),
          onChanged: (v) => setState(() {
            _perfil = v ?? 'CAIXA';
            if (_perfil != 'GARCOM') _controleComissao.clear();
          }),
          items: _perfis
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
        ),
      ),
    );
  }
}
