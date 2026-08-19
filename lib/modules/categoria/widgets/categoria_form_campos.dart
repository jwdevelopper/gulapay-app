import 'package:flutter/material.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';

class CategoriaFormCampos extends StatelessWidget {
  const CategoriaFormCampos({
    super.key,
    required this.controleNome,
    required this.controleDescricao,
    required this.limiteNome,
    required this.limiteDescricao,
    required this.aoMudar,
  });

  final TextEditingController controleNome;
  final TextEditingController controleDescricao;
  final int limiteNome;
  final int limiteDescricao;
  final VoidCallback aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRotulo(
          'Nome *',
          contador: '${controleNome.text.length}/$limiteNome',
        ),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: controleNome,
          dica: 'Ex.: Pratos principais',
          tamanhoMax: limiteNome,
          aoMudar: (_) => aoMudar(),
          validador: (valor) {
            final nome = valor?.trim() ?? '';
            if (nome.isEmpty) return 'Informe o nome';
            if (nome.length < 2) return 'Mínimo de 2 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 14),
        AppRotulo(
          'Descrição',
          opcional: true,
          contador: '${controleDescricao.text.length}/$limiteDescricao',
        ),
        const SizedBox(height: 6),
        AppCampoTexto(
          controle: controleDescricao,
          dica: 'Detalhes, ingredientes, acompanhamentos...',
          tamanhoMax: limiteDescricao,
          maxLinhas: 4,
          minLinhas: 3,
          tipoTeclado: TextInputType.multiline,
          aoMudar: (_) => aoMudar(),
        ),
        const SizedBox(height: 18),
        const AppDica(
          'Use um nome curto e claro. A descrição aparece no cardápio '
          'digital pro cliente.',
        ),
      ],
    );
  }
}
