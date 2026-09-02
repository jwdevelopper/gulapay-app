# Plano de migração — `movimentacao_form_page.dart`

> Documento de planejamento. **Nenhum código foi alterado ainda.**
> Base analisada: `lib/modules/movimentacao_estoque/page/movimentacao_form_page.dart`
> (693 linhas, commit atual da branch).

---

## 1. Diagnóstico

### 1.1. Números

| Métrica | Hoje |
|---|---|
| Linhas no arquivo | **693** |
| Classes no arquivo | 4 (`_ChoiceOption`, `MovimentacaoFormPage`, `_FormHeaderIconButton`, `_SummaryRow`) |
| Métodos `_build*` dentro do State | **16** |
| Bottom sheets construídos inline | 2 (56 e 58 linhas cada) |
| Widgets reutilizáveis extraídos | 0 |
| Cobertura de testes | **0** |
| Identificadores em inglês | ~90% do arquivo |

### 1.2. Mapa do arquivo atual

| Linhas | Elemento | Destino proposto |
|---|---|---|
| 8–22 | `_ChoiceOption` + `_tipoOptions` | `models/tipos_movimentacao.dart` |
| 30–52 | Estado (5 controllers + 12 campos) | permanece na página |
| 93–115 | `_loadInsumos` / `_loadUnidades` / `_loadLotes` | permanece (com tratamento de erro) |
| 117–149 | `_parseQty` / `_parseCusto` / `_clearValidation` / `_validateStep` | `models/validacao_movimentacao.dart` |
| 167–192 | `_submit` (monta payload inline) | payload vai para o modelo |
| 194–249 | `_openInsumoSelector` | `widgets/form/seletor_insumo.dart` |
| 251–263 | `_insumoTipoMedida` / `_unidadesCompativeis` | permanece (regra de dados) |
| 265–322 | `_openUnidadeSelector` | `widgets/form/seletor_unidade.dart` |
| 324–348 | `_buildHeader` + `_buildProgress` | `widgets/form/cabecalho_wizard.dart` |
| 350–364 | `_buildTextField` | `widgets/form/campo_texto_estoque.dart` |
| 366–385 | `_buildErrorBanner` + `_buildInfoCard` | `widgets/form/avisos_formulario.dart` |
| 387–424 | `_buildTypeOption` + `_buildStep0` | `widgets/form/etapa_tipo.dart` |
| 426–481 | `_buildInsumoSelector` / `_buildUnidadeSelector` / `_buildStep1` | `widgets/form/etapa_insumo_quantidade.dart` |
| 483–546 | `_buildLoteSelector` + `_buildStep2` | `widgets/form/etapa_lote_detalhes.dart` + `seletor_lote.dart` |
| 548–570 | `_buildSummary` | `widgets/form/resumo_movimentacao.dart` |
| 572–600 | `_buildSuccessScreen` | `widgets/form/tela_sucesso.dart` |
| 602–637 | `_buildBottomButtons` | `widgets/form/rodape_wizard.dart` |
| 664–677 | `_FormHeaderIconButton` | absorvido pelo cabeçalho |
| 679–692 | `_SummaryRow` | absorvido pelo resumo |

### 1.3. Problemas funcionais encontrados

Estes **não são só organização** — são comportamentos incorretos que a migração deve corrigir:

