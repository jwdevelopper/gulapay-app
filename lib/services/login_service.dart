import 'package:my_app_teste/model/response_login.dart';
import 'package:dio/dio.dart';
import 'package:my_app_teste/utils/constants_api.dart';

class LoginService {
  final dio = new Dio();

  Future<ResponseLogin> efetuarLogin(
    String email, 
    String password) async {
      try {
      final response = await 
      dio.post(ConstantsApi.baseUrl 
      + ConstantsApi.porta 
      + ConstantsApi.urlLogin, data: {
        "login": email,
        "senha": password
      });
      return ResponseLogin.fromJson(response.data);
      } on DioException catch (e) {
        print("Antes de mostrar o erro");
        print(e);
        if(e.response!.statusCode == 400) {
          return 
          ResponseLogin(message: e.response!.data['message']);
        } else if(e.response!.statusCode == 500) {
          return ResponseLogin(message: "Erro inesperado do servidor!");
        }
        return ResponseLogin(message: e.toString());
      }
    }
}