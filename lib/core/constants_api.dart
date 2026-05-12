/// Constantes de endereço e endpoints da API.
final class ConstantsApi {
  ConstantsApi._();

  static const String baseUrl = "http://localhost";
  static const String porta = ":8080";

  // Endpoints
  static const String urlLogin = "/auth/login";
  static const String urlRegistrarUsuario = "/auth/register";
  static const String urlCategorias = "/categorias";
  static const String urlProdutos = "/produtos";
}