| # | Problema | Evidência | Gravidade |
|---|---|---|---|
| P1 | **Etapa 3 não valida nada.** `_validateStep()` (L128) trata `_step == 0` e `_step == 1`; a etapa 2 cai no `return true` da L148. Os asteriscos de "Validade *", "Custo unitário *" e "Lote a baixar *" são decorativos. | L128–149 | Alta |
| P2 | **Saída sem lote passa silenciosamente.** `_buildLoteSelector()` retorna `SizedBox.shrink()` quando `_lotes.isEmpty` (L484) — a seção some da tela e o registro é enviado sem `loteId`. | L484 | Alta |
| P3 | **Validade é texto livre.** Campo aceita qualquer string (`31/12/2026`, `amanhã`), enviada crua ao backend → 400. | L526 | Alta |
| P4 | **Calendário fora do tema.** Os dois `showDatePicker` existentes no app (`lote_form_page.dart:117` e `estoque_page.dart:235`) herdam o tema do `main.dart`, que é `ColorScheme.fromSeed(seedColor: Colors.blueAccent)` — **abrem azuis num app laranja**. | `main.dart:17` | Média |
| P5 | **Falha de rede é engolida.** Os 3 loaders usam `catch (_) {}` (L98, L106, L114); se a API cair, as listas ficam vazias sem explicação. | L93–115 | Média |
| P6 | **Asterisco duplicado à mão** em 6 rótulos, sem fonte única. | L411, 439, 469, 487, 524, 528 | Baixa |

---

## 2. Arquitetura alvo

```
lib/
├── core/widgets/
│   ├── app_seletor_data.dart          [NOVO] calendário temático reutilizável
│   └── app_campo_data.dart            [NOVO] input de data (abre o calendário)
│
└── modules/movimentacao_estoque/
    ├── models/
    │   ├── tipos_movimentacao.dart    [NOVO] os 5 tipos + rótulo amigável
    │   └── validacao_movimentacao.dart[NOVO] dados + regras de obrigatoriedade
    ├── widgets/form/
    │   ├── campo_texto_estoque.dart   [NOVO]
    │   ├── rotulo_campo.dart          [NOVO] fonte única do "*"
    │   ├── avisos_formulario.dart     [NOVO] banner de erro + cartão de dica
    │   ├── folha_selecao.dart         [NOVO] casca comum das bottom sheets
    │   ├── seletor_insumo.dart        [NOVO]
    │   ├── seletor_unidade.dart       [NOVO]
    │   ├── seletor_lote.dart          [NOVO]
    │   ├── cabecalho_wizard.dart      [NOVO]
    │   ├── rodape_wizard.dart         [NOVO]
    │   ├── resumo_movimentacao.dart   [NOVO]
    │   ├── tela_sucesso.dart          [NOVO]
    │   ├── etapa_tipo.dart            [NOVO]
    │   ├── etapa_insumo_quantidade.dart [NOVO]
    │   └── etapa_lote_detalhes.dart   [NOVO]
    └── page/
        └── movimentacao_form_page.dart[REESCRITO] ~200 linhas, só orquestração
```

**Meta:** nenhum arquivo novo acima de ~200 linhas; a página fica responsável apenas por estado, navegação entre etapas e envio.

---

## 3. Os quatro pontos pedidos

### 3.1. Componentes que podem ser componentizados

| Componente | Origem | Reutilizável fora do form? |
|---|---|---|
| `FolhaSelecao` — casca das bottom sheets (alça, título, botão fechar, lista) | duplicada em `_openInsumoSelector` e `_openUnidadeSelector` | Sim — qualquer módulo com seleção em sheet |
| `ItemSelecionavel` — cartão com borda/fundo de selecionado | repetido 4× (insumo na sheet, unidade, lote, tipo) | Sim |
| `CabecalhoWizard` — voltar + título + etapa + barra de progresso | `_buildHeader` + `_buildProgress` | Sim — serve a qualquer form multi-etapa |
| `RodapeWizard` — par de botões voltar/avançar com estado de carregando | `_buildBottomButtons` | Sim |
| `BannerValidacao` / `CartaoInfo` | `_buildErrorBanner` / `_buildInfoCard` (estrutura idêntica, só mudam ícone e cor) | Sim — unificar num `_CartaoAviso` privado |
| `ResumoMovimentacao` + linha de resumo | `_buildSummary` + `_SummaryRow` | Não (específico), mas usado em 2 telas |
| `TelaSucesso` | `_buildSuccessScreen` | Parcial — vale um padrão de tela de sucesso |

