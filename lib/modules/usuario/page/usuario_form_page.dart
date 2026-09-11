import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/usuario/dto/rotulos_usuario.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/dto/validacao_usuario.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';

/// Cadastro de usuário com login.
///
/// Cuida de estado e envio; as regras vivem em [ValidadorUsuario].
///
/// **A edição ainda não existe.** O backend expõe apenas `POST /usuarios`,
/// `GET /usuarios` e `GET /usuarios/me` — não há `PUT`. Com um [usuario]
/// informado, a tela abre em modo consulta: os campos ficam travados e o
/// aviso no topo explica o porquê, em vez de deixar o usuário preencher
/// tudo para só então descobrir que não dá para salvar.
class UsuarioFormularioPagina extends StatefulWidget {
  final UsuarioResposta? usuario;

  const UsuarioFormularioPagina({super.key, this.usuario});

  /// Verdadeiro quando a tela abre sobre um usuário existente — hoje,
  /// somente para consulta.
  bool get ehConsulta => usuario != null;

  @override
  State<UsuarioFormularioPagina> createState() =>
      _UsuarioFormularioPaginaState();
}

class _UsuarioFormularioPaginaState extends State<UsuarioFormularioPagina> {
  final _servico = UsuarioServico();
  final _nome = TextEditingController();
  final _login = TextEditingController();
  final _senha = TextEditingController();
  final _comissao = TextEditingController();

  DadosUsuario _dados = const DadosUsuario();
  bool _ocultarSenha = true;
  bool _salvando = false;
  String? _erro;

  bool get _somenteLeitura => widget.ehConsulta;

  @override
  void initState() {
    super.initState();
    final usuario = widget.usuario;
    if (usuario == null) return;

    _nome.text = usuario.nome ?? '';
    _login.text = usuario.login ?? '';
    _comissao.text = formatarNumeroBr(
      usuario.percentualComissao,
      casas: null,
      vazio: '',
    );
    _dados = DadosUsuario(perfil: usuario.perfil ?? RotulosUsuario.caixa);
  }

  @override
  void dispose() {
    _nome.dispose();
    _login.dispose();
    _senha.dispose();
    _comissao.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------

  /// Junta o que está nos controllers ao que está em [_dados].
  DadosUsuario get _dadosCompletos => _dados.copiarCom(
    nome: _nome.text,
    login: _login.text,
    senha: _senha.text,
    percentualComissao: _comissao.text,
  );

  Future<void> _salvar() async {
    if (_somenteLeitura) return;

    final dados = _dadosCompletos;
    final erroValidacao = ValidadorUsuario.validar(dados);
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await _servico.criar(dados.paraCriacao());
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _somenteLeitura ? 'Usuário' : 'Novo usuário',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTema.texto,
            ),
          ),
          Text(
            _somenteLeitura ? 'Cadastro · Consulta' : 'Cadastro · Identidade',
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
          if (_somenteLeitura) ...[
            const AppCartaoAviso.dica(
              'A edição de usuário ainda não está disponível na API. '
              'Para trocar perfil ou senha, cadastre um usuário novo.',
            ),
            const SizedBox(height: 14),
          ],
          const AppRotulo('Nome'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _nome,
            dica: 'Ex.: Maria da Silva',
            tamanhoMax: 120,
            habilitado: !_somenteLeitura,
          ),
          const SizedBox(height: 14),
          const AppRotulo('Login'),
          const SizedBox(height: 6),
          AppCampoTexto(
            controle: _login,
            dica: 'Ex.: maria.silva',
            tamanhoMax: 60,
            habilitado: !_somenteLeitura,
          ),
          if (!_somenteLeitura) ...[
            const SizedBox(height: 14),
            const AppRotulo('Senha'),
            const SizedBox(height: 6),
            _campoSenha(),
          ],
          const SizedBox(height: 14),
          const AppRotulo('Perfil'),
          const SizedBox(height: 6),
          _seletorPerfil(),
          if (_dados.exigeComissao) ...[
            const SizedBox(height: 14),
            const AppRotulo('Percentual de comissão', opcional: true),
            const SizedBox(height: 6),
            AppCampoTexto(
              controle: _comissao,
              dica: '0,00 a 100,00',
              habilitado: !_somenteLeitura,
              tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
              formatadores: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
          ],
          const SizedBox(height: 18),
          AppDica(
            _somenteLeitura
                ? 'A comissão só se aplica ao perfil Garçom.'
                : 'Apenas administradores podem cadastrar usuários. O login '
                      'deve ser único e a senha ter no mínimo '
                      '${ValidadorUsuario.senhaTamanhoMinimo} caracteres.',
          ),
          if (_erro != null) ...[
            const SizedBox(height: 14),
            AppCartaoAviso.erro(_erro),
          ],
        ],
      ),
    ),
    bottomNavigationBar: _somenteLeitura
        ? null
        : AppBarraAcoes(
            textoConfirmar: 'Salvar',
            carregando: _salvando,
            aoCancelar: () => Navigator.pop(context, false),
            aoConfirmar: _salvar,
          ),
  );

  Widget _campoSenha() => AppCampoTexto(
    controle: _senha,
    dica: 'Mínimo de ${ValidadorUsuario.senhaTamanhoMinimo} caracteres',
    ocultar: _ocultarSenha,
    tamanhoMax: 100,
    sufixo: IconButton(
      tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
      onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
      icon: FaIcon(
        _ocultarSenha ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
        color: AppTema.primariaEscura,
        size: 18,
      ),
    ),
  );

  Widget _seletorPerfil() => IgnorePointer(
    ignoring: _somenteLeitura,
    child: Opacity(
      opacity: _somenteLeitura ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: DecoracoesApp.campoPlano(),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _dados.perfil,
            isExpanded: true,
            icon: const FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 14,
              color: AppTema.primariaEscura,
            ),
            style: const TextStyle(color: AppTema.texto, fontSize: 16),
            items: [
              for (final perfil in RotulosUsuario.perfis)
                DropdownMenuItem(
                  value: perfil,
                  child: Text(RotulosUsuario.perfil(perfil)),
                ),
            ],
            onChanged: (valor) => setState(() {
              _dados = _dados.copiarCom(perfil: valor ?? RotulosUsuario.caixa);
              // Trocar de perfil apaga a comissão: fora de garçom ela não
              // seria enviada, e deixá-la preenchida na tela confunde.
              if (!_dados.exigeComissao) _comissao.clear();
              _erro = null;
            }),
          ),
        ),
      ),
    ),
  );
}
