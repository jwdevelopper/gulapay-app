import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/core/utils/whatsapp.dart';

void main() {
  group('montarLinkWhatsApp — a partir do telefone', () {
    test('acrescenta o DDI 55 quando o número vem sem ele', () {
      expect(
        montarLinkWhatsApp(telefone: '44999990000'),
        'https://wa.me/5544999990000',
      );
    });

    test('descarta máscara e mantém só os dígitos', () {
      expect(
        montarLinkWhatsApp(telefone: '(44) 99999-0000'),
        'https://wa.me/5544999990000',
      );
    });

    test('não duplica o DDI quando o número já vem com ele', () {
      expect(
        montarLinkWhatsApp(telefone: '5544999990000'),
        'https://wa.me/5544999990000',
      );
    });

    test('telefone só com máscara, sem dígitos, cai no link pronto', () {
      expect(
        montarLinkWhatsApp(telefone: '()- ', linkPronto: 'https://wa.me/551'),
        'https://wa.me/551',
      );
    });
  });

  group('montarLinkWhatsApp — a partir do link pronto', () {
    test('usa a URL do backend como está', () {
      expect(
        montarLinkWhatsApp(linkPronto: 'https://wa.me/5544999990000'),
        'https://wa.me/5544999990000',
      );
    });

    test('aceita o esquema whatsapp:', () {
      expect(
        montarLinkWhatsApp(linkPronto: 'whatsapp://send?phone=55'),
        'whatsapp://send?phone=55',
      );
    });

    test('normaliza quando o campo vem com um telefone em vez de URL', () {
      expect(
        montarLinkWhatsApp(linkPronto: '44999990000'),
        'https://wa.me/5544999990000',
      );
    });
  });

  group('montarLinkWhatsApp — sem destino', () {
    test('devolve null sem telefone e sem link', () {
      expect(montarLinkWhatsApp(), isNull);
    });

    test('devolve null com strings vazias', () {
      expect(montarLinkWhatsApp(telefone: '  ', linkPronto: ''), isNull);
    });
  });

  test('o telefone tem precedência sobre o link pronto', () {
    expect(
      montarLinkWhatsApp(
        telefone: '44988887777',
        linkPronto: 'https://wa.me/5511111111111',
      ),
      'https://wa.me/5544988887777',
    );
  });
}