> **Nota:** `_buildErrorBanner` e `_buildInfoCard` têm exatamente a mesma estrutura (Container + ícone + texto), diferindo só em ícone e cor da borda. Merecem um widget-base comum, não duas cópias.

### 3.2. Widgets que merecem arquivo próprio

Prioridade decrescente (tamanho × independência):

1. `seletor_insumo.dart` — 56 linhas de sheet + 23 do campo = **79 linhas**
2. `seletor_unidade.dart` — 58 + 13 = **71 linhas**
3. `seletor_lote.dart` — 36 linhas, e é onde mora o bug **P2**
4. `etapa_tipo.dart` — cartão de tipo + grid = **37 linhas**
5. `resumo_movimentacao.dart` — 23 + 14 = **37 linhas**
6. `tela_sucesso.dart` — **29 linhas**
7. `rodape_wizard.dart` — **36 linhas**
8. `cabecalho_wizard.dart` — 18 + 6 + 14 = **38 linhas**
9. `etapa_insumo_quantidade.dart` e `etapa_lote_detalhes.dart` — orquestram os itens acima

### 3.3. Inputs reutilizáveis

| Input | Situação hoje | Proposta |
|---|---|---|
| Campo de texto | `_buildTextField` com **8 parâmetros** (`price`, `largeText`, `suffix`, `error`…) dentro do State | `CampoTextoEstoque` em arquivo próprio, mesma API |
| Rótulo com `*` | String literal `'Campo *'` repetida 6× | `RotuloCampo(texto, obrigatorio: true)` — asterisco em `EstoquePalette.error`, **fonte única** |
| Mensagem de erro do campo | `if (_xError) ...[SizedBox, Text(...)]` repetido 2× | `MensagemErroCampo(texto, visivel: bool)` |
| Campo de data | `TextField` cru com `keyboardType: datetime` | **`AppCampoData`** — ver 3.4 |
| Campo monetário | flag `price: true` que injeta prefixo `R$ ` | manter no `CampoTextoEstoque` (não vale widget separado) |

**Sobre o `AppRotulo` que já existe em `core/widgets/`:** ele usa `AppTema` (paleta global) e tem a flag `opcional`, semântica **inversa** da que precisamos. O módulo de estoque usa `EstoquePalette`, que é uma paleta própria. Duas saídas:

- **(A)** criar `RotuloCampo` local ao módulo, usando `EstoquePalette` — isolado, sem risco de regressão nas outras telas;
- **(B)** estender `AppRotulo` com `obrigatorio` e migrar o módulo para `AppTema`.

**Recomendação: (A) agora, (B) como tarefa separada.** Unificar `AppTema` × `EstoquePalette` mexe em 5 módulos e não deve entrar no escopo deste refactor.

### 3.4. Componente de calendário reutilizável e fiel ao tema

**O problema concreto:** `main.dart:17` define `ColorScheme.fromSeed(seedColor: Colors.blueAccent)`. Como `showDatePicker` herda o `Theme` do contexto, **os dois calendários existentes no app abrem em azul** — destoando de toda a identidade laranja-areia. Além disso, a tela de movimentação nem oferece calendário: digita-se a data à mão.

**Proposta — dois widgets em `core/widgets/`:**

```dart
// app_seletor_data.dart
Future<DateTime?> abrirSeletorData(
  BuildContext context, {
  DateTime? dataInicial,
  DateTime? dataMinima,
  DateTime? dataMaxima,
  String textoAjuda = 'Selecione a data',
});
```

Envolve o `showDatePicker` num `Theme` construído a partir de `AppTema`:

| Elemento do calendário | Cor |
|---|---|
| Fundo do diálogo | `AppTema.cartao` |
| Cabeçalho (faixa superior) | `AppTema.primaria` / texto branco |
| Dia selecionado | `AppTema.primaria` / texto branco |
| Dia de hoje (contorno) | `AppTema.primariaEscura` |
| Texto dos dias | `AppTema.textoEscuro` |
| Dias desabilitados | `AppTema.textoSecundario` |
| Botões Cancelar/OK | `AppTema.primaria` |
| Cantos | 16px, alinhado aos cartões do app |

