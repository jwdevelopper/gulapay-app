# 📄 Documentação: Home — Tela Principal com Navegação

**Arquivo:** `lib/modules/home/page/home.dart`
**Projeto:** `my_app_teste`
**Linguagem:** Dart (Flutter)
**Padrão:** StatefulWidget com Navegação por Drawer

---

## 📌 Visão Geral

`Home` é uma *StatefulWidget* que implementa a tela principal da aplicação com navegação por menu lateral (Drawer). Ele gerencia a troca entre três páginas distintas através de um sistema de índice:

- **Página 0 (Dashboard)** → `DashboardPage` — tela inicial com métricas/overview
- **Página 1 (Categoria)** → `CategoriaPage` — gerenciamento de categorias de produtos
- **Página 2 (Produto)** → `ProdutoPage` — gerenciamento de produtos (fullscreen)

A decisão de implementar com `IndexedStack` permite preservar o estado de cada página durante a navegação — formulários, scroll e inputs não são perdidos ao trocar de seção.

---

## 🏛️ Estrutura de Imports

```dart
import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';
```

**Decisão:** Imports absolutos com organização modular `modules/<nome>/page/<nome>_page.dart`.

| Aspecto | Justificativa |
|---------|---------------|
| **Padrão Modular** | Separa funcionalmente cada área da aplicação (categoria, dashboard, produto) |
| **Imports Absolutos** | Evita imports relativos confusos (`../../..`) e facilita refatoração |
| **Nomenclatura** | Arquivos `*_page.dart` indicam que exportam um widget de página completa |

---

## 🏗️ Declaração da Classe Principal

```dart
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}
```

**Decisões:**

| Aspecto | Justificativa |
|---------|---------------|
| `StatefulWidget` | Requer gerenciamento de estado mutável (`_selectedIndex`) que muda durante o ciclo de vida |
| `const Home({super.key})` | Construtor constante — permite otimização de rebuilds pelo Flutter |
| `super.key` | Repassa o `key` para a superclasse, permitindo identificação única e testes |
| `createState()` | Retorna `_HomeState` — segue padrão Flutter de separação estado e widget |

**Por que não StatelessWidget?**
O `Home` precisa manter `_selectedIndex` entre rebuilds. Um `StatelessWidget` não permite `setState()`, então precisaria receber o índice como parâmetro externo (elevated state) — complexidade desnecessária para este caso.

---

## 🏗️ Declaração da Classe de Estado

```dart
class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    DashboardPage(),
    CategoriaPage(),
    ProdutoPage(),
  ];
```

### `_selectedIndex`

```dart
int _selectedIndex = 0;
```

**Decisão:** Controla qual página está visível no momento.

| Aspecto | Justificativa |
|---------|---------------|
| `int` (primitivo) | Tipo simples e eficiente para comparação. Não há necessidade de `enum` aqui — três valores apenas |
| Underscore (`_`) | Convenção Dart para membros privados — encapsula o acesso, força uso de `setState()` |
| Valor inicial `0` | Dashboard é a página inicial padrão da aplicação |

**Índices:**
```
0 → DashboardPage (página inicial)
1 → CategoriaPage (gerenciamento de categorias)
2 → ProdutoPage   (gerenciamento de produtos)
```

### `_pages`

```dart
final List<Widget> _pages = const [
  DashboardPage(),
  CategoriaPage(),
  ProdutoPage(),
];
```

**Decisões:**

| Aspecto | Justificativa |
|---------|---------------|
| `final` | A lista não será substituída — apenas seus itens são usados como referência |
| `const` | Instâncias `DashboardPage()`, `CategoriaPage()`, `ProdutoPage()` são compile-time constants |
| `List<Widget>` | Tipagem genérica — permite qualquer widget que implemente a interface `Widget` |

**Por que não lateinit/nullable?**
A lista é criada junto com o estado e nunca muda. `final` + initializer direto é mais limpo e seguro que `late final` (evita uso antes de inicialização).

---

## 🏗️ Método build()

```dart
@override
Widget build(BuildContext context) {
  final showShell = _selectedIndex != 2;
```

### Variável `showShell`

```dart
final showShell = _selectedIndex != 2;
```

**Decisão:** Determina se AppBar e Drawer devem ser renderizados.

| Aspecto | Justificativa |
|---------|---------------|
| `final` | Valor calculado uma vez por build, não precisa ser estado |
| `_selectedIndex != 2` | **Página de Produto (índice 2) é fullscreen** — sem AppBar, sem Drawer |
| `bool` resultante | `true` para Dashboard e Categoria; `false` para Produto |

**Por que ocultar shell na página 2?**
Indica que a página de Produto pode funcionar como:
- Modal/fullscreen de cadastro/edição
- Tela que requer navegação própria (dentro de ProdutoPage)
- Contexto onde o drawer seria redundante ou interferiria

---

## 📦 Scaffold e AppBar

```dart
return Scaffold(
  appBar: showShell ? AppBar(title: const Text('Home')) : null,
```

**Decisões:**

