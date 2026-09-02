# Levantamento de componentes reutilizáveis — aplicação inteira

> Complemento do [PLANO_MIGRACAO.md](./PLANO_MIGRACAO.md).
> Documento de análise. **Nenhum código foi alterado.**
> Varredura de `lib/` completa (26.185 linhas, 15 módulos).

---

## 0. Correção de convenção: `dto/` em vez de `models/`

Conforme definido, **classes de modelo vão em pastas `dto/`**. O `PLANO_MIGRACAO.md` propunha `models/` — fica revogado.

**Situação atual:** 12 módulos usam `dto/`, mas **3 também têm `models/`**:

| Pasta | Conteúdo | Ação |
|---|---|---|
| `insumo/models/` | `insumo_list_filter.dart`, `insumo_sort_options.dart` | mover para `insumo/dto/` |
| `produto/models/` | `produto_list_filter.dart`, `produto_sort_option.dart` | mover para `produto/dto/` |
| `lote/models/` | `lote_status_validade.dart` | mover para `lote/dto/` |
| `movimentacao_estoque/models/` | **vazia** | remover |

**Destinos revisados do plano de migração:**

| Antes (plano v1) | Agora |
|---|---|
| `movimentacao_estoque/models/tipos_movimentacao.dart` | `movimentacao_estoque/dto/tipo_movimentacao.dart` |
| `movimentacao_estoque/models/validacao_movimentacao.dart` | `movimentacao_estoque/dto/movimentacao_form_dto.dart` + `dto/validacao_movimentacao.dart` |

> Observação: hoje `dto/` guarda contratos da API e `models/` guardava estado de UI (filtros, ordenação). Unificando em `dto/`, os dois tipos convivem — vale um prefixo no nome (`*_filter`, `*_request`, `*_response`) para manter a leitura clara.

---

## 1. Sumário executivo

| Família duplicada | Cópias | Linhas desperdiçadas (est.) | Prioridade |
|---|---|---|---|
| **Paletas de cor** | 3 módulos + 2 globais | ~60 | 🔴 Crítica |
| **Campo de busca** | 4 implementações | ~220 | 🔴 Crítica |
| **Empty state** | 5 implementações | ~280 | 🔴 Crítica |
| **Botão de ícone do cabeçalho** | 3 cópias privadas | ~45 | 🟠 Alta |
| **Linha de resumo** (`_SummaryRow`) | 2 cópias idênticas | ~28 | 🟠 Alta |
| **Opção de escolha** (`_ChoiceOption`) | 2 cópias idênticas | ~14 | 🟠 Alta |
| **Folha de seleção** (bottom sheet) | 11 arquivos montam a casca à mão | ~350 | 🟠 Alta |
| **Diálogo de confirmação** | 11 arquivos | ~200 | 🟡 Média |
| **Folha de ordenação** | 2 implementações (APIs divergentes) | ~120 | 🟡 Média |
| **Indicador de carregamento** | 21 arquivos | ~80 | 🟡 Média |
| **Calendário** | 2 `showDatePicker` sem tema | ~30 | 🟡 Média |
| **Chips de filtro** | 3 implementações | ~150 | 🟢 Baixa |
| **Cartão de aviso/dica** | 4+ variações | ~120 | 🟢 Baixa |

**Total estimado de duplicação: ~1.700 linhas** (≈6,5% da base).

---

## 2. Achados críticos

### 2.1. 🔴 As três paletas de módulo são idênticas

`ProdutosPalette`, `EntregadoresPalette` e `EstoquePalette` têm **exatamente os mesmos valores hexadecimais** nas 11 chaves comuns:

```
background   #FCF6EC     text        #3D261A
surface      #FFF9F1     textMuted   #A06E4E
surfaceAlt   #FFFDF9     border      #E8D8C2
primary      #F07330     borderSoft  #F0E3D0
primaryPressed #E85F1E   inputFill   #FFF4E8
primarySoft  #F8C39C
```

Diferenças: `Produtos` e `Estoque` têm `warningBg`/`warningBorder`/`error`; `Entregadores` e `Estoque` têm `success` — **com valores diferentes entre si** (`#2E8B57` vs `#4CAF50`), o único ponto de real divergência, e provavelmente não intencional.

**Proposta:** `lib/core/theme/paleta_app.dart` com a união das chaves. Os três arquivos viram `typedef`/re-export temporário para migração incremental, e são removidos ao final.

> **Agravante:** existe ainda uma **quarta** paleta (`AppTema`, laranja-areia: `#EC8550`, `#FFF8EC`) e uma **quinta** (`GulaColors`, `#D96A3A`, `#FBF8F1`). Três famílias de laranja convivendo. Unificar as cinco é tarefa maior — ver §5.

### 2.2. 🔴 Quatro campos de busca com a mesma API

| Arquivo | Linhas | Tema usado |
|---|---|---|
| `core/widgets/app_campo_busca.dart` | 40 | `AppTema` |
| `produto/widgets/produto_search_field.dart` | 67 | `ProdutosPalette` |
| `insumo/components/insumo_search_field.dart` | 79 | **`Theme.of(context)`** ⚠️ |
| `entregador/widgets/entregador_search_field.dart` | 71 | `EntregadoresPalette` |