Também fixa `locale: pt_BR` e o formato `dd/mm/aaaa` na exibição.

```dart
// app_campo_data.dart
class AppCampoData extends StatelessWidget {
  final DateTime? valor;
  final String dica;              // 'dd/mm/aaaa'
  final bool erro;
  final bool obrigatorio;
  final ValueChanged<DateTime> aoSelecionar;
}
```

Campo tocável que mostra a data formatada em pt-BR (ou a dica quando vazio), com ícone de calendário à direita — abre `abrirSeletorData` no toque. O estado deixa de ser `String` e passa a ser `DateTime?`, o que **elimina o problema P3 na raiz**: não há como digitar data inválida.

**Ganho colateral:** os dois `showDatePicker` já existentes (`lote_form_page.dart:117` e `estoque_page.dart:235`) passam a usar o mesmo componente — três telas com o mesmo calendário, corrigindo o azul em todas.

> **Dependência:** exibir nomes de mês/dia em português exige `flutter_localizations` no `pubspec.yaml` e `localizationsDelegates` + `supportedLocales: [Locale('pt','BR')]` no `MaterialApp`. Hoje o app não tem isso — sem essa configuração o calendário abre em inglês. É uma tarefa da **Fase 1**.

### 3.5. Código em português-BR

Convenção do projeto (CLAUDE.md §14): "Nomes em português (`UsuarioServico`, `SessaoAutenticacao`, `AppCampoBusca`) seguem o padrão já estabelecido pelo grupo." Este arquivo está quase todo em inglês.

**Tabela de renomeação:**

| Hoje | Proposto |
|---|---|
| `_ChoiceOption` | `OpcaoTipoMovimentacao` |
| `_tipoOptions` | `tiposMovimentacao` |
| `_selectedTipo` / `_selectedInsumo` / `_selectedLote` / `_selectedUnidade` | `_tipo` / `_insumo` / `_lote` / `_unidade` |
| `_saving` / `_success` / `_step` | `_salvando` / `_sucesso` / `_etapa` |
| `_validationMessage` | `_validacao` (objeto `ResultadoValidacao`) |
| `_tipoError`, `_insumoError`, `_quantidadeError`, `_unidadeError` | `enum CampoMovimentacao` + `Set<CampoMovimentacao>` |
| `_loadInsumos` / `_loadUnidades` / `_loadLotes` | `_carregarInsumos` / `_carregarUnidades` / `_carregarLotes` |
| `_parseQty` / `_parseCusto` | `quantidadeNumerica` / `custoNumerico` (getters do modelo) |
| `_clearValidation` / `_validateStep` | `_limparErro` / `ValidadorMovimentacao.validarEtapa` |
| `_next` / `_prev` / `_submit` | `_avancar` / `_voltar` / `_enviar` |
| `_openInsumoSelector` / `_openUnidadeSelector` | `_abrirSelecaoInsumo` / `_abrirSelecaoUnidade` |
| `_buildStep0/1/2` | `EtapaTipo` / `EtapaInsumoQuantidade` / `EtapaLoteDetalhes` |
| `_buildHeader` + `_buildProgress` | `CabecalhoWizard` |
| `_buildBottomButtons` | `RodapeWizard` |
| `_buildSummary` / `_SummaryRow` | `ResumoMovimentacao` / `_LinhaResumo` |
| `_buildSuccessScreen` | `TelaSucesso` |
| `_buildTextField` | `CampoTextoEstoque` |
| `_buildErrorBanner` / `_buildInfoCard` | `BannerValidacao` / `CartaoInfo` |
| `_FormHeaderIconButton` | `_BotaoIconeCabecalho` |
| `_isEntrada` | `ehEntrada` |
| `_stepLabel` / `_headerTitle` / `_tipoLabel` | `_rotuloEtapa` / `_titulo` / `rotuloTipoMovimentacao()` |
| Parâmetros: `controller`, `hint`, `onChanged`, `maxLines`, `keyboardType`, `error`, `price`, `largeText`, `suffix` | `controlador`, `dica`, `aoAlterar`, `maxLinhas`, `tipoTeclado`, `erro`, `preco`, `textoGrande`, `sufixo` |

