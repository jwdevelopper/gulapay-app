import 'package:dio/dio.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/constants_api.dart';
import 'package:my_app_teste/features/produto/model/produto.dart';

class ProdutoService {
  final Dio _dio = ApiClient.dio;

  Future<Produto> createProduto(Produto produto) async {
    final resp = await _dio.post(ConstantsApi.urlProdutos, data: produto.toJson());
    return Produto.fromJson(resp.data);
  }

  Future<Produto> getProduto(int id) async {
    final resp = await _dio.get('${ConstantsApi.urlProdutos}/$id');
    return Produto.fromJson(resp.data);
  }

  Future<List<Produto>> listProdutos({bool apenasAtivos = false}) async {
    final resp = await _dio.get(
      ConstantsApi.urlProdutos,
      queryParameters: {'apenasAtivos': apenasAtivos.toString()},
    );
    if (resp.data is List) {
      return (resp.data as List).map((e) => Produto.fromJson(e)).toList();
    }
    return [];
  }

  Future<Produto> updateProduto(int id, Produto produto) async {
    final resp = await _dio.put('${ConstantsApi.urlProdutos}/$id', data: produto.toJson());
    return Produto.fromJson(resp.data);
  }

  Future<void> deleteProduto(int id) async {
    await _dio.delete('${ConstantsApi.urlProdutos}/$id');
  }
}
