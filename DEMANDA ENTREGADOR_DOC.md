# Documentação — Módulo Entregador (histórico)

> **Atenção:** este documento descreve a implementação anterior, baseada em formulário único e salvamento simulado. A referência atual está em [`docs/refatoracao_entregadores.md`](docs/refatoracao_entregadores.md).

> Projeto: Sistema de Comandas e Gestão para Food Service
> Disciplina: Análise e Projeto de Sistemas — Unipar
> Responsável: José Wilson (jwdevelopper@gmail.com)
> Última atualização: 2026-05-27

---

## 1. Visão Geral

O módulo **Entregador** é responsável pelo cadastro e gerenciamento dos entregadores internos do estabelecimento. Conforme decisão de projeto (sessão 6 — `CLAUDE.md`), entregadores **não possuem login no sistema**; atuam como recurso cadastral vinculado a comandas do tipo `DELIVERY`, recebendo a comanda impressa (JasperReports) para realizar a entrega.

Esta documentação cobre a camada **frontend Flutter** do módulo, incluindo a tela de cadastro, o DTO de resposta e os casos de teste homologados.

---

## 2. Regras de Negócio

| Regra | Descrição |
|-------|-----------|
| RN01 | Entregador não possui credencial de acesso ao sistema. |
| RN02 | Nome é obrigatório e deve ter no mínimo 3 caracteres. |
| RN03 | Telefone é obrigatório e deve conter DDD + número (mínimo 10 dígitos). |
| RN04 | Status padrão na criação é `Ativo`. |
| RN05 | Entregador inativo não deve ser vinculado a novas comandas de delivery. |

---

## 3. Estrutura de Arquivos

```
lib/
└── modules/
    └── entregador/
        ├── page/
        │   └── entregador_page.dart       # Tela de cadastro
        └── dto/
            └── entregador_response_dto.dart  # DTO de resposta da API
```

A rota de acesso à tela está registrada no `Home` (menu lateral/drawer), conforme trecho:

```dart
ListTile(
  leading: Icon(Icons.delivery_dining),
  title: Text('Entregador'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EntregadorPage()),
    );
  },
),
```

---

## 4. DTO de Resposta — `entregador_responseDTO`

Representa o objeto retornado pela API REST (Spring Boot) após operações de criação ou consulta de entregador.

```dart
class entregador_responseDTO {
  int? id;
  String? nome;
  String? telefone;
  bool? ativo;
}
```

### Campos

| Campo | Tipo | Nullable | Descrição |
|-------|------|----------|-----------|
| `id` | `int` | Sim | Identificador gerado pelo banco. Nulo antes da persistência. |
| `nome` | `String` | Sim | Nome completo do entregador. |
| `telefone` | `String` | Sim | Telefone com DDD (somente dígitos, conforme normalização da API). |
| `ativo` | `bool` | Sim | Indica se o entregador está ativo no sistema. |

### Métodos

`fromJson(Map<String, dynamic> json)` — desserializa o JSON recebido da API para o objeto Dart.

`toJson()` — serializa o objeto para `Map`, utilizado no envio de dados à API.

### Exemplo de payload JSON

```json
{
  "id": 12,
  "nome": "Carlos Silva",
  "telefone": "11987654321",
  "ativo": true
}
```

> **Nota técnica:** O nome da classe segue o padrão `snake_case` herdado do projeto. Recomenda-se padronizar para `EntregadorResponseDTO` (UpperCamelCase) em refatorações futuras, alinhando ao padrão Dart/Flutter.

---

## 5. Tela de Cadastro — `EntregadorPage`

### 5.1. Descrição

`StatefulWidget` responsável pelo formulário de criação de entregador. Gerencia validação de campos, controle de estado de carregamento (`_isLoading`) e exibição de feedback ao usuário via `SnackBar`.

### 5.2. Estado interno

| Variável | Tipo | Valor inicial | Descrição |
|----------|------|---------------|-----------|
| `_formKey` | `GlobalKey<FormState>` | — | Chave global do formulário para disparo de validação. |
| `_nomeController` | `TextEditingController` | vazio | Controlador do campo Nome. |
| `_telefoneController` | `TextEditingController` | vazio | Controlador do campo Telefone. |
| `_ativo` | `bool` | `true` | Estado do switch Ativo/Inativo. |
| `_isLoading` | `bool` | `false` | Bloqueia o botão durante o envio para evitar submissões duplicadas. |

### 5.3. Componentes visuais

| Componente | Descrição |
|-----------|-----------|
| `AppBar` | Título "Entregador", fundo laranja/marrom (`#CD6928`), título centralizado e branco. |
| Campo `Nome` | `TextFormField` com ícone `Icons.person`, botão de limpeza rápida (`FontAwesomeIcons.xmark`) e validação. |
| Campo `Telefone` | `TextFormField` com `keyboardType: phone`, ícone `Icons.phone`, botão de limpeza e validação. |
| `SwitchListTile` | Alterna entre Ativo/Inativo com ícone dinâmico (✅ verde / ❌ vermelho). |
| Card `Resumo` | Exibe em tempo real os dados preenchidos; atualiza conforme o usuário digita. |
| Botão `Salvar Entregador` | `ElevatedButton.icon` — exibe spinner e texto "Salvando..." durante o carregamento; desabilitado enquanto `_isLoading = true`. |

