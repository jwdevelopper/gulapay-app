# Módulo de Clientes — Resumo de Alterações

## Arquivos Modificados

- `lib/modules/cliente/page/cliente_page.dart`
- `lib/modules/cliente/page/cliente_form_page.dart`
- `lib/modules/cliente/page/cliente_detalhe_page.dart`
- `lib/modules/cliente/service/cliente_service.dart`
- `lib/modules/cliente/dto/cliente_endereco.dart`
- `lib/modules/home/page/home_page.dart`

---

## 1. Correções de Qualidade (Code Review Copilot)

### Null Safety
- `c.nome!` → `c.nome ?? ''` no filtro de busca (`cliente_page.dart`)
- `cliente.nome!` → `cliente.nome ?? 'Sem nome'` no `ListTile` e no card de perfil
- `widget.cliente!.nome!` → `widget.cliente!.nome ?? ''` no `initState` do formulário

### Gerenciamento de Recursos
- Adicionado `dispose()` em `_ClientePageState` para descartar `_buscaController`
- Removido `_buscaController` desnecessário do `ClienteFormPage` (não era usado no formulário)

### Segurança Assíncrona (`mounted` checks)
- `if (!mounted) return;` adicionado no caminho de sucesso e de erro de `_carregarClientes()`
- `if (!mounted) return;` adicionado no bloco `catch` de `_salvar()` antes de usar `context`
- `ctx.mounted` / `context.mounted` adicionados após `await inativarCliente(...)` no dialog de confirmação

### Logs com Dados Pessoais (PII)
- Removidos dois `debugPrint` que logavam JSON com endereço e dados do cliente

### Tratamento de Erros
- `await inativarCliente(...)` envolvido em `try/catch` com snackbar de feedback ao usuário

### Comentários e Organização
- Comentário errado `// Buscar cliente por ID` removido do `cliente_service.dart`
- Comentário desatualizado de importação removido do `cliente_detalhe_page.dart`
- Botão `open_in_new` com `onPressed` vazio removido do card de contato

### UI
- `Text('cliente')` → `Text('Clientes')` no menu lateral (`home_page.dart`)
- Indentação corrigida em `cliente_endereco.dart` (espaço extra antes de `class`)

### Scaffold Aninhado
- `ClientePage` retornava `Scaffold` com `AppBar` próprio dentro do `IndexedStack` do `Home`,
  que já possui seu próprio `Scaffold/AppBar`. Corrigido para retornar `Scaffold` sem `AppBar`,
  seguindo o mesmo padrão de `UsuarioListaPagina`.

---

## 2. Padronização de Layout (padrão do módulo Usuário)

### `cliente_page.dart`
- Substituído o cabeçalho laranja customizado por `AppCampoBusca` (widget compartilhado)
- Substituído o card customizado por `Dismissible` com swipe para inativar (igual ao de usuário)
- Substituído o estado vazio customizado por `AppEstadoVazio`
- Adicionado `AppTag` para exibir badge "Inativo" no card
- Adicionado `RefreshIndicator` para recarregar a lista com pull-to-refresh
- Cores hardcoded substituídas por `AppTema`
- Avatar com inicial do nome (igual ao módulo de usuário)

### `cliente_form_page.dart`
- Campos `TextField` customizados substituídos por `AppCampoTexto`
- Rótulos substituídos por `AppRotulo` (com suporte a `opcional:`)
- Botões substituídos por `AppBarraAcoes` (Cancelar + Salvar fixos no rodapé)
- `AppBar` padronizado com subtítulo (igual ao de usuário)
- `AppDica` adicionada com instruções de preenchimento
- Seção de endereço separada visualmente com divider e ícone `locationDot`
- Cores hardcoded substituídas por `AppTema`

### `cliente_detalhe_page.dart`
- `AppBar` padronizado com subtítulo "Ativo / Inativo"
- Ícone de edição substituído por `FaIcon(penToSquare)` com cor `AppTema.primariaEscura`
- Card de perfil reescrito com avatar de inicial, nome, e-mail e badge de status
- Card de contato reescrito com método `_buildLinha` reutilizável (WhatsApp + e-mail)
- Card de endereço adicionado — exibido apenas quando o endereço está preenchido,
  formatando logradouro, número, complemento, bairro, cidade, UF e CEP
- Dialog de confirmação de inativação padronizado (ícone de alerta + cores `AppTema`)
- Snackbar de sucesso adicionado após inativação
- Cores hardcoded substituídas por `AppTema`

---

## 3. Melhorias de Usabilidade

### Filtro de status (`cliente_page.dart`)
- Adicionados chips de filtro **TODOS / ATIVOS / INATIVOS** abaixo da barra de busca
- Filtro combinado com busca por texto (nome e telefone) ao mesmo tempo
- Swipe de inativar desabilitado para clientes já inativos (`DismissDirection.none`)
- Mensagem de estado vazio considera o filtro ativo

### Menu de ações (⋮) nos cartões (`cliente_page.dart`)
- Substituído o ícone `>` por um menu de três pontos (`ellipsisVertical`) no canto dos cards
- Menu exibe **Editar** e **Inativar** para clientes ativos
- Menu exibe **Editar** e **Ativar** para clientes inativos
- Toque no card continua abrindo a tela de detalhes; swipe também permanece disponível

### Ativar cliente inativado
- Adicionada função `reativarCliente(id, dados)` em `cliente_service.dart`
  — reutiliza o endpoint PUT com `ativo: true` e os dados existentes do cliente
- `_confirmarReativacao` e `_reativar` adicionados em `cliente_page.dart`
  com dialog de confirmação verde e snackbar de feedback
- `_confirmarReativacao` adicionado em `cliente_detalhe_page.dart`
  com botão **"Ativar cliente"** (verde) exibido quando o cliente está inativo,
  alternando com o botão **"Inativar cliente"** (vermelho) quando ativo

### Refresh automático da lista
- Após **inativar**: `_inativar()` chama `_carregar()` ao invés de remover localmente
- Após **reativar**: `_reativar()` chama `_carregar()` para refletir o novo status
- Após **editar ou criar**: `_abrirFormulario()` chama `_carregar()` quando o formulário retorna `true`
- Ao **voltar dos detalhes**: `onTap` do card chama `_carregar()` quando a tela retorna `true`
