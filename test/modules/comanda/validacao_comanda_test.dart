import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_endereco.dart';
import 'package:my_app_teste/modules/cliente/dto/cliente_response.dart';
import 'package:my_app_teste/modules/comanda/dto/validacao_comanda.dart';

void main() {
  ClienteResponse cliente({int? id = 7, bool comEndereco = false}) =>
      ClienteResponse(
        id: id,
        nome: 'Ana',
        telefone: '44999990000',
        endereco: comEndereco
            ? ClienteEndereco(id: 3, logradouro: 'Rua A', cidade: 'Umuarama')
            : null,
      );

  group('DadosComanda', () {
    test('nasce em MESA / INDIVIDUAL', () {
      const d = DadosComanda();
      expect(d.tipo, DadosComanda.canalMesa);
      expect(d.escopo, DadosComanda.escopoIndividual);
      expect(d.ehMesa, isTrue);
      expect(d.ehDelivery, isFalse);
    });

    test('clienteTemEndereco exige o id do endereço', () {
      expect(const DadosComanda().clienteTemEndereco, isFalse);
      expect(DadosComanda(cliente: cliente()).clienteTemEndereco, isFalse);
      expect(
        DadosComanda(cliente: cliente(comEndereco: true)).clienteTemEndereco,
        isTrue,
      );
    });

    test('copiarCom preserva os campos não informados', () {
      final d = DadosComanda(
        tipo: DadosComanda.canalBalcao,
        mesaId: 1,
        garcomId: 2,
        cliente: cliente(),
      );
      final novo = d.copiarCom(tipo: DadosComanda.canalDelivery);
      expect(novo.tipo, DadosComanda.canalDelivery);
      expect(novo.mesaId, 1);
      expect(novo.garcomId, 2);
      expect(novo.cliente?.id, 7);
    });
  });

  group('paraRequisicao', () {
    test('MESA envia mesa, garçom e escopo', () {
      final req = DadosComanda(
        mesaId: 4,
        garcomId: 9,
        escopo: DadosComanda.escopoCompartilhada,
        cliente: cliente(),
      ).paraRequisicao();

      expect(req.tipoOrigem, 'MESA');
      expect(req.escopo, DadosComanda.escopoCompartilhada);
      expect(req.mesaId, 4);
      expect(req.garcomId, 9);
      expect(req.clienteId, 7);
      expect(req.enderecoEntregaId, isNull);
    });

    test('BALCAO descarta mesa/garçom e força INDIVIDUAL', () {
      final req = DadosComanda(
        tipo: DadosComanda.canalBalcao,
        escopo: DadosComanda.escopoCompartilhada,
        mesaId: 4,
        garcomId: 9,
        cliente: cliente(),
      ).paraRequisicao();

      expect(req.mesaId, isNull);
      expect(req.garcomId, isNull);
      expect(req.escopo, DadosComanda.escopoIndividual);
    });

    test('DELIVERY envia o endereço do cliente', () {
      final req = DadosComanda(
        tipo: DadosComanda.canalDelivery,
        cliente: cliente(comEndereco: true),
      ).paraRequisicao();

      expect(req.enderecoEntregaId, 3);
      expect(req.mesaId, isNull);
    });

    test('observação em branco não é enviada', () {
      final req = const DadosComanda(observacao: '   ').paraRequisicao();
      expect(req.observacao, isNull);
    });

    test('observação é aparada', () {
      final req = const DadosComanda(
        observacao: '  sem cebola  ',
      ).paraRequisicao();
      expect(req.observacao, 'sem cebola');
    });
  });

  group('ValidadorComanda', () {
    test('etapas 0 e 3 não têm campo obrigatório', () {
      expect(ValidadorComanda.validarEtapa(0, const DadosComanda()), isNull);
      expect(ValidadorComanda.validarEtapa(3, const DadosComanda()), isNull);
    });

    test('etapa 1 exige cliente', () {
      expect(
        ValidadorComanda.validarEtapa(1, const DadosComanda()),
        'Selecione o cliente da comanda.',
      );
      expect(
        ValidadorComanda.validarEtapa(1, DadosComanda(cliente: cliente())),
        isNull,
      );
    });

    test('etapa 1 recusa cliente sem id', () {
      expect(
        ValidadorComanda.validarEtapa(
          1,
          DadosComanda(cliente: cliente(id: null)),
        ),
        isNotNull,
      );
    });

    test('etapa 2 em MESA exige mesa e garçom, nessa ordem', () {
      const semNada = DadosComanda();
      expect(
        ValidadorComanda.validarEtapa(2, semNada),
        'Selecione a mesa da comanda.',
      );
      expect(
        ValidadorComanda.validarEtapa(2, const DadosComanda(mesaId: 1)),
        'Selecione o garçom responsável pela comanda.',
      );
      expect(
        ValidadorComanda.validarEtapa(
          2,
          const DadosComanda(mesaId: 1, garcomId: 2),
        ),
        isNull,
      );
    });

    test('etapa 2 em BALCAO não exige nada', () {
      expect(
        ValidadorComanda.validarEtapa(
          2,
          const DadosComanda(tipo: DadosComanda.canalBalcao),
        ),
        isNull,
      );
    });

    test('etapa 2 em DELIVERY exige cliente com endereço', () {
      expect(
        ValidadorComanda.validarEtapa(
          2,
          DadosComanda(tipo: DadosComanda.canalDelivery, cliente: cliente()),
        ),
        'Selecione um cliente com endereço cadastrado.',
      );
      expect(
        ValidadorComanda.validarEtapa(
          2,
          DadosComanda(
            tipo: DadosComanda.canalDelivery,
            cliente: cliente(comEndereco: true),
          ),
        ),
        isNull,
      );
    });
  });
}
