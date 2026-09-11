import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/unidade_medida/dto/unidade_medida_response.dart';

/// Campo de escolha de unidade de medida.
///
/// Compartilhado pelos formulários que precisam de uma unidade cadastrada —
/// hoje Lote e Insumo. Vive no módulo `unidade_medida` (e não em `core`)
/// porque conhece [UnidadeMedidaResponse]; o core não depende de módulos.
///
/// ## Os três estados
///
/// A lista vem de `GET /unidades-medida`, então o campo precisa dar conta
/// de mais do que "escolher":
///
///  * **carregando** — mostra o próprio estado em vez de um dropdown vazio.
///    Sem isso o usuário abre a lista, não vê nada e conclui que não há
///    unidades cadastradas;
///  * **erro** — explica e oferece [aoRecarregar], em vez de deixar a tela
///    num impasse silencioso;
///  * **pronto** — o dropdown.
///
/// ```dart
/// CampoUnidadeMedida(
///   unidades: _unidades,
///   selecionadaId: _dados.unidadeId,
///   carregando: _carregando,
///   erro: _erroUnidades,
///   aoRecarregar: _carregarUnidades,
///   aoSelecionar: (id) => setState(() => _unidadeId = id),
/// )
/// ```
class CampoUnidadeMedida extends StatelessWidget {
  /// Unidades disponíveis. Ids nulos são ignorados.
  final List<UnidadeMedidaResponse> unidades;

  /// Id da unidade escolhida. Um id que não está em [unidades] é tratado
  /// como "nada escolhido" — sem isso o `DropdownButton` lança em tempo de
  /// execução.
  final int? selecionadaId;

  /// Verdadeiro enquanto a lista está sendo buscada.
  final bool carregando;

  /// Mensagem da falha de carga, quando houve uma.
  final String? erro;

  /// Ação do botão "Recarregar". Sem ela o estado de erro não oferece saída.
  final VoidCallback? aoRecarregar;

  /// Chamado com o id escolhido.
  final ValueChanged<int?> aoSelecionar;

  /// Texto do rótulo acima do campo.
  final String rotulo;

  const CampoUnidadeMedida({
    super.key,
    required this.unidades,
    required this.selecionadaId,
    required this.carregando,
    required this.aoSelecionar,
    this.erro,
    this.aoRecarregar,
    this.rotulo = 'Unidade de medida',
  });

  /// O id escolhido, ou `null` quando ele não está entre [unidades].
  int? get _valorValido =>
      unidades.any((u) => u.id == selecionadaId) ? selecionadaId : null;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRotulo(rotulo),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: DecoracoesApp.campoPlano(erro: erro != null),
        child: _conteudo(),
      ),
      if (erro != null) ...[
        const SizedBox(height: 6),
        Text(erro!, style: const TextStyle(color: AppTema.erro, fontSize: 12)),
      ],
    ],
  );

  Widget _conteudo() {
    if (carregando) return const _Carregando();
    if (erro != null) return _Falha(aoRecarregar: aoRecarregar);
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value: _valorValido,
        hint: const Text(
          'Selecione a unidade',
          style: TextStyle(color: AppTema.textoSecundario),
        ),
        items: [
          for (final unidade in unidades)
            if (unidade.id != null)
              DropdownMenuItem(
                value: unidade.id,
                child: Text(
                  '${unidade.nome ?? ''} (${unidade.simbolo ?? ''})',
                  style: const TextStyle(color: AppTema.texto),
                ),
              ),
        ],
        onChanged: aoSelecionar,
      ),
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTema.primaria,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Carregando unidades…',
          style: TextStyle(color: AppTema.textoSecundario),
        ),
      ],
    ),
  );
}

class _Falha extends StatelessWidget {
  final VoidCallback? aoRecarregar;

  const _Falha({this.aoRecarregar});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Não foi possível carregar as unidades.',
            style: TextStyle(color: AppTema.textoSecundario, fontSize: 13),
          ),
        ),
        if (aoRecarregar != null)
          TextButton.icon(
            onPressed: aoRecarregar,
            style: TextButton.styleFrom(foregroundColor: AppTema.primaria),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Recarregar'),
          ),
      ],
    ),
  );
}