**Fica em inglês (intencionalmente):**
- Valores de enum da API (`ENTRADA_COMPRA`, `SAIDA_PERDA_VALIDADE`…) — contrato do backend;
- Chaves do payload (`insumoId`, `custoUnitario`…) — contrato do backend;
- `EstoquePalette` e membros — já usado por 5 outros arquivos do módulo; renomear é tarefa à parte.

---

## 4. Fases da migração

Cada fase é um commit verificável. **Nenhuma quebra a anterior.**

### Fase 0 — Rede de segurança (antes de mover qualquer código)
- [ ] Teste de widget do fluxo feliz atual: percorrer as 3 etapas e conferir o payload montado.
- [ ] Registrar em vídeo/print o comportamento atual das 3 etapas (referência visual pós-refactor).

> Sem isso o refactor é feito no escuro — hoje a tela tem **zero** testes.

### Fase 1 — Fundação de tema e localização
- [ ] Adicionar `flutter_localizations` ao `pubspec.yaml`.
- [ ] Configurar `localizationsDelegates` + `supportedLocales: [Locale('pt','BR')]` no `MaterialApp`.
- [ ] Criar `core/widgets/app_seletor_data.dart` (calendário temático).
- [ ] Criar `core/widgets/app_campo_data.dart` (input de data).
- [ ] **Verificação:** abrir o calendário em `lote_form_page` — deve estar laranja e em português.

### Fase 2 — Modelo e validação (sem tocar na UI)
- [ ] `models/tipos_movimentacao.dart` — mover `_ChoiceOption` → `OpcaoTipoMovimentacao`.
- [ ] `models/validacao_movimentacao.dart` — `DadosMovimentacao`, `CampoMovimentacao`, `ResultadoValidacao`, `ValidadorMovimentacao`.
- [ ] Implementar as regras faltantes da etapa 3 (**corrige P1**):
  - entrada → validade e custo obrigatórios;
  - saída/ajuste → lote obrigatório.
- [ ] Mover a montagem do payload de `_submit` para `DadosMovimentacao.paraPayload()`.
- [ ] **Testes unitários** da validação (classe pura, sem `BuildContext`) — ~15 casos.
- [ ] **Verificação:** `flutter test` verde; a tela ainda funciona igual (a página passa a chamar o validador).

### Fase 3 — Inputs reutilizáveis
- [ ] `widgets/form/rotulo_campo.dart` — fonte única do `*` (**corrige P6**).
- [ ] `widgets/form/campo_texto_estoque.dart`.
- [ ] `widgets/form/avisos_formulario.dart` — `BannerValidacao` + `CartaoInfo` sobre base comum.
- [ ] Trocar os 6 rótulos literais por `RotuloCampo(obrigatorio: true)`.
- [ ] **Verificação:** comparação visual com os prints da Fase 0.

### Fase 4 — Seletores
- [ ] `widgets/form/folha_selecao.dart` — casca comum + `ItemSelecionavel` + `ListaVazia`.
- [ ] `widgets/form/seletor_insumo.dart`, `seletor_unidade.dart`, `seletor_lote.dart`.
- [ ] No seletor de lote, trocar o `SizedBox.shrink()` por estado vazio explícito (**corrige P2**).
- [ ] **Verificação:** abrir as duas sheets; testar insumo sem lote.

### Fase 5 — Cromo do wizard
- [ ] `cabecalho_wizard.dart` (absorve `_FormHeaderIconButton`).
- [ ] `rodape_wizard.dart`.
- [ ] `resumo_movimentacao.dart` (absorve `_SummaryRow`).
- [ ] `tela_sucesso.dart`.

