import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';

/// Estado vazio das listagens, em dois formatos.
///
/// Fonte única do "nada aqui" no app. Substituiu quatro implementações
/// separadas — `EmptyStateCard` (declarada **duas vezes**, em Produto e em
/// Insumo, com a mesma assinatura e implementações independentes),
/// `EntregadorEmptyState`, `EstoqueEmptyState` e a versão anterior deste
/// arquivo.
///
/// ## Formatos
///
/// O formato é escolhido automaticamente pelo conteúdo informado:
///
///  * **simples** — só [icone] e [mensagem]. Fica solto no meio da área
///    vazia, sem moldura. Use dentro de uma lista que já tem contexto ao
///    redor.
///  * **cartão** — quando há [titulo]. Ganha moldura, ícone em destaque e,
///    se [rotuloBotao] for informado, um botão de ação. Use quando o vazio
///    é a tela inteira e precisa orientar o próximo passo.
///
/// ## Exemplos
///
/// Simples, dentro de uma lista filtrada:
///
/// ```dart
/// const AppEstadoVazio(
///   icone: Icons.inbox_outlined,
///   mensagem: 'Nenhum cliente encontrado.',
/// )
/// ```
///
/// Cartão com ação primária (primeiro cadastro):
///
/// ```dart
/// AppEstadoVazio(
///   icone: Icons.inventory_2_outlined,
///   titulo: 'Nenhum insumo cadastrado',
///   mensagem: 'Cadastre o primeiro insumo para controlar o estoque.',
///   rotuloBotao: 'Cadastrar insumo',
///   aoTocarBotao: _abrirFormulario,
/// )
/// ```
///
/// Cartão com ação secundária (limpar um filtro que não achou nada):
///
/// ```dart
/// AppEstadoVazio(
///   icone: Icons.search_off_rounded,
///   titulo: 'Nada encontrado',
///   mensagem: 'Nenhum produto corresponde aos filtros aplicados.',
///   rotuloBotao: 'Limpar filtros',
///   iconeBotao: Icons.filter_alt_off_rounded,
///   secundario: true,
///   aoTocarBotao: _limparFiltros,
/// )
/// ```
class AppEstadoVazio extends StatelessWidget {
  /// Ícone ilustrativo. No formato cartão ganha um fundo arredondado.
  final IconData icone;

  /// Texto explicativo. No formato simples é o único texto exibido.
  final String mensagem;

  /// Título curto. **Informá-lo ativa o formato cartão.**
  final String? titulo;

  /// Rótulo do botão de ação. Sem ele o cartão não desenha botão.
  final String? rotuloBotao;

  /// Ícone do botão. Ignorado quando [rotuloBotao] é nulo.
  final IconData? iconeBotao;

  /// Ação do botão. Obrigatória na prática quando [rotuloBotao] é
  /// informado — sem ela o botão fica inerte.
  final VoidCallback? aoTocarBotao;

  /// Desenha o botão como contorno em vez de preenchido. Use para ações
  /// intermediárias ("limpar filtros"), reservando o preenchido para a
  /// ação principal da tela ("cadastrar").
  final bool secundario;

  /// Linha de dica adicional, abaixo do botão. Útil para explicar uma
  /// pré-condição ("cadastre um insumo antes de criar o lote").
  final String? dica;

  const AppEstadoVazio({
    super.key,
    required this.icone,
    required this.mensagem,
    this.titulo,
    this.rotuloBotao,
    this.iconeBotao,
    this.aoTocarBotao,
    this.secundario = false,
    this.dica,
  });

  /// `true` quando o widget renderiza no formato cartão.
  bool get _ehCartao => titulo != null;

  @override
  Widget build(BuildContext context) {
    return _ehCartao ? _construirCartao() : _construirSimples();
  }

  Widget _construirSimples() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 36, color: AppTema.primariaEscura),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTema.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _construirCartao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTema.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTema.bordaSuave),
        boxShadow: const [
          BoxShadow(
            color: AppTema.sombra,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTema.preenchimentoCampo,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icone, color: AppTema.primaria, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            titulo!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTema.texto,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTema.textoSecundario,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (rotuloBotao != null) ...[
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: _construirBotao()),
          ],
          if (dica != null) ...[
            const SizedBox(height: 12),
            Text(
              dica!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTema.textoSecundario,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirBotao() {
    final icone = Icon(iconeBotao ?? Icons.add_rounded);
    final rotulo = Text(rotuloBotao!);
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const espacamento = EdgeInsets.symmetric(vertical: 15);

    if (secundario) {
      return OutlinedButton.icon(
        onPressed: aoTocarBotao,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTema.texto,
          backgroundColor: AppTema.superficieAlt,
          side: const BorderSide(color: AppTema.borda),
          shape: forma,
          padding: espacamento,
        ),
        icon: icone,
        label: rotulo,
      );
    }

    return ElevatedButton.icon(
      onPressed: aoTocarBotao,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTema.primaria,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppTema.primariaPressionada.withValues(alpha: 0.35),
        shape: forma,
        padding: espacamento,
      ),
      icon: icone,
      label: rotulo,
    );
  }
}
