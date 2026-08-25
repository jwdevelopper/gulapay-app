/// Constantes de endereço e endpoints da API.
final class ConstantsApi {
  ConstantsApi._();

  static const String apiEnvironment = String.fromEnvironment(
    'API_ENV',
    defaultValue: 'test',
  );

  static const String localBaseUrl = String.fromEnvironment(
    'API_LOCAL_BASE_URL',
    defaultValue: 'http://localhost',
  );

  static const String localPorta = String.fromEnvironment(
    'API_LOCAL_PORT',
    defaultValue: ':8080',
  );

  static const String testBaseUrl = String.fromEnvironment(
    'API_TEST_BASE_URL',
    defaultValue: 'https://gulapay-backend.renannardi.com',
  );

  static const String testPorta = String.fromEnvironment(
    'API_TEST_PORT',
    defaultValue: '',
  );

  static bool get usarApiDeTeste => apiEnvironment == 'test';

  static String get baseUrl => usarApiDeTeste ? testBaseUrl : localBaseUrl;

  static String get porta => usarApiDeTeste ? testPorta : localPorta;

  static String get urlBaseCompleta => '$baseUrl$porta';

  static const urlRegistrarUsuario = "/auth/register";
  static const urlLogin = "/auth/login";
  static const urlClientes = "/clientes";
  static const urlUsuarios = "/usuarios";
  static const urlInsumos = "/insumos";
  static const urlLotes = "/lotes";
  static const urlUnidadesMedida = "/unidades-medida";
  static const urlCategorias = "/categorias";
  static const urlProdutos = "/produtos";
  static const urlMesas = "/mesas";
  static const urlComandas = "/comandas";
  static const urlItensComanda = "/itens-comanda";
}
