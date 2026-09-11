import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/rotulos_unidade.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_base.dart';

/// Atalhos para as unidades que o sistema já conhece.
///
/// Tocar num deles preenche nome, símbolo, tipo e fator de uma vez. É o
/// caminho para o caso comum — cadastrar quilograma, litro ou dúzia — sem
/// exigir que se saiba de cor que o fator do kg é 1000.
///
/// O cadastro manual continua aberto logo abaixo: um estabelecimento que
/// compra em caixa fechada ainda precisa conseguir criar `cx`.
class AtalhosUnidadeBase extends StatelessWidget {
  /// Símbolo já preenchido no formulário, para destacar o atalho
  /// correspondente.
  final String? simboloAtual;

  /// Chamado com o atalho escolhido.
  final ValueChanged<UnidadeBase> aoEscolher;

  const AtalhosUnidadeBase({
    super.key,
    required this.simboloAtual,
    required this.aoEscolher,
  });

  @override
  Widget build(BuildContext context) {
    final selecionada = baseCorrespondente(simboloAtual);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Começar por uma unidade conhecida',
          style: TextStyle(
            color: AppTema.texto,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            for (final base in unidadesBase)
              AppChipFiltro(
                rotulo: '${base.nome} (${base.simbolo})',
                selecionado: base.simbolo == selecionada?.simbolo,
                aoTocar: () => aoEscolher(base),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          selecionada == null
              ? 'Ou preencha os campos abaixo para uma unidade própria.'
              : '${RotulosUnidade.tipo(selecionada.tipoMedida)} · '
                    '${selecionada.descricao}',
          style: const TextStyle(color: AppTema.textoSecundario, fontSize: 12),
        ),
      ],
    );
  }
}
