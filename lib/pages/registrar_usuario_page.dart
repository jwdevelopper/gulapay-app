import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/services/registrar_usuario_service.dart';
import 'package:my_app_teste/utils/api_error.dart';

class RegistrarUsuario extends StatefulWidget {
  const RegistrarUsuario({super.key});

  @override
  State<RegistrarUsuario> createState() => _RegistrarUsuarioState();
}

class _RegistrarUsuarioState extends State<RegistrarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _registrarUsuarioService = new RegistrarUsuarioService();

  bool _isLoading = false;

  TextEditingController _nomeController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _senhaController = new TextEditingController();
  TextEditingController _confirmarSenhaController = new TextEditingController();

  bool _obscureText = true;
  bool _obscureTextConfirmSenha = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Usuário", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 12, 2, 61),
              const Color.fromARGB(255, 42, 3, 142),
              Color.fromARGB(255, 2, 27, 139),
              const Color.fromARGB(255, 13, 11, 151),
            ],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
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
                    children: [
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
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: "Nome",
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: FaIcon(FontAwesomeIcons.user, size: 15.0),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _nomeController.clear(),
                        icon: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: 15.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo Nome deve ser preenchido";
                      } else if (value.length < 6) {
                        return "O campo Nome deve conter mais de 5 caracteres";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: "E-mail",
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: FaIcon(FontAwesomeIcons.envelope, size: 15.0),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _emailController.clear(),
                        icon: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: 15.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Informe o e-mail";
                      } else if (!value.contains("@")) {
                        return "Informe um e-mail válido!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: "Senha",
                      prefixIcon: IconButton(
                        icon: FaIcon(FontAwesomeIcons.lock, size: 15),
                        onPressed: () {},
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                        icon: FaIcon(
                          _obscureText
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                          size: 15.0,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Informe a senha";
                      } else if (value.length < 8) {
                        return "Informe uma senha que contenha no minimo 8 digitos";
                      } else if (value == "12345678") {
                        return "Informe uma senha mais complexa";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  TextFormField(
                    controller: _confirmarSenhaController,
                    obscureText: _obscureTextConfirmSenha,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: "Confirmar Senha",
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: FaIcon(
                          FontAwesomeIcons.check,
                          size: 15.0,
                          color: Colors.green,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureTextConfirmSenha =
                                !_obscureTextConfirmSenha;
                          });
                        },
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
                      if(value == null || value.isEmpty) {
                        return "Confirme a senha";
                      } else if(_confirmarSenhaController.text != _senhaController.text){
                        return "Senhas não coincidem";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.0),
                  SizedBox(
                    width: double.infinity,
                    height: 60.0,
                    child: ElevatedButton.icon(
                      onPressed:_isLoading ? null : () async {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
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
                            await _registrarUsuarioService.registrarUsuario(
                              _nomeController.text,
                              _emailController.text,
                              _senhaController.text,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
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
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                         }

                      },
                      label: Text(
                        _isLoading ? "Registrando usuario...." : "Registrar Usuário",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon:_isLoading ? CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        color: Colors.green,
                      ) : FaIcon(FontAwesomeIcons.userPlus, size: 25.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      iconAlignment: IconAlignment.end,
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