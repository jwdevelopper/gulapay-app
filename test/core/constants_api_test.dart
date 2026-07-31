import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/constants_api.dart';

void main() {
  test('usa a API de teste por padrao', () {
    expect(ConstantsApi.usarApiDeTeste, isTrue);
    expect(
      ConstantsApi.baseUrl,
      'https://gulapay-backend.renannardi.com',
    );
    expect(ConstantsApi.porta, '');
    expect(
      ConstantsApi.urlBaseCompleta,
      'https://gulapay-backend.renannardi.com',
    );
  });
}
