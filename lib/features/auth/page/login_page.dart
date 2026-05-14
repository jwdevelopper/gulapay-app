import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/features/auth/service/login_service.dart';
import 'package:my_app_teste/modules/home/page/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _loginService = LoginService();

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _efetuarLogin() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor verifique o formulário!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _loginService.efetuarLogin(
        _emailController.text,
        _senhaController.text,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login realizado com sucesso!"),
          backgroundColor: Color.fromARGB(255, 175, 129, 76),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on ApiError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao efetuar login: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/login_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/img/logo_mascot.png",
                      height: 175.0,
                      width: 175.0,
                    ),
                    const SizedBox(height: 20.0),
                    _buildCampoEmail(),
                    const SizedBox(height: 20.0),
                    _buildCampoSenha(),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _efetuarLogin,
                        label: const Text("Logar"),
                        icon: const Icon(Icons.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 236, 133, 80),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoEmail() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xF2FFF5DC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 248, 151, 40)),
        ),
        hintText: "Digite seu e-mail",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.user, color: Color(0xffB8825A)),
        ),
        suffixIcon: IconButton(
          onPressed: _emailController.clear,
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Color(0xffB8825A)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Informe o e-mail";
        return null;
      },
    );
  }

  Widget _buildCampoSenha() {
    return TextFormField(
      controller: _senhaController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xF2FFF5DC),
        hintText: "Digite sua senha",
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 248, 151, 40)),
        ),
        prefixIcon: IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.lock, color: Color(0xffB8825A)),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: FaIcon(
            _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            color: const Color(0xffB8825A),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Informe a senha";
        if (value.length < 6) return "A senha deve conter mais de 5 digitos!";
        return null;
      },
    );
  }
}