| Aspecto | Justificativa |
|---------|---------------|
| `showShell ? AppBar(...) : null` | Renderização condicional — retorna `null` quando não deve exibir |
| `const Text('Home')` | Título fixo da aplicação |
| `AppBar(title: ...)` | Barra de título Material Design padrão |

**Nota sobre título fixo:**
O título sempre exibirá "Home" independentemente da página ativa (índice 0, 1 ou 2). Isso pode ser uma limitação — em apps reais, cada página costuma ter seu próprio título dinâmico. Sugestão de melhoria: extrair títulos para um `List<String>` e usar `_pages[_selectedIndex]` como índice.

---

## 📦 Drawer Menu Lateral

```dart
drawer: showShell
    ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Usuario'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categoria'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Produto'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ],
        ),
      )
    : null,
```

### Estrutura do Drawer

| Componente | Propriedade | Valor | Justificativa |
|------------|-------------|-------|---------------|
| `Drawer` | — | Widget nativo | Container Material Design para menu lateral |
| `ListView` | `padding` | `EdgeInsets.zero` | Remove espaçamento padrão do topo (DrawerHeader já fornece espaço visual) |
| `DrawerHeader` | `decoration` | `BoxDecoration(color: Colors.blue)` | Fundo azul (#2196F3) — cor primária Material Design |
| `DrawerHeader` | `child` | `Text('Menu', ...)` | Título do menu em branco, fonte 24 |
| `ListTile` | `leading` | Ícone Material | Representação visual de cada seção |
| `ListTile` | `title` | Texto descritivo | Label identificável para cada item |
| `ListTile` | `onTap` | Callback | Ação ao clicar — atualiza `_selectedIndex` e fecha drawer |

### Ícones por Seção

| Seção | Ícone | Semântica |
|-------|-------|-----------|
| Home | `Icons.home` | Página inicial — representação de casa |
| Usuario | `Icons.person` | Perfil do usuário — representação genérica |
| Categoria | `Icons.category` | Categorias — organização/classificação |
| Produto | `Icons.shopping_cart` | Produtos/carrinho — e-commerce |

### Callbacks dos Itens

```dart
// Dashboard
onTap: () {
  setState(() {
    _selectedIndex = 0;
  });
},

// Usuario (NÃO IMPLEMENTADO)
onTap: () {},

// Categoria
onTap: () {
  setState(() {
    _selectedIndex = 1;
  });
},

// Produto
onTap: () {
  setState(() {
    _selectedIndex = 2;
  });
},
```

**Decisão:** Usar `setState()` para atualizar o índice e disparar rebuild do widget.

| Aspecto | Justificativa |
|---------|---------------|
| `setState(() { ... })` | Indica ao Flutter que o estado mudou e uma reconstrução é necessária |
| Atualizar `_selectedIndex` | Muda o índice ativo, atualizando o `IndexedStack` |
| `onTap: () {}` vazio | **Placeholder** — funcionalidade do módulo "Usuario" não foi implementada |

**⚠️ Item "Usuario" não implementado:**
O callback está vazio `onTap: () {}`. Isso indica que:
1. O módulo de usuário existe mas não foi conectado ao drawer
2. A funcionalidade está planejada mas não priorizada
3. Necessita implementação futura

---

## 📦 Corpo da Página (IndexedStack)

```dart
body: IndexedStack(index: _selectedIndex, children: _pages),
```

### Por que IndexedStack?

```dart
IndexedStack(
  index: _selectedIndex,
  children: _pages,
)
```

**Decisão:** Mantém o estado de todas as páginas sem destruí-las.

| Abordagem | Comportamento | Estado Preservado? |
|-----------|---------------|-------------------|
| `IndexedStack` | Exibe uma página, mantém as outras invisíveis mas vivas | ✅ Sim |
| `Column/Stack` com `Visibility` | Alternativa nativa do Flutter | ✅ Sim |
| `PageView` | Destrói páginas fora da tela | ❌ Não |
| `Navigator` com múltiplas rotas | Cria/destrói rotas | ❌ Não |

**Vantagens do IndexedStack para este caso:**
- Formulários não perdem dados ao navegar
- Scroll position é mantido
- Widgets não são recriados — melhor performance
- Simplicidade — não requer gerenciamento de rotas

---

## 🗺️ Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                          Scaffold                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  AppBar (condicional - hidden when index == 2)      │   │
│   │  ┌─────────────────────────────────────────────┐    │   │
│   │  │  "Home"                          ☰ (hamburger) │   │
│   │  └─────────────────────────────────────────────┘    │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Drawer (condicional - hidden when index == 2)      │   │
│   │  ┌─────────────────────────────────────────────┐    │   │
│   │  │  Menu (DrawerHeader - azul)                 │    │   │
│   │  │  ─────────────────────────────────────────  │    │   │
│   │  │  🏠 Home ────────────────► index = 0        │    │   │
│   │  │  👤 Usuario ──────────────► (não impl.)     │    │   │
│   │  │  📂 Categoria ───────────► index = 1        │    │   │
│   │  │  🛒 Produto ──────────────► index = 2        │    │   │
│   │  └─────────────────────────────────────────────┘    │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  IndexedStack                                        │   │
│   │  ┌─────────────────────────────────────────────┐    │   │
│   │  │  [index=0] DashboardPage ──────────┐        │    │   │
│   │  │  [index=1] CategoriaPage           ├─ visível│   │
│   │  │  [index=2] ProdutoPage             │        │    │   │
│   │  └─────────────────────────────────────────────┘    │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Interação do Usuário

```
   Usuário abre o App
           │
           ▼
   Scaffold renderiza
   ├── AppBar: "Home" (visible)
   ├── Drawer: disponível (visible)
   └── IndexedStack: mostra index=0 (DashboardPage)
           │
           ▼
   Usuário toca o ☰ (hamburger)
           │
           ▼
   Drawer abre (menu lateral)
           │
           ├── Tap "Home"     → _selectedIndex = 0 → Dashboard
           ├── Tap "Usuario"  → (não faz nada - placeholder)
           ├── Tap "Categoria"→ _selectedIndex = 1 → Categoria
           └── Tap "Produto"  → _selectedIndex = 2 → Produto
                                          │
                                          ▼
                              AppBar e Drawer SOMEM
                              (showShell = false)
                              IndexedStack mostra ProdutoPage fullscreen
```

---

## 📊 Tabela de Decisões de Implementação

| Decisão | Opção Escolhida | Alternativas Consideradas | Motivo da Escolha |
|---------|-----------------|---------------------------|-------------------|
| Tipo de Widget | `StatefulWidget` | `StatelessWidget` + Provider | Requer estado mutável simples |
| Navegação | `IndexedStack` | `PageView`, `Navigator` | Preserva estado entre páginas |
| Menu | `Drawer` | `BottomNavigationBar`, `NavigationRail` | Padrão mobile comum, familiar |
| Shell condicional | `showShell = index != 2` | `showShell = true` sempre | ProdutoPage funciona fullscreen |
| Construtores | `const` | Não usar `const` | Otimização de rebuild |
| Acesso a estado | `_underscore` (privado) | Público | Encapsulamento |

---

## ⚠️ Análise Crítica e Sugestões de Melhoria

| Aspecto | Situação Atual | Problema | Sugestão |
|---------|---------------|----------|----------|
| **Título fixo "Home"** | Sempre "Home" | Não reflete página ativa | Usar `List<String>` de títulos e indexar |
| **Item "Usuario" vazio** | `onTap: () {}` | Funcionalidade não implementada | Implementar ou remover item |
| **Sem animação de transição** | Troca instantânea | Experiência visual básica | Adicionar `AnimatedSwitcher` ou `FadeTransition` |
| **Sem feedback visual** | Navegação direta | Usuário não sabe onde está | Adicionar `ListTile.selected` baseado em `_selectedIndex` |
| **Hardcoded índice** | `0, 1, 2` mágicos | Difícil manutenção | Usar `enum HomePage { dashboard, categoria, produto }` |
| **Sem navegação para produto** | Drawer fecha automaticamente | Usuário pode querer navegar de volta | Manter drawer visível ou adicionar FAB |
| **Escalabilidade** | Tudo em um arquivo | Widget muito longo | Extrair `Drawer` como widget separado |

---

## 💡 Versão Aprimorada Sugerida

```dart
import 'package:flutter/material.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_page.dart';
import 'package:my_app_teste/modules/dashboard/page/dashboard_page.dart';
import 'package:my_app_teste/modules/produto/page/produto_page.dart';

// Enum para índices legíveis e seguros
enum HomePage { dashboard, categoria, produto }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomePage _selectedIndex = HomePage.dashboard;

  // Títulos dinâmicos por página
  final List<String> _titles = ['Dashboard', 'Categorias', 'Produtos'];

  // Páginas como getter (evita criação antecipada)
  List<Widget> get _pages => const [
    DashboardPage(),
    CategoriaPage(),
    ProdutoPage(),
  ];

  bool get _showShell => _selectedIndex != HomePage.produto;

  // Getter de conveniência para título atual
  String get _currentTitle => _titles[_selectedIndex.index];

  void _navigateTo(HomePage page) {
    setState(() {
      _selectedIndex = page;
    });
    // Fecha o drawer após navegação
    if (_showShell) {
      Navigator.of(context).pop();
    }
  }

  // Item do drawer com estado de seleção
  ListTile _buildDrawerItem({
    required IconData icon,
    required String title,
    required HomePage page,
  }) {
    final isSelected = _selectedIndex == page;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () => _navigateTo(page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showShell
          ? AppBar(title: Text(_currentTitle))
          : null,
      drawer: _showShell ? _buildDrawer() : null,
      body: IndexedStack(
        index: _selectedIndex.index,
        children: _pages,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              _currentTitle,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(icon: Icons.home, title: 'Home', page: HomePage.dashboard),
          _buildDrawerItem(icon: Icons.person, title: 'Usuario', page: HomePage.dashboard), // placeholder
          _buildDrawerItem(icon: Icons.category, title: 'Categoria', page: HomePage.categoria),
          _buildDrawerItem(icon: Icons.shopping_cart, title: 'Produto', page: HomePage.produto),
        ],
      ),
    );
  }
}