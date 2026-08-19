import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_tag.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';

class CategoriaCardConteudo extends StatelessWidget {
  const CategoriaCardConteudo({
    super.key,
    required this.categoria,
    required this.aoAbrir,
    required this.acoes,
  });

  final Categoria categoria;
  final VoidCallback aoAbrir;
  final Widget acoes;

  @override
  Widget build(BuildContext context) {
    final ativa = categoria.ativo ?? true;
    final nome = categoria.nome.trim();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoAbrir,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTema.bordaCampo),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTema.fundoDica,
                child: Text(
                  nome.isNotEmpty ? nome.characters.first.toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTema.primaria,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ativa
                            ? AppTema.textoEscuro
                            : AppTema.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (categoria.descricao?.trim().isNotEmpty ?? false)
                          ? categoria.descricao!
                          : 'Sem descrição',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTema.textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    if (!ativa) ...[
                      const SizedBox(height: 6),
                      AppTag(
                        'Inativa',
                        fundo: Colors.red.shade100,
                        cor: Colors.red.shade800,
                      ),
                    ],
                  ],
                ),
              ),
              acoes,
              const SizedBox(width: 4),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: AppTema.primariaEscura,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
