import 'package:flutter/material.dart';
import 'package:my_app_teste/model/categoria_dto.dart';
import 'package:my_app_teste/pages/categoria_form_page.dart';
import 'package:my_app_teste/services/categoria_service.dart';


class CategoriaListaPage extends StatefulWidget {
  const CategoriaListaPage({super.key});

  @override
  State<CategoriaListaPage> createState() => _CategoriaListaPageState();
}

class _CategoriaListaPageState extends State<CategoriaListaPage> {
  final Color corFundo = const Color(0xFFFCF8F2);
  final Color corLaranja = const Color(0xFFF25D27);
  final Color corTextoEscuro = const Color(0xFF4A342E);
  final Color corTextoClaro = const Color(0xFF8D7A74);

  final CategoriaService _categoriaService = CategoriaService();
  late Future<List<CategoriaDto>> _categoriasFuture;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  // Função para recarregar a lista sempre que precisar
  void _carregarCategorias() {
    setState(() {
      _categoriasFuture = _categoriaService.listarCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'Categorias',
                    style: TextStyle(color: corTextoEscuro, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'Gerencie seu cardápio',
                    style: TextStyle(color: corTextoClaro, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Barra de Busca
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar categoria...',
                  hintStyle: TextStyle(color: corTextoClaro),
                  prefixIcon: Icon(Icons.search, color: corTextoClaro),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Lista Dinâmica conectada na API
            Expanded(
              child: FutureBuilder<List<CategoriaDto>>(
                future: _categoriasFuture,
                builder: (context, snapshot) {
                  // Estado 1: Carregando
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: corLaranja));
                  }
                  
                  // Estado 2: Erro na requisição
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar categorias.'));
                  }

                  // Estado 3: Sucesso, mas a lista veio do backend com aquele seu DTO de erro
                  final categorias = snapshot.data ?? [];
                  if (categorias.isNotEmpty && categorias.first.nome == "Erro") {
                    return Center(child: Text(categorias.first.message ?? 'Erro desconhecido.'));
                  }

                  // Estado 4: Sucesso, mas lista vazia
                  if (categorias.isEmpty) {
                    return const Center(child: Text('Nenhuma categoria encontrada.'));
                  }

                  // Estado 5: Sucesso! Mostrando a lista
                  return ListView.separated(
                    itemCount: categorias.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return _buildCategoriaCard(
                        titulo: categoria.nome,
                        subtitulo: categoria.descricao ?? 'Sem descrição',
                        ativo: categoria.ativo ?? true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: corLaranja,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () async {
          // O "await" faz a tela de lista esperar a tela de formulário fechar.
          // Se retornar true (salvou com sucesso), ele recarrega a lista automaticamente!
          final bool? recarregar = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoriaFormPage()),
          );
          if (recarregar == true) {
            _carregarCategorias();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCategoriaCard({required String titulo, required String subtitulo, required bool ativo}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.category_rounded, color: corLaranja),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: ativo ? corTextoEscuro : Colors.grey, // Fica cinza se inativo
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: TextStyle(color: corTextoClaro, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: corTextoClaro),
            onPressed: () {
            },
          ),
        ],
      ),
    );
  }
}