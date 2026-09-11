import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/cliente/dto/validacao_cliente.dart';

void main() {
  const enderecoCompleto = DadosCliente(
    nome: 'Ana Souza',
    telefone: '(44) 99999-0000',
    logradouro: 'Rua A',
    numero: '10',
    bairro: 'Centro',
    cidade: 'Umuarama',
    uf: 'PR',
  );

  group('telefone', () {
    test('vai para a API só com dígitos', () {
      const d = DadosCliente(telefone: '(44) 99999-0000');
      expect(d.telefoneParaApi, '44999990000');
    });

    test('já sem máscara continua igual', () {
      const d = DadosCliente(telefone: '44999990000');
      expect(d.telefoneParaApi, '44999990000');
    });

    test('exige DDD e número', () {
      expect(ValidadorCliente.validarTelefone(''), isNotNull);
      expect(ValidadorCliente.validarTelefone('(44) 9'), isNotNull);
      expect(ValidadorCliente.validarTelefone('(44) 3333-4444'), isNull);
      expect(ValidadorCliente.validarTelefone('(44) 99999-0000'), isNull);
    });
  });

  group('nome', () {
    test('é obrigatório', () {
      expect(ValidadorCliente.validarNome(''), isNotNull);
      expect(ValidadorCliente.validarNome('   '), isNotNull);
    });

    test('exige o mínimo de caracteres', () {
      expect(ValidadorCliente.validarNome('Jo'), isNotNull);
      expect(ValidadorCliente.validarNome('Ana'), isNull);
    });
  });

  group('e-mail', () {
    test('é opcional', () {
      expect(ValidadorCliente.validarEmail(''), isNull);
      expect(ValidadorCliente.validarEmail(null), isNull);
    });

    test('quando informado precisa ter formato de e-mail', () {
      expect(ValidadorCliente.validarEmail('joao'), isNotNull);
      expect(ValidadorCliente.validarEmail('joao@'), isNotNull);
      expect(ValidadorCliente.validarEmail('joao@email'), isNotNull);
      expect(ValidadorCliente.validarEmail('joao@email.com'), isNull);
    });

    test('e-mail em branco não é enviado', () {
      const d = DadosCliente(nome: 'Ana', telefone: '44999990000');
      expect(d.paraCriacao().email, isNull);
    });
  });

  group('endereço', () {
    test('em branco é aceito — só delivery exige endereço', () {
      const d = DadosCliente(nome: 'Ana', telefone: '(44) 99999-0000');
      expect(d.temEndereco, isFalse);
      expect(d.endereco, isNull);
      expect(ValidadorCliente.validar(d), isNull);
    });

    test('iniciado precisa ser completado', () {
      const d = DadosCliente(
        nome: 'Ana',
        telefone: '(44) 99999-0000',
        logradouro: 'Rua A',
      );
      expect(d.temEndereco, isTrue);
      expect(ValidadorCliente.validar(d), 'Informe o número.');
    });

    test('completo passa', () {
      expect(ValidadorCliente.validar(enderecoCompleto), isNull);
    });

    test('UF precisa ter duas letras', () {
      expect(ValidadorCliente.validarUf('P'), isNotNull);
      expect(ValidadorCliente.validarUf('PRR'), isNotNull);
      expect(ValidadorCliente.validarUf('pr'), isNull);
    });

    test('UF é enviada em maiúsculas', () {
      const d = DadosCliente(
        nome: 'Ana',
        telefone: '44999990000',
        logradouro: 'Rua A',
        numero: '10',
        bairro: 'Centro',
        cidade: 'Umuarama',
        uf: 'pr',
      );
      expect(d.endereco?.uf, 'PR');
    });

    test('CEP é opcional, mas precisa estar completo quando informado', () {
      expect(ValidadorCliente.validarCep(''), isNull);
      expect(ValidadorCliente.validarCep('01310-100'), isNull);
      expect(ValidadorCliente.validarCep('01310-1'), isNotNull);
    });

    test('CEP vai para a API só com dígitos', () {
      const d = DadosCliente(
        nome: 'Ana',
        telefone: '44999990000',
        logradouro: 'Rua A',
        numero: '10',
        bairro: 'Centro',
        cidade: 'Umuarama',
        uf: 'PR',
        cep: '01310-100',
      );
      expect(d.endereco?.cep, '01310100');
    });

    test('CEP incompleto reprova o endereço', () {
      const d = DadosCliente(
        nome: 'Ana',
        telefone: '(44) 99999-0000',
        logradouro: 'Rua A',
        numero: '10',
        bairro: 'Centro',
        cidade: 'Umuarama',
        uf: 'PR',
        cep: '01310',
      );
      expect(ValidadorCliente.validar(d), contains('CEP incompleto'));
    });

    test('só o complemento já conta como endereço iniciado', () {
      const d = DadosCliente(
        nome: 'Ana',
        telefone: '(44) 99999-0000',
        complemento: 'Apto 42',
      );
      expect(d.temEndereco, isTrue);
      expect(ValidadorCliente.validar(d), 'Informe o logradouro.');
    });
  });

  group('payload', () {
    test('criação leva telefone sem máscara e endereço', () {
      final req = enderecoCompleto.paraCriacao();
      expect(req.telefone, '44999990000');
      expect(req.nome, 'Ana Souza');
      expect(req.endereco?.cidade, 'Umuarama');
    });

    test('edição preserva o ativo', () {
      const d = DadosCliente(
        nome: 'Ana Souza',
        telefone: '44999990000',
        ativo: false,
      );
      expect(d.paraEdicao().ativo, isFalse);
    });

    test('comCampos preserva o ativo', () {
      const d = DadosCliente(ativo: false);
      final novo = d.comCampos(
        nome: 'Ana',
        telefone: '44999990000',
        email: '',
        cep: '',
        logradouro: '',
        numero: '',
        complemento: '',
        bairro: '',
        cidade: '',
        uf: '',
      );
      expect(novo.ativo, isFalse);
      expect(novo.nome, 'Ana');
    });
  });

  test('a validação para no primeiro problema, na ordem da tela', () {
    const d = DadosCliente(nome: '', telefone: '', email: 'x');
    expect(ValidadorCliente.validar(d), 'Informe o nome do cliente.');
  });
}
