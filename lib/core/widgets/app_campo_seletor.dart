import 'package:flutter/material.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/theme/decoracoes_app.dart';

/// Campo que mostra uma escolha e abre um seletor ao toque.
///
/// É o campo de formulário que não se digita: mostra o que está escolhido
/// (ou um convite a escolher) e delega ao toque a abertura de uma folha,
/// um calendário ou um diálogo. Quem chama decide o que abrir — este widget
/// só desenha o campo.
///
/// Fonte única de um desenho que existia em quatro cópias praticamente
/// idênticas: `CampoSeletorComanda`, `SeletorInsumo` (estoque),
/// `SeletorCategoria` (produto) e os campos de insumo/validade do
/// formulário de lote.
///
/// ## Estados
///
///  * **vazio** — [valor] em branco: o texto fica em cinza com o convite de
///    [dica] e o ícone fica no fundo suave;
///  * **preenchido** — o texto fica escuro e o ícone ganha o fundo laranja;
///  * **erro** — a borda fica vermelha, para casar com a mensagem de
///    validação exibida abaixo;
///  * **desabilitado** — [aoTocar] nulo: o campo perde o chevron e o toque,
///    virando exibição de um dado que não pode mudar naquele contexto (ex.:
///    o insumo de um lote em edição).
///
/// ```dart
/// AppCampoSeletor(
///   rotulo: 'Insumo',
///   obrigatorio: true,
///   valor: insumo?.nome ?? '',
///   detalhe: insumo == null ? null : 'Saldo: ${insumo.saldo}',
///   icone: Icons.inventory_2_rounded,
///   erro: tentouSalvar && insumo == null,
///   aoTocar: _abrirSelecaoInsumo,
/// )
/// ```
class AppCampoSeletor extends StatelessWidget {
  /// Nome do campo, exibido acima do valor.
  final String rotulo;

  /// Marca o rótulo com asterisco. Só sinaliza — a validação continua
  /// sendo responsabilidade de quem chama.
  final bool obrigatorio;

  /// O que está escolhido. Vazio ativa o estado de convite.
  final String valor;

  /// Segunda linha, exibida só quando há [valor]. Use para o dado de apoio
  /// que confirma a escolha (telefone do cliente, saldo do insumo).
  final String? detalhe;

  /// Texto exibido quando [valor] está vazio.
  final String dica;

  /// Ícone à esquerda.
  final IconData icone;

  /// Pinta a borda de vermelho.
  final bool erro;

  /// Ação ao tocar. `null` desabilita o campo.
  final VoidCallback? aoTocar;

  const AppCampoSeletor({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.icone,
    required this.aoTocar,
    this.detalhe,
    this.dica = 'Selecione uma opção',
    this.obrigatorio = false,
    this.erro = false,
  });

  @override
  Widget build(BuildContext context) {
    final preenchido = valor.isNotEmpty;
    final habilitado = aoTocar != null;

    return Opacity(
      opacity: habilitado ? 1 : 0.7,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(DecoracoesApp.raioCampo),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: DecoracoesApp.campo(erro: erro),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: preenchido
                      ? AppTema.primaria
                      : AppTema.preenchimentoCampo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icone,
                  color: preenchido ? Colors.white : AppTema.primaria,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      obrigatorio ? '$rotulo *' : rotulo,
                      style: const TextStyle(
                        color: AppTema.texto,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preenchido ? valor : dica,
                      style: TextStyle(
                        color: preenchido
                            ? AppTema.texto
                            : AppTema.textoSecundario,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (preenchido && (detalhe ?? '').isNotEmpty)
                      Text(
                        detalhe!,
                        style: const TextStyle(
                          color: AppTema.textoSecundario,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (habilitado)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTema.textoSecundario,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
