import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/utils/numero_br.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

/// Traduções e cores dos enums de UnidadeMedida vindos da API.
///
/// O backend devolve `MASSA`, `VOLUME` e `UNIDADE`; estas funções são o
/// único lugar que converte isso em texto e cor de tela. Todas caem em um
/// padrão seguro quando o valor não é reconhecido.
class RotulosUnidade {
  const RotulosUnidade._();

  /// Os três tipos de medida do backend (enum `TipoMedida`).
  static const tipos = ['MASSA', 'VOLUME', 'UNIDADE'];

  /// Nome legível do tipo de medida.
  static String tipo(String? valor) => switch (valor) {
    'MASSA' => 'Massa',
    'VOLUME' => 'Volume',
    'UNIDADE' => 'Unidade',
    _ => valor ?? '—',
  };

  /// Cor que identifica o tipo. Cada família de medida ganha a sua para o
  /// olho separar massa de volume de contagem numa lista longa.
  static Color corTipo(String? valor) => switch (valor) {
    'MASSA' => AppTema.primaria,
    'VOLUME' => AppTema.info,
    'UNIDADE' => AppTema.sucesso,
    _ => AppTema.primariaEscura,
  };

  /// Fator de conversão sem zeros supérfluos (`1000`, `0,5`).
  static String fator(double? valor) =>
      valor == null ? '?' : formatarNumeroBr(valor, casas: null);

  /// A unidade é a referência do seu tipo?
  ///
  /// Deve haver exatamente uma com `fatorParaBase = 1` por tipo — é ela que
  /// define em que grandeza os saldos são guardados (seção 4.5.1).
  static bool ehBase(UnidadeMedidaResponse unidade) =>
      (unidade.fatorParaBase ?? 0) == 1.0;

  /// Segunda linha do card: o papel da unidade dentro do seu tipo.
  static String descricao(UnidadeMedidaResponse unidade) => ehBase(unidade)
      ? 'Referência de ${tipo(unidade.tipoMedida)}'
      : '${tipo(unidade.tipoMedida)} · '
            '×${fator(unidade.fatorParaBase)} em relação à base';
}