Os três de módulo têm **assinatura pública idêntica**:

```dart
final TextEditingController controller;
final String search;
final ValueChanged<String> onChanged;
final VoidCallback onClear;
```

A única diferença real é o `hintText` ("Buscar produto…" / "Buscar insumo…" / "Buscar entregador…").

⚠️ **`InsumoSearchField` usa `Theme.of(context)`**, que resolve para o `ColorScheme.fromSeed(seedColor: Colors.blueAccent)` do `main.dart` — ou seja, **renderiza com cores azuis** enquanto os irmãos são laranja.

**Proposta:** `core/widgets/app_campo_busca.dart` recebe `dica` como parâmetro e absorve os três. Estimativa: **–180 linhas**.

### 2.3. 🔴 Cinco empty states, dois com a mesma classe

| Arquivo | Classe | Tema |
|---|---|---|
| `core/widgets/app_estado_vazio.dart` | `AppEstadoVazio` | `AppTema` |
| `produto/widgets/empty_state_card.dart` | **`EmptyStateCard`** | `ProdutosPalette` |
| `insumo/components/empty_state_card.dart` | **`EmptyStateCard`** | **`Theme.of(context)`** ⚠️ |
| `entregador/widgets/entregador_empty_state.dart` | `EntregadorEmptyState` | `EntregadoresPalette` |
| `movimentacao_estoque/widgets/estoque_empty_state.dart` | `EstoqueEmptyState` | `EstoquePalette` |

Produto e Insumo declaram **a mesma classe `EmptyStateCard` com os mesmos 6 parâmetros** (`title`, `subtitle`, `icon`, `buttonLabel`, `onPressed`, `secondary`) — implementações independentes que só divergem no tema. De novo, a de insumo puxa o tema azul.

**Proposta:** `core/widgets/app_estado_vazio.dart` evolui para cobrir os dois formatos (simples: ícone+texto; cartão: +título+botão), via parâmetros opcionais. Estimativa: **–230 linhas**.

---

## 3. Widgets privados duplicados entre arquivos

Classes `_Privadas` copiadas de um arquivo para outro — o sinal mais claro de componente faltando:

| Classe | Ocorrências | Proposta |
|---|---|---|
| `_ChoiceOption` | `movimentacao_form_page.dart:8`<br>`produto_form_page.dart:16` | `core/dto/opcao_escolha.dart` → `OpcaoEscolha` |
| `_HeaderIconButton` / `_FormHeaderIconButton` | `estoque_page.dart:917`<br>`produto_form_page.dart:1320`<br>`movimentacao_form_page.dart:664` | `core/widgets/app_botao_icone.dart` → `AppBotaoIcone` |
| `_SummaryRow` | `movimentacao_form_page.dart:679`<br>`produto_form_page.dart:1349` | `core/widgets/app_linha_resumo.dart` → `AppLinhaResumo` |

As três são estruturalmente idênticas entre as cópias — copy-paste puro.

---

## 4. Componentes propostos

### 4.1. Núcleo (`core/widgets/`) — servem toda a aplicação

| # | Componente | Substitui | Impacto |
|---|---|---|---|
| C1 | `PaletaApp` (`core/theme/paleta_app.dart`) | 3 paletas de módulo | 3 módulos |
| C2 | `AppCampoBusca` (evoluir) | 4 campos de busca | 4 módulos |
| C3 | `AppEstadoVazio` (evoluir) | 5 empty states | 5 módulos |
| C4 | `AppBotaoIcone` | 3 cópias privadas | 3 arquivos |
| C5 | `AppLinhaResumo` | 2 cópias privadas | 2 arquivos |
| C6 | `AppFolhaSelecao` — casca da bottom sheet (alça, título, fechar, lista) | 11 arquivos que montam à mão | 8 módulos |
| C7 | `AppItemSelecionavel` — cartão com estado de selecionado | ~6 repetições | 5 módulos |
| C8 | `AppDialogoConfirmacao` | 11 arquivos com `AlertDialog` | 9 módulos |
| C9 | `AppCarregando` — indicador padronizado | 21 arquivos | 15 módulos |
| C10 | **`AppSeletorData`** — calendário temático | 2 `showDatePicker` sem tema | 3 telas |
| C11 | **`AppCampoData`** — input de data | campo de texto livre | 3 telas |
| C12 | `AppRotuloCampo` — rótulo com `*` obrigatório | 6+ literais `'Campo *'` | todos os forms |
| C13 | `AppCartaoAviso` — base de banner de erro / cartão de dica | 4+ variações | 4 módulos |
| C14 | `AppFolhaOrdenacao` — folha de ordenação genérica | 2 implementações divergentes | 2 módulos |
| C15 | `AppCampoTextoTematico` — campo com estado de erro | `_buildTextField` ×2 | 2 módulos |

### 4.2. Locais ao módulo de estoque (do plano original)

Permanecem como estavam no `PLANO_MIGRACAO.md` §2, com destinos ajustados para `dto/`:

