/// Biblioteca de componentes compartilhados do GulaPay.
///
/// Importe este arquivo para ter acesso a todo o catálogo de uma vez:
///
/// ```dart
/// import 'package:my_app_teste/core/widgets/app_widgets.dart';
/// ```
///
/// Todos os componentes leem cor de [AppTema] e moldura de
/// [DecoracoesApp] — nenhum usa `Theme.of(context)`, que no app resolve
/// para o `seedColor` azul do `MaterialApp` e destoaria da identidade
/// laranja-areia.
///
/// ## Catálogo
///
/// **Entrada de dados**
///  * [AppCampoBusca] — busca das listagens, com botão de limpar.
///  * [AppCampoTexto] — texto comum de formulário.
///  * [AppCampoData] — data, abre o calendário temático.
///  * [AppCampoFormulario] — campo de texto com a moldura padrão.
///  * [AppCampoSeletor] — campo que abre um seletor ao toque.
///  * [AppCampoInterruptor] — liga/desliga com moldura de campo.
///  * [AppRotuloCampo] — rótulo com asterisco de obrigatório.
///  * [AppMensagemErroCampo] — erro inline abaixo de um campo.
///
/// **Ação**
///  * [AppBotaoComponente] — botão preenchido com ícone opcional.
///  * [AppBotaoIcone] — botão quadrado de ícone (cabeçalhos).
///  * [AppBarraAcoes] — par cancelar/confirmar no rodapé de formulário.
///  * [AppMenuAcoes] — menu de 3 pontos (editar/excluir).
///  * [AppExpandableFab] — FAB que abre em leque.
///
/// **Exibição**
///  * [AppEstadoVazio] — vazio simples ou em cartão com ação.
///  * [AppCarregando] — indicador de carregamento.
///  * [AppCartaoAviso] — faixa de erro, dica ou sucesso.
///  * [AppDica] — dica curta com emoji.
///  * [AppTag] — etiqueta colorida.
///  * [AppLinhaResumo] — linha "rótulo → valor" de cartões de resumo.
///  * [AppChipFiltro] — pílula de filtro selecionável.
///  * [AppFileiraChips] — fileira rolável de chips de filtro.
///
/// **Estrutura e navegação**
///  * [abrirFolhaSelecao] — folha inferior com a moldura padrão.
///  * [AppItemSelecionavel] — item de lista com estado de selecionado.
///  * [AppListaVazia] — vazio enxuto dentro de uma folha.
///  * [AppCartaoDeslizavel] — card com swipe-to-delete.
///  * [AppDialogoConfirmacao] — diálogo de confirmação/exclusão.
///  * [abrirSeletorData] — calendário temático avulso.
///
/// Veja também:
///  * `core/theme/app_tema.dart` — paleta única.
///  * `core/theme/decoracoes_app.dart` — molduras compartilhadas.
library;

export 'app_barra_acoes.dart';
export 'app_botao_componente.dart';
export 'app_botao_icone.dart';
export 'app_campo_busca.dart';
export 'app_campo_formulario.dart';
export 'app_campo_interruptor.dart';
export 'app_campo_seletor.dart';
export 'app_campo_texto.dart';
export 'app_carregando.dart';
export 'app_cartao_aviso.dart';
export 'app_chip_filtro.dart';
export 'app_cartao_deslizavel.dart';
export 'app_data.dart';
export 'app_dialogo_confirmacao.dart';
export 'app_dica.dart';
export 'app_estado_vazio.dart';
export 'app_expandable_fab.dart';
export 'app_folha_selecao.dart';
export 'app_linha_resumo.dart';
export 'app_menu_acoes.dart';
export 'app_rotulo.dart';
export 'app_rotulo_campo.dart';
export 'app_tag.dart';
