# Plano de Testes - EntregadorPage

## Visão Geral

Este documento descreve a estratégia de testes para a tela `EntregadorPage` do aplicativo Gulapay. A página é responsável por cadastrar ou editar entregadores, capturando nome, telefone e status de atividade.

## Objetivo

Garantir que o formulário de cadastro de entregadores funcione corretamente, incluindo validação de campos, exibição de estado de carregamento, registro de entregador e mensagens de feedback para o usuário.

## Pré-requisitos

- Aplicação compilada e rodando em modo de desenvolvimento.
- Dispositivo ou emulador Android/iOS disponível.
- Acessar a tela `EntregadorPage` diretamente ou via navegação do app.

## Estrutura da Página

Elementos principais:

- AppBar com título `Entregador`.
- Campo de texto `Nome` com ícone de pessoa e botão para limpar.
- Campo de texto `Telefone` com ícone de telefone e botão para limpar.
- Switch de status (`Ativo` / `Inativo`) com ícone visual.
- Cartão `Resumo` exibindo valores atuais do formulário.
- Botão principal `Salvar Entregador` que mostra um indicador de carregamento durante a operação.

## Critérios de Aceitação

- O formulário deve validar que o campo `Nome` não esteja vazio e tenha pelo menos 3 caracteres.
- O campo `Telefone` deve validar que não esteja vazio e contenha ao menos 10 dígitos.
- O botão `Salvar Entregador` deve ser desabilitado enquanto a operação estiver em andamento.
- Ao salvar com sucesso, deve aparecer um `SnackBar` verde com mensagem de confirmação.
- Ao falhar, deve aparecer um `SnackBar` vermelho com mensagem de erro.
- O `Resumo` deve refletir os valores atuais simultaneamente ao preenchimento.
- O switch de status deve alterar o texto e o ícone conforme `Ativo` ou `Inativo`.

## Casos de Teste

### 1. Carregamento inicial

- Passos:
  1. Abrir a tela `EntregadorPage`.
- Resultado esperado:
  - Todos os campos estão vazios.
  - O status é `Ativo` por padrão.
  - O cartão de resumo mostra `Nome: —`, `Telefone: —`, `Status: Ativo`.
  - O botão `Salvar Entregador` está habilitado.

### 2. Validação de campo `Nome` vazio

- Passos:
  1. Deixar o campo `Nome` vazio.
  2. Preencher o telefone com um número válido.
  3. Tocar em `Salvar Entregador`.
- Resultado esperado:
  - Exibe erro abaixo do campo `Nome`: `Informe o nome do entregador.`
  - Não exibe `SnackBar` de sucesso.
  - O formulário não envia.

### 3. Validação de `Nome` curto

- Passos:
  1. Inserir `Jo` no campo `Nome`.
  2. Preencher telefone válido.
  3. Tocar em `Salvar Entregador`.
- Resultado esperado:
  - Exibe erro: `O nome deve ter ao menos 3 caracteres.`
  - Não prossegue com o envio.

### 4. Validação de campo `Telefone` vazio

- Passos:
  1. Preencher nome válido.
  2. Deixar telefone vazio.
  3. Tocar em `Salvar Entregador`.
- Resultado esperado:
  - Exibe erro: `Informe o telefone do entregador.`
  - Não prossegue com o envio.

### 5. Validação de telefone inválido

- Passos:
  1. Preencher nome válido.
  2. Inserir telefone com menos de 10 dígitos.
  3. Tocar em `Salvar Entregador`.
- Resultado esperado:
  - Exibe erro: `Telefone inválido. Use DDD + número.`
  - Não prossegue com o envio.

### 6. Salvar entregador com sucesso

- Passos:
  1. Preencher `Nome` com valor válido.
  2. Preencher `Telefone` com valor válido.
  3. Confirmar o status `Ativo` ou `Inativo`.
  4. Tocar em `Salvar Entregador`.
- Resultado esperado:
  - O botão passa a mostrar `Salvando...` e o spinner.
  - O botão fica desabilitado enquanto dura a operação.
  - Após ~1 segundo, exibe `SnackBar` verde: `Entregador "<nome>" salvo com sucesso!`.
  - A página fecha ou retorna à tela anterior.

### 7. Teste de falha no salvamento

- Notas:
  - Atualmente o código não dispara exceção no fluxo normal porque usa apenas `Future.delayed`.
  - Para testes de falha, simular exceção no método `_salvarEntregador` ou alterar o comportamento de `Future.delayed`.
- Resultado esperado:
  - Exibe `SnackBar` vermelho com mensagem `Falha ao salvar entregador: <erro>`.
  - O botão retorna ao estado normal após a falha.

### 8. Atualização do resumo em tempo real

- Passos:
  1. Inserir nome e telefone aos poucos.
- Resultado esperado:
  - O cartão `Resumo` atualiza o texto conforme o usuário digita.
  - `Nome` exibe o valor digitado ou `—` quando vazio.
  - `Telefone` exibe o valor digitado ou `—` quando vazio.
  - `Status` muda para `Ativo` ou `Inativo` no resumo.

### 9. Testar limpeza de campo

- Passos:
  1. Inserir texto em `Nome`.
  2. Tocar no ícone de limpar (`x`).
  3. Repetir para `Telefone`.
- Resultado esperado:
  - O campo é limpo imediatamente.
  - O resumo exibe `—` para o campo limpo.

### 10. Verificação de estilo e acessibilidade

- Passos:
  1. Inspecionar AppBar e cores de fundo.
  2. Confirmar contraste do texto.
- Resultado esperado:
  - AppBar usa cor laranja/marrom consistente.
  - Texto e ícones são legíveis.
  - O botão principal tem dimensões adequadas.

## Dados de Teste Sugeridos

- Nome válido: `Carlos Silva`.
- Telefone válido: `11987654321`.
- Telefone inválido: `12345`, `987654`.
- Nome curto: `Al`.

## Observações para Automação

- O formulário usa `GlobalKey<FormState>` para validação.
- O fluxo de `SnackBar` e `Navigator.pop()` são pontos-chave para verificação de sucesso.
- O botão de enviar deve ser verificado como habilitado/desabilitado conforme `_isLoading`.
- O resumo é renderizado com valores diretos dos controladores.

## Recomendações

- Adicionar testes automatizados de widget para `EntregadorPage`.
- Implementar um serviço real para salvar os dados e permitir testes de integração com backend/API.
- Garantir que `TextFormField` use máscaras adequadas para telefone em versão futura.
