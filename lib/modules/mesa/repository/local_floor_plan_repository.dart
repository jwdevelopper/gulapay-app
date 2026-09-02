import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class RepositorioLocalMapaMesas {
  static const _chaveArmazenamento = 'gulapay_floor_plan_v1';

  Future<EstadoMapaMesas?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chaveArmazenamento);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return EstadoMapaMesas.deMapa(map);
  }

  Future<bool> salvar(EstadoMapaMesas estado) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_chaveArmazenamento, jsonEncode(estado.paraMapa()));
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveArmazenamento);
  }

  EstadoMapaMesas construirDadosIniciais() {
    final now = DateTime.now();

    return EstadoMapaMesas(
      idAreaSelecionada: 'salao',
      areas: [
        AreaRestaurante(
          id: 'salao',
          nome: 'Salao interno',
          tipo: 'interno',
          mesas: [
            MesaRestaurante(
              id: 'm1',
              codigo: 'Mesa 01',
              idArea: 'salao',
              x: 84,
              y: 132,
              width: 116,
              height: 86,
              formato: FormatoMesa.retangular,
              quantidadeCadeiras: 6,
              situacao: SituacaoMesa.comPedido,
              estaUnida: false,
              idComandaAtiva: 'ORD-1001',
              ultimoPedidoEm: now.subtract(const Duration(minutes: 12)),
              pessoasSentadas: 4,
              nomeCliente: 'Marina',
              quantidadeItensPedido: 8,
              totalParcial: 186.40,
            ),
            MesaRestaurante(
              id: 'm2',
              codigo: 'Mesa 02',
              idArea: 'salao',
              x: 286,
              y: 132,
              width: 88,
              height: 88,
              formato: FormatoMesa.redonda,
              quantidadeCadeiras: 4,
              situacao: SituacaoMesa.ocupada,
              estaUnida: false,
              ultimoPedidoEm: now.subtract(const Duration(minutes: 38)),
              pessoasSentadas: 3,
            ),
            MesaRestaurante(
              id: 'm3',
              codigo: 'Mesa 03',
              idArea: 'salao',
              x: 468,
              y: 294,
              width: 120,
              height: 74,
              formato: FormatoMesa.oval,
              quantidadeCadeiras: 6,
              situacao: SituacaoMesa.livre,
              estaUnida: false,
            ),
          ],
        ),
        AreaRestaurante(
          id: 'varanda',
          nome: 'Varanda',
          tipo: 'externo',
          mesas: [
            MesaRestaurante(
              id: 'm4',
              codigo: 'Mesa 04',
              idArea: 'varanda',
              x: 112,
              y: 150,
              width: 86,
              height: 86,
              formato: FormatoMesa.quadrada,
              quantidadeCadeiras: 4,
              situacao: SituacaoMesa.livre,
              estaUnida: false,
            ),
            MesaRestaurante(
              id: 'm5',
              codigo: 'Mesa 05',
              idArea: 'varanda',
              x: 332,
              y: 274,
              width: 120,
              height: 74,
              formato: FormatoMesa.retangular,
              quantidadeCadeiras: 6,
              situacao: SituacaoMesa.ocupada,
              estaUnida: false,
              ultimoPedidoEm: now.subtract(
                const Duration(hours: 1, minutes: 10),
              ),
              pessoasSentadas: 5,
            ),
          ],
        ),
        AreaRestaurante(
          id: 'vip',
          nome: 'Area VIP',
          tipo: 'premium',
          mesas: [
            MesaRestaurante(
              id: 'm6',
              codigo: 'Mesa 06',
              idArea: 'vip',
              x: 274,
              y: 164,
              width: 132,
              height: 80,
              formato: FormatoMesa.oval,
              quantidadeCadeiras: 6,
              situacao: SituacaoMesa.livre,
              estaUnida: false,
            ),
            MesaRestaurante(
              id: 'm7',
              codigo: 'Mesa 07',
              idArea: 'vip',
              x: 474,
              y: 164,
              width: 132,
              height: 80,
              formato: FormatoMesa.oval,
              quantidadeCadeiras: 6,
              situacao: SituacaoMesa.livre,
              estaUnida: false,
            ),
          ],
        ),
      ],
    );
  }
}