`seletor_insumo.dart`, `seletor_unidade.dart`, `seletor_lote.dart`, `cabecalho_wizard.dart`, `rodape_wizard.dart`, `resumo_movimentacao.dart`, `tela_sucesso.dart`, `etapa_tipo.dart`, `etapa_insumo_quantidade.dart`, `etapa_lote_detalhes.dart`.

### 4.3. Estrutura alvo do núcleo

```
lib/core/
├── theme/
│   ├── paleta_app.dart          [NOVO]  C1 — fonte única de cor
│   ├── app_tema.dart            [mantém, passa a delegar para PaletaApp]
│   └── gula_theme.dart          [mantém — ver §5]
├── dto/
│   └── opcao_escolha.dart       [NOVO]  OpcaoEscolha (ex-_ChoiceOption)
└── widgets/
    ├── app_campo_busca.dart     [EVOLUI]     C2
    ├── app_estado_vazio.dart    [EVOLUI]     C3
    ├── app_botao_icone.dart     [NOVO]       C4
    ├── app_linha_resumo.dart    [NOVO]       C5
    ├── app_folha_selecao.dart   [NOVO]       C6 + C7
    ├── app_dialogo_confirmacao.dart [NOVO]   C8
    ├── app_carregando.dart      [NOVO]       C9
    ├── app_seletor_data.dart    [NOVO]       C10
    ├── app_campo_data.dart      [NOVO]       C11
    ├── app_rotulo_campo.dart    [NOVO]       C12
    ├── app_cartao_aviso.dart    [NOVO]       C13
    ├── app_folha_ordenacao.dart [NOVO]       C14
    └── app_campo_texto_tematico.dart [NOVO]  C15
```

---

## 5. Fora de escopo (registrado, não proposto agora)

| Item | Motivo |
|---|---|
| Unificar `AppTema` × `GulaColors` × `PaletaApp` (3 laranjas diferentes) | Mexe em 15 módulos; merece tarefa própria |
| Ligar `GulaTheme.light()` no `MaterialApp` (hoje o app roda com seed **azul**) | Alto impacto visual global; precisa de validação tela a tela |
| Consolidar os cards de listagem (`produto_card`, `insumo_card`, `lote_card`, `entregador_card`, `movimentacao_card`) | Estruturas parecidas mas conteúdo bem distinto; ganho menor que o risco |
| Quebrar `produto_form_page.dart` (1.383 linhas) e `comanda_detalhe_page.dart` (1.303) | Mesmo tratamento deste plano, em tarefas separadas |

---

## 6. Ordem de execução sugerida

Do menor risco/maior alcance para o maior risco:

| Onda | Componentes | Por quê primeiro |
|---|---|---|
| **1** | C1 (paleta) | Base de tudo; substituição mecânica, valores idênticos → risco visual zero |
| **2** | C4, C5, C12 (botão, linha de resumo, rótulo) | Widgets pequenos e isolados; sem estado |
| **3** | C10, C11 (calendário e campo de data) | Independentes; corrigem o calendário azul em 3 telas |
| **4** | C2, C3 (busca, empty state) | Alcançam 5 módulos; corrigem o tema azul em insumo |
| **5** | C6, C7, C13, C15 (folha, item, aviso, campo) | Habilitam o refactor do `movimentacao_form_page` |
| **6** | Refactor do `movimentacao_form_page` | Consome tudo acima — ver `PLANO_MIGRACAO.md` fases 2–7 |
| **7** | C8, C9, C14 (diálogo, carregando, ordenação) | Varredura ampla; melhor com o resto estabilizado |
| **8** | Mover `models/` → `dto/` nos 3 módulos | Renomeação mecânica; fazer por último evita conflito com as ondas acima |

> Cada onda deve terminar com `flutter analyze` limpo e `flutter test` verde.

---

## 7. Ganho esperado

| Métrica | Hoje | Depois |
|---|---|---|
| Paletas de cor no app | 5 | 2 (`PaletaApp` + `GulaColors`) |
| Implementações de campo de busca | 4 | 1 |
| Implementações de empty state | 5 | 1 |
| Classes privadas duplicadas entre arquivos | 3 (7 cópias) | 0 |
| Widgets que puxam o tema azul por engano | 2 confirmados | 0 |
| Calendários fora do tema | 2 | 0 |
| Pastas `models/` fora da convenção | 3 (+1 vazia) | 0 |
| Linhas duplicadas | ~1.700 | ~0 |

---

## 8. Decisões pendentes

Somam-se às três já listadas no `PLANO_MIGRACAO.md` §6:

4. **`success` divergente entre paletas:** `EntregadoresPalette` usa `#2E8B57`, `EstoquePalette` usa `#4CAF50`. Qual vira o padrão em `PaletaApp`?
5. **Escopo da onda 1:** substituir as 3 paletas de uma vez, ou manter re-exports temporários e migrar módulo a módulo?
6. **`dto/` unificado:** filtros e opções de ordenação (estado de UI) convivendo com requests/responses da API na mesma pasta — confirma, ou prefere subpastas (`dto/api/`, `dto/ui/`)?

---

_Levantamento criado em 2026-08-31. Base: `lib/` com 26.185 linhas em 15 módulos._
