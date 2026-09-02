import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/modules/home/page/home_page.dart';
import 'package:my_app_teste/modules/login/service/login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailControler = new TextEditingController();
  TextEditingController _senhaControler = new TextEditingController();

  final _loginService = new LoginService();

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailControler.dispose();
    _senhaControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/login_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/logo_mascot.png",
                          height: 175.0,
                          width: 175.0,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _emailControler,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xF2FFF5DC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 248, 151, 40),
                              ),
                            ),
                            hintText: "Digite seu e-mail",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: FaIcon(
                                FontAwesomeIcons.user,
                                color: Color(0xffB8825A),
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _emailControler.clear();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.xmark,
                                color: Color(0xffB8825A),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Informe o e-mail";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _senhaControler,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xF2FFF5DC),
                            hintText: "Digite sua senha",
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 248, 151, 40),
                              ),
                            ),
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.lock, color: Color(0xffB8825A),),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: FaIcon(
                                _obscureText
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                              color: Color(0xffB8825A),),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Informe a senha";
                            } else if (value.length < 6) {
                              return "A senha deve conter mais de 5 digitos!";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          height: 60.0,
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Por favor verifique o formulário!",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        await _loginService.efetuarLogin(
                                          _emailControler.text,
                                          _senhaControler.text,
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Login realizado com sucesso!",
                                            ),
                                            backgroundColor: const Color.fromARGB(255, 175, 129, 76),
                                          ),
                                        );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Home(),
                                          ),
                                        );
                                      } on ApiError catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Erro ao efetuar login: ${e.message}",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                            label: Text("Logar"),
                            icon: Icon(Icons.login),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 236, 133, 80),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
