import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/produto/dto/filtro_produtos.dart';
import 'package:my_app_teste/modules/produto/dto/produto.dart';

void main() {
  Produto produto({
    required String nome,
    double? preco,
    int? categoriaId,
    String? descricao,
    String? tipo,
    String? setor,
  }) => Produto(
    nome: nome,
    preco: preco,
    categoriaId: categoriaId,
    descricao: descricao,
    tipoProduto: tipo,
    setorProducao: setor,
  );

  final pizza = produto(
    nome: 'Pizza',
    preco: 45,
    categoriaId: 1,
    descricao: 'Massa fina',
    tipo: 'COMPOSTO',
    setor: 'COZINHA',
  );
  final agua = produto(
    nome: 'Água',
    preco: 5,
    categoriaId: 2,
    descricao: 'Sem gás',
    tipo: 'UNITARIO',
    setor: 'BAR',
  );
  final bolo = produto(nome: 'Bolo', preco: 20, categoriaId: 3);
  final todos = [pizza, agua, bolo];

  String nomeCategoria(int? id) => switch (id) {
    1 => 'Pratos principais',
    2 => 'Bebidas',
    3 => 'Sobremesas',
    _ => '',
  };

  List<Produto> aplicar(FiltroProdutos f) =>
      f.aplicar(todos, nomeCategoria: nomeCategoria);

  group('busca livre', () {
    test('confere o nome', () {
      expect(
        aplicar(const FiltroProdutos(busca: 'pizza')).single.nome,
        'Pizza',
      );
    });

    test('confere a descrição', () {
      expect(
        aplicar(const FiltroProdutos(busca: 'sem gás')).single.nome,
        'Água',
      );
    });

    test('confere o nome da categoria', () {
      expect(
        aplicar(const FiltroProdutos(busca: 'bebidas')).single.nome,
        'Água',
      );
    });

    test('não diferencia maiúsculas', () {
      expect(aplicar(const FiltroProdutos(busca: 'PIZZA')).length, 1);
    });

    test('termo em branco não recorta', () {
      expect(aplicar(const FiltroProdutos(busca: '   ')).length, 3);
    });
  });

  group('filtro avançado', () {
    test('categoria', () {
      expect(aplicar(const FiltroProdutos(categoriaId: 2)).single.nome, 'Água');
    });

    test('faixa de preço', () {
      final r = aplicar(const FiltroProdutos(precoMin: 10, precoMax: 30));
      expect(r.single.nome, 'Bolo');
    });

    test('produto sem preço conta como zero', () {
      final semPreco = produto(nome: 'Cortesia');
      final r = const FiltroProdutos(
        precoMax: 0,
      ).aplicar([semPreco, pizza], nomeCategoria: nomeCategoria);
      expect(r.single.nome, 'Cortesia');
    });

    test('tipo de produto', () {
      expect(
        aplicar(const FiltroProdutos(tipoProduto: 'UNITARIO')).single.nome,
        'Água',
      );
    });

    test('setor de produção', () {
      expect(
        aplicar(const FiltroProdutos(setorProducao: 'COZINHA')).single.nome,
        'Pizza',
      );
    });

    test('descrição do filtro avançado', () {
      expect(
        aplicar(const FiltroProdutos(descricao: 'massa')).single.nome,
        'Pizza',
      );
    });

    test('critérios se combinam', () {
      expect(
        aplicar(const FiltroProdutos(categoriaId: 1, precoMax: 10)),
        isEmpty,
      );
    });
  });

  group('ordenação', () {
    test('destaque preserva a ordem do backend', () {
      expect(aplicar(const FiltroProdutos()).map((p) => p.nome), [
        'Pizza',
        'Água',
        'Bolo',
      ]);
    });

    test('preço crescente', () {
      final r = aplicar(
        const FiltroProdutos(ordenacao: OrdenacaoProduto.precoCrescente),
      );
      expect(r.map((p) => p.nome), ['Água', 'Bolo', 'Pizza']);
    });

    test('preço decrescente', () {
      final r = aplicar(
        const FiltroProdutos(ordenacao: OrdenacaoProduto.precoDecrescente),
      );
      expect(r.map((p) => p.nome), ['Pizza', 'Bolo', 'Água']);
    });

    test('nome A-Z ignora maiúsculas', () {
      final r = aplicar(
        const FiltroProdutos(ordenacao: OrdenacaoProduto.nomeCrescente),
      );
      expect(r.map((p) => p.nome), ['Água', 'Bolo', 'Pizza']);
    });

    test('nome Z-A', () {
      final r = aplicar(
        const FiltroProdutos(ordenacao: OrdenacaoProduto.nomeDecrescente),
      );
      expect(r.map((p) => p.nome), ['Pizza', 'Bolo', 'Água']);
    });

    test('não altera a lista recebida', () {
      final original = [pizza, agua, bolo];
      const FiltroProdutos(
        ordenacao: OrdenacaoProduto.nomeCrescente,
      ).aplicar(original, nomeCategoria: nomeCategoria);
      expect(original.map((p) => p.nome), ['Pizza', 'Água', 'Bolo']);
    });
  });

  group('estado', () {
    test('a busca sozinha não conta como filtro avançado', () {
      const f = FiltroProdutos(busca: 'pizza');
      expect(f.temFiltroAvancado, isFalse);
      expect(f.vazio, isFalse);
    });

    test('vazio quando nada foi escolhido', () {
      expect(const FiltroProdutos().vazio, isTrue);
      expect(const FiltroProdutos().temFiltroAvancado, isFalse);
    });

    test('cada critério avançado marca temFiltroAvancado', () {
      expect(const FiltroProdutos(categoriaId: 1).temFiltroAvancado, isTrue);
      expect(const FiltroProdutos(precoMin: 1).temFiltroAvancado, isTrue);
      expect(const FiltroProdutos(precoMax: 1).temFiltroAvancado, isTrue);
      expect(const FiltroProdutos(descricao: 'x').temFiltroAvancado, isTrue);
      expect(const FiltroProdutos(tipoProduto: 'x').temFiltroAvancado, isTrue);
      expect(
        const FiltroProdutos(setorProducao: 'x').temFiltroAvancado,
        isTrue,
      );
    });
  });

  group('comAvancados', () {
    test('preserva busca e ordenação', () {
      const f = FiltroProdutos(
        busca: 'pizza',
        ordenacao: OrdenacaoProduto.nomeCrescente,
        categoriaId: 1,
      );
      final novo = f.comAvancados(categoriaId: 2);
      expect(novo.busca, 'pizza');
      expect(novo.ordenacao, OrdenacaoProduto.nomeCrescente);
      expect(novo.categoriaId, 2);
    });

    test('zera os avançados não informados', () {
      const f = FiltroProdutos(precoMin: 10, tipoProduto: 'UNITARIO');
      final novo = f.comAvancados(categoriaId: 1);
      expect(novo.precoMin, isNull);
      expect(novo.tipoProduto, isNull);
    });
  });

  test('limparCategoria zera a categoria', () {
    const f = FiltroProdutos(categoriaId: 5, busca: 'x');
    final novo = f.copiarCom(limparCategoria: true);
    expect(novo.categoriaId, isNull);
    expect(novo.busca, 'x');
  });
}
