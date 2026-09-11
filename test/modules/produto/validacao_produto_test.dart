import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/produto/dto/validacao_produto.dart';

void main() {
  ResultadoValidacaoProduto validar(int etapa, DadosProduto d) =>
      ValidadorProduto.validarEtapa(etapa, d);

  group('etapa 0 — identidade', () {
    test('nome vazio bloqueia', () {
      final r = validar(0, const DadosProduto());
      expect(r.valido, isFalse);
      expect(r.erroEm(CampoProduto.nome), isTrue);
      expect(r.mensagem, contains('1 campo obrigatório'));
    });

    test('nome só com espaços também bloqueia', () {
      final r = validar(0, const DadosProduto(nome: '   '));
      expect(r.erroEm(CampoProduto.nome), isTrue);
    });

    test('nome preenchido avança', () {
      final r = validar(0, const DadosProduto(nome: 'Picanha'));
      expect(r.valido, isTrue);
    });

    test('descrição não é obrigatória', () {
      final r = validar(0, const DadosProduto(nome: 'Picanha'));
      expect(r.valido, isTrue);
    });
  });

  group('etapa 1 — preço e categoria', () {
    test('vazia acusa os dois campos', () {
      final r = validar(1, const DadosProduto(nome: 'Picanha'));
      expect(r.camposComErro, {CampoProduto.preco, CampoProduto.categoria});
      expect(r.mensagem, contains('2 campos obrigatórios'));
    });

    test('preço zero é inválido', () {
      final r = validar(
        1,
        const DadosProduto(nome: 'X', preco: '0,00', categoriaId: 1),
      );
      expect(r.erroEm(CampoProduto.preco), isTrue);
    });

    test('preço e categoria preenchidos avançam', () {
      final r = validar(
        1,
        const DadosProduto(nome: 'X', preco: '89,00', categoriaId: 1),
      );
      expect(r.valido, isTrue);
    });
  });

  group('etapa 2 — produção', () {
    test('vazia acusa tipo e setor', () {
      final r = validar(2, const DadosProduto(nome: 'X'));
      expect(r.camposComErro, {CampoProduto.tipo, CampoProduto.setor});
    });

    test('tipo e setor escolhidos liberam o cadastro', () {
      final r = validar(
        2,
        const DadosProduto(nome: 'X', tipo: 'UNITARIO', setor: 'COZINHA'),
      );
      expect(r.valido, isTrue);
    });
  });

  group('precoNumerico', () {
    test('aceita vírgula como separador decimal', () {
      expect(const DadosProduto(preco: '89,90').precoNumerico, 89.90);
    });

    test('ignora o ponto de milhar', () {
      expect(const DadosProduto(preco: '1.299,90').precoNumerico, 1299.90);
    });

    test('texto inválido vira zero', () {
      expect(const DadosProduto(preco: 'abc').precoNumerico, 0);
    });
  });

  group('paraPayload', () {
    const base = DadosProduto(
      nome: '  Picanha  ',
      descricao: 'Na chapa',
      preco: '89,90',
      categoriaId: 3,
      tipo: 'UNITARIO',
      setor: 'COZINHA',
    );

    test('faz trim do nome e envia o preço numérico', () {
      final p = base.paraPayload();
      expect(p['nome'], 'Picanha');
      expect(p['preco'], 89.90);
      expect(p['categoriaId'], 3);
      expect(p['tipoProduto'], 'UNITARIO');
      expect(p['setorProducao'], 'COZINHA');
    });

    test('criação não envia ativo', () {
      expect(base.paraPayload().containsKey('ativo'), isFalse);
    });

    test('edição envia ativo', () {
      final p = base.paraPayload(paraEdicao: true);
      expect(p['ativo'], isTrue);
    });

    test('descrição vazia vira null', () {
      const semDescricao = DadosProduto(nome: 'X', descricao: '   ');
      expect(semDescricao.paraPayload()['descricao'], isNull);
    });
  });

  group('ResultadoValidacaoProduto.sem', () {
    test('remove só o campo corrigido', () {
      const r = ResultadoValidacaoProduto(
        camposComErro: {CampoProduto.preco, CampoProduto.categoria},
        mensagem: '2 campos obrigatórios precisam ser preenchidos.',
      );
      final depois = r.sem(CampoProduto.preco);
      expect(depois.erroEm(CampoProduto.preco), isFalse);
      expect(depois.erroEm(CampoProduto.categoria), isTrue);
    });

    test('volta a válido quando o último erro sai', () {
      const r = ResultadoValidacaoProduto(
        camposComErro: {CampoProduto.nome},
        mensagem: 'x',
      );
      expect(r.sem(CampoProduto.nome).valido, isTrue);
    });
  });
}
