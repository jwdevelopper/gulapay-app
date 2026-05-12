import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/features/auth/service/registrar_usuario_service.dart';

class RegistrarUsuarioPage extends StatefulWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  State<RegistrarUsuarioPage> createState() => _RegistrarUsuarioPageState();
}

class _RegistrarUsuarioPageState extends State<RegistrarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _registrarUsuarioService = RegistrarUsuarioService();

  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureTextConfirmSenha = true;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
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
      await _registrarUsuarioService.registrarUsuario(
        _nomeController.text,
        _emailController.text,
        _senhaController.text,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario Registrado!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on ApiError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao registrar o usuario: ${e.message}"),
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
      appBar: AppBar(
        title: const Text("Registrar Usuário", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 12, 2, 61),
              Color.fromARGB(255, 42, 3, 142),
              Color.fromARGB(255, 2, 27, 139),
              Color.fromARGB(255, 13, 11, 151),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.userPlus, size: 25.0),
                      SizedBox(width: 10.0),
                      Text(
                        "Registrar o usuario",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _buildNome(),
                  const SizedBox(height: 30.0),
                  _buildEmail(),
                  const SizedBox(height: 20.0),
                  _buildSenha(),
                  const SizedBox(height: 30.0),
                  _buildConfirmarSenha(),
                  const SizedBox(height: 30.0),
                  _buildBotaoRegistrar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNome() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: "Nome",
        prefixIcon: IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.user, size: 15.0),
        ),
        suffixIcon: IconButton(
          onPressed: _nomeController.clear,
          icon: const FaIcon(FontAwesomeIcons.xmark, size: 15.0, color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo Nome deve ser preenchido";
        if (value.length < 6) return "O campo Nome deve conter mais de 5 caracteres";
        return null;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: "E-mail",
        prefixIcon: IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.envelope, size: 15.0),
        ),
        suffixIcon: IconButton(
          onPressed: _emailController.clear,
          icon: const FaIcon(FontAwesomeIcons.xmark, size: 15.0, color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Informe o e-mail";
        if (!value.contains("@")) return "Informe um e-mail válido!";
        return null;
      },
    );
  }

  Widget _buildSenha() {
    return TextFormField(
      controller: _senhaController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: "Senha",
        prefixIcon: IconButton(
          icon: const FaIcon(FontAwesomeIcons.lock, size: 15),
          onPressed: () {},
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: FaIcon(
            _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            size: 15.0,
            color: Colors.black45,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Informe a senha";
        if (value.length < 8) return "Informe uma senha que contenha no minimo 8 digitos";
        if (value == "12345678") return "Informe uma senha mais complexa";
        return null;
      },
    );
  }

  Widget _buildConfirmarSenha() {
    return TextFormField(
      controller: _confirmarSenhaController,
      obscureText: _obscureTextConfirmSenha,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        labelText: "Confirmar Senha",
        prefixIcon: IconButton(
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.check, size: 15.0, color: Colors.green),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(
              () => _obscureTextConfirmSenha = !_obscureTextConfirmSenha),
          icon: FaIcon(
            _obscureTextConfirmSenha
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            size: 15.0,
            color: Colors.black45,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Confirme a senha";
        if (_confirmarSenhaController.text != _senhaController.text) {
          return "Senhas não coincidem";
        }
        return null;
      },
    );
  }

  Widget _buildBotaoRegistrar() {
    return SizedBox(
      width: double.infinity,
      height: 60.0,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _registrar,
        label: Text(
          _isLoading ? "Registrando usuario...." : "Registrar Usuário",
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
        ),
        icon: _isLoading
            ? const CircularProgressIndicator(
                backgroundColor: Colors.white,
                color: Colors.green,
              )
            : const FaIcon(FontAwesomeIcons.userPlus, size: 25.0),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        iconAlignment: IconAlignment.end,
      ),
    );
  }
}