### Fase 6 — Etapas
- [ ] `etapa_tipo.dart`, `etapa_insumo_quantidade.dart`, `etapa_lote_detalhes.dart`.
- [ ] Na etapa 3, trocar o campo de validade por `AppCampoData` (**corrige P3**).
- [ ] Estado da validade passa de `String` para `DateTime?`.

### Fase 7 — Página e limpeza
- [ ] Reescrever `movimentacao_form_page.dart` como orquestrador (~200 linhas).
- [ ] Aplicar a tabela de renomeação (§3.5) em todo o módulo.
- [ ] Tratar os `catch (_) {}` dos loaders com mensagem ao usuário (**corrige P5**).
- [ ] Adicionar os novos widgets ao barrel `widgets/estoque_widgets.dart`.
- [ ] **Verificação:** `flutter analyze` sem erros; `flutter test` verde; `dart format`.

### Fase 8 — Propagação (opcional, fora do escopo mínimo)
- [ ] Migrar `lote_form_page.dart:117` e `estoque_page.dart:235` para `AppSeletorData`.
- [ ] Avaliar unificação `AppTema` × `EstoquePalette` (tarefa própria, mexe em 5 módulos).

---

## 5. Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Refactor sem teste quebra o fluxo silenciosamente | Fase 0 é pré-requisito, não opcional |
| `flutter_localizations` altera o `MaterialApp` (afeta o app inteiro) | Fase isolada, verificada sozinha antes de seguir |
| Validade vira `DateTime?` e o payload muda de formato | `paraPayload()` centraliza a serialização ISO; coberto por teste na Fase 2 |
| Tornar o lote obrigatório é **mais restritivo que o backend** (a API aceita saída sem `loteId`, aplicando FEFO; só `AJUSTE_INVENTARIO` exige lote) | **Decisão pendente** — ver §6 |
| Excesso de arquivos pequenos dificulta navegação | Barrel `estoque_widgets.dart` já é convenção do módulo |
| Divergência visual pós-migração | Prints da Fase 0 como referência de comparação |

---

## 6. Decisões pendentes (precisam de aval antes da Fase 2)

1. **Lote obrigatório em toda saída?**
   O rótulo já diz "Lote a baixar *", mas o backend aceita saída sem `loteId` (aplica FEFO automático) e só exige lote no `AJUSTE_INVENTARIO`.
   - **(a)** Obrigatório sempre — operador escolhe conscientemente; app mais restritivo que a API.
   - **(b)** Obrigatório só em `AJUSTE_INVENTARIO`; nas perdas, opcional com aviso "sem seleção, o sistema baixa pelo lote mais próximo do vencimento (FEFO)".
   > Sugestão: **(b)**, por espelhar o backend e aproveitar o FEFO que já existe.

2. **Formato de exibição da data:** `dd/mm/aaaa` na interface com conversão para ISO no payload (recomendado), ou ISO direto na tela?

3. **Escopo do português:** renomear só o que for tocado no refactor, ou incluir `EstoquePalette` e os demais arquivos do módulo (`estoque_page.dart` tem `_openCreate`, `_buildTabBar`…)?
   > Sugestão: só o que for tocado; o resto vira tarefa separada.

---

## 7. Resultado esperado

| Métrica | Antes | Depois |
|---|---|---|
| Linhas no arquivo da página | 693 | ~200 |
| Maior arquivo do módulo (form) | 693 | ~200 |
| Widgets reutilizáveis | 0 | 14 (2 em `core/`, 12 no módulo) |
| Testes da validação | 0 | ~15 |
| Campos obrigatórios efetivamente validados | 4 de 7 | **7 de 7** |
| Calendários fora do tema no app | 2 | 0 |
| Identificadores em inglês no form | ~90% | ~0% (exceto contratos da API) |

---

_Plano criado em 2026-08-31. Atualizar conforme as decisões da §6 forem tomadas._
