import 'package:dio/dio.dart';
import 'package:my_app_teste/utils/constants_api.dart';
import 'package:my_app_teste/model/produto.dart';

class ProdutoService {
  final Dio _dio;

  ProdutoService([Dio? dio]) : _dio = dio ?? Dio(BaseOptions(baseUrl: ConstantsApi.baseUrl, headers: {'Content-Type': 'application/json'}));

  Future<Produto> createProduto(Produto produto) async {
    final resp = await _dio.post('/produtos', data: produto.toJson());
    return Produto.fromJson(resp.data);
  }

  Future<Produto> getProduto(int id) async {
    final resp = await _dio.get('/produtos/$id');
    return Produto.fromJson(resp.data);
  }

  Future<List<Produto>> listProdutos({bool apenasAtivos = false}) async {
    final resp = await _dio.get('/produtos', queryParameters: {'apenasAtivos': apenasAtivos.toString()});
    if (resp.data is List) {
      return (resp.data as List).map((e) => Produto.fromJson(e)).toList();
    }
    return [];
  }

  Future<Produto> updateProduto(int id, Produto produto) async {
    final resp = await _dio.put('/produtos/$id', data: produto.toJson());
    return Produto.fromJson(resp.data);
  }

  Future<void> deleteProduto(int id) async {
    await _dio.delete('/produtos/$id');
  }
}