### 5.4. Fluxo de salvamento (`_salvarEntregador`)

```
Usuário toca em "Salvar Entregador"
        │
        ▼
_formKey.currentState!.validate()
        │
   inválido ──► SnackBar vermelho + retorno
        │
   válido
        │
        ▼
setState(_isLoading = true)  ← bloqueia botão
        │
        ▼
await chamada à API (atualmente: Future.delayed simulado)
        │
   sucesso ──► SnackBar verde + Navigator.pop(context)
        │
   erro    ──► SnackBar vermelho com mensagem da exceção
        │
        ▼
finally: setState(_isLoading = false)
```

### 5.5. Validações dos campos

**Campo Nome**

| Condição | Mensagem exibida |
|----------|-----------------|
| Vazio ou nulo | `Informe o nome do entregador.` |
| Menos de 3 caracteres | `O nome deve ter ao menos 3 caracteres.` |

**Campo Telefone**

| Condição | Mensagem exibida |
|----------|-----------------|
| Vazio ou nulo | `Informe o telefone do entregador.` |
| Menos de 10 dígitos | `Telefone inválido. Use DDD + número.` |

### 5.6. Gerenciamento de recursos

Os controllers são descartados no `dispose()` para evitar vazamento de memória:

```dart
@override
void dispose() {
  _nomeController.dispose();
  _telefoneController.dispose();
  super.dispose();
}
```

A verificação `if (!mounted) return` protege chamadas de `setState` e `ScaffoldMessenger` após o widget ser desmontado (ex.: usuário navegou para outra tela durante o carregamento).

---

## 6. Identidade Visual

| Elemento | Valor |
|----------|-------|
| Cor primária (AppBar/botão) | `Color(0xFFCD6928)` — laranja/marrom |
| Cor de acento (ícones x) | `Color(0xFFF89728)` — laranja claro |
| Fundo da tela | `Color(0xFFF2ECE2)` — bege claro |
| Borda dos campos | `BorderRadius.circular(30.0)` — arredondada |
| Altura do botão principal | `56.0` dp (acessibilidade de toque) |

---

## 7. Casos de Teste Homologados

Todos os 9 cenários foram executados e aprovados. Dados utilizados: nome válido `Carlos Silva`, telefone válido `11987654321`, telefone inválido `12345` / `987654`, nome curto `Al`.

| # | Cenário | Resultado |
|---|---------|-----------|
| 1 | Carregamento inicial — campos vazios, status Ativo, resumo com `—` | ✅ PASSOU |
| 2 | Campo Nome vazio → erro `Informe o nome do entregador.` | ✅ PASSOU |
| 3 | Nome com menos de 3 chars → erro `O nome deve ter ao menos 3 caracteres.` | ✅ PASSOU |
| 4 | Campo Telefone vazio → erro `Informe o telefone do entregador.` | ✅ PASSOU |
| 5 | Telefone com menos de 10 dígitos → erro `Telefone inválido. Use DDD + número.` | ✅ PASSOU |
| 6 | Dados válidos → spinner, SnackBar verde, retorno à tela anterior | ✅ PASSOU |
| 7 | Falha simulada no salvamento → SnackBar vermelho, botão reabilitado | ✅ PASSOU |
| 8 | Atualização do card Resumo em tempo real conforme digitação | ✅ PASSOU |
| 9 | Botão de limpeza (x) limpa campo e atualiza resumo para `—` | ✅ PASSOU |

---

## 8. Pendências e Recomendações

| # | Item | Prioridade |
|---|------|-----------|
| P01 | Substituir `Future.delayed` pela integração real com a API REST (endpoint `POST /entregadores`). | Alta |
| P02 | Aplicar máscara de telefone no formato `(XX) XXXXX-XXXX` via `FilteringTextInputFormatter` ou pacote `easy_mask`. | Média |
| P03 | Padronizar nome do DTO de `entregador_responseDTO` para `EntregadorResponseDTO` (convenção Dart). | Baixa |
| P04 | Implementar tela de listagem de entregadores com opção de edição e inativação. | Alta |
| P05 | Adicionar `entregador_createDTO` para separar o payload de criação do payload de resposta. | Alta |

---

## 9. Dependências Flutter

| Pacote | Uso no módulo |
|--------|--------------|
| `flutter/material.dart` | Widgets base (Scaffold, Form, Switch, Card, etc.) |
| `font_awesome_flutter` | Ícones `truckFast`, `xmark`, `paperPlane`, `infoCircle`, `circleCheck`, `circleXmark` |

---

_Documentação gerada com base nos artefatos: `entregador_page.dart`, `entregador_responseDTO`, relatório de testes e `CLAUDE.md` do projeto._
