import 'package:dio/dio.dart';
import 'package:my_app_teste/model/response_cadastrar_usuario_dto.dart';
import 'package:my_app_teste/utils/constants_api.dart';

class RegistrarUsuarioService {
  final dio = new Dio();

  Future<ResponseCadastrarUsuario> registrarUsuario(
    String name, 
    String email, 
    String password) async {
      try {
      final response = await 
      dio.post(ConstantsApi.baseUrl 
      + ConstantsApi.porta  
      + ConstantsApi.urlRegistrarUsuario, data: {
        "name": name,
        "email": email,
        "password": password
      });
      print("Resposta do servico");
      print(response.data);
      print(response);
      return ResponseCadastrarUsuario.fromJson(response.data);
      } on DioException catch (e) {
        print("Antes de mostrar o erro");
        print(e);
        if(e.response!.statusCode == 400) {
          return 
          ResponseCadastrarUsuario(message: e.response!.data['message']);
        } else if(e.response!.statusCode == 500) {
          return ResponseCadastrarUsuario(message: "Erro inesperado do servidor!");
        }
        return ResponseCadastrarUsuario(message: e.toString());
      }
    }
}