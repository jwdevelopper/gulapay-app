import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_cartao_aviso.dart';
import 'package:my_app_teste/modules/home/page/home_page.dart';
import 'package:my_app_teste/modules/login/dto/validacao_login.dart';
import 'package:my_app_teste/modules/login/service/login_service.dart';
import 'package:my_app_teste/modules/login/widgets/campo_login.dart';

/// Entrada no app.
///
/// Cuida de estado e autenticação; as regras vivem em [ValidadorLogin] e o
/// campo em [CampoLogin].
///
/// O backend autentica por **login** (nome de usuário), não por e-mail —
/// `POST /auth/login` recebe `{login, senha}`. Não há auto-cadastro: quem
/// cria usuários é o administrador, pela tela de Usuários.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _servico = LoginService();
  final _login = TextEditingController();
  final _senha = TextEditingController();

  bool _ocultarSenha = true;
  bool _entrando = false;
  String? _erro;

  late final AnimationController _animacao = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  late final Animation<double> _aparecer = CurvedAnimation(
    parent: _animacao,
    curve: Curves.easeIn,
  );
  late final Animation<Offset> _subir = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animacao, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _animacao.forward();
  }

  @override
  void dispose() {
    _animacao.dispose();
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Autenticação
  // ---------------------------------------------------------------------

  Future<void> _entrar() async {
    final erroValidacao = ValidadorLogin.validar(
      login: _login.text,
      senha: _senha.text,
    );
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }

    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await _servico.efetuarLogin(_login.text.trim(), _senha.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível entrar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FadeTransition(
      opacity: _aparecer,
      child: SlideTransition(
        position: _subir,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/login_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/img/logo_mascot.png',
                      height: 175,
                      width: 175,
                    ),
                    const SizedBox(height: 20),
                    CampoLogin(
                      controle: _login,
                      dica: 'Digite seu login',
                      icone: const FaIcon(
                        FontAwesomeIcons.user,
                        color: AppTema.primariaEscura,
                        size: 18,
                      ),
                      iconeAcao: const FaIcon(
                        FontAwesomeIcons.xmark,
                        color: AppTema.primariaEscura,
                        size: 18,
                      ),
                      dicaAcao: 'Limpar',
                      aoTocarAcao: _login.clear,
                    ),
                    const SizedBox(height: 20),
                    CampoLogin(
                      controle: _senha,
                      dica: 'Digite sua senha',
                      icone: const FaIcon(
                        FontAwesomeIcons.lock,
                        color: AppTema.primariaEscura,
                        size: 18,
                      ),
                      ocultarTexto: _ocultarSenha,
                      iconeAcao: FaIcon(
                        _ocultarSenha
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: AppTema.primariaEscura,
                        size: 18,
                      ),
                      dicaAcao: _ocultarSenha
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                      aoTocarAcao: () =>
                          setState(() => _ocultarSenha = !_ocultarSenha),
                      aoEnviar: _entrar,
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 16),
                      AppCartaoAviso.erro(_erro),
                    ],
                    const SizedBox(height: 20),
                    _botaoEntrar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _botaoEntrar() => SizedBox(
    height: 60,
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _entrando ? null : _entrar,
      icon: _entrando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.login_rounded),
      label: Text(_entrando ? 'Entrando…' : 'Entrar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTema.primariaSuave,
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
