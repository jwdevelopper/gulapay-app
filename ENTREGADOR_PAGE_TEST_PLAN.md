# Plano e Relatório de Testes - EntregadorPage (Grupo 2)

## Visão Geral

Este documento descreve a estratégia de testes e apresenta os **resultados reais da execução dos testes** para a tela `EntregadorPage` do aplicativo Gulapay. A página é responsável por cadastrar ou editar entregadores, capturando nome, telefone e status de atividade.

## Objetivo

Garantir que o formulário de cadastro de entregadores funcione corretamente, incluindo validação de campos, exibição de estado de carregamento, registro de entregador e mensagens de feedback para o usuário.

## Pré-requisitos

- Aplicação compilada e rodando em modo de desenvolvimento.
- Dispositivo ou emulador Android/iOS disponível.
- Acessar a tela `EntregadorPage` diretamente ou via navegação do app.

---

##  RELATÓRIO 1: Verificação de Estilo, Interface e Componentes Visuais

Este relatório consolida os testes estáticos e dinâmicos aplicados diretamente na interface do usuário (UI) para garantir a conformidade com o design do sistema Gulapay e critérios de acessibilidade.

### Estrutura da Página e Elementos Principais

- **AppBar com título `Entregador`**: 
  -  *Resultado:* **APROVADO**. Renderizado corretamente no topo da página. O estilo visual e a paleta de cores (laranja/marrom) seguem o guia de identidade do aplicativo, garantindo excelente contraste para leitura.
- **Campo de texto `Nome`**: 
  -  *Resultado:* **APROVADO**. Exibe o ícone de pessoa (`Icons.person`) à esquerda. O botão de limpeza rápida (`x`) aparece dinamicamente assim que o usuário começa a digitar.
- **Campo de texto `Telefone`**: 
  -  *Resultado:* **APROVADO**. Exibe o ícone de telefone (`Icons.phone`) à esquerda e também conta com o botão funcional de limpeza rápida.
- **Switch de status (`Ativo` / `Inativo`)**: 
  -  *Resultado:* **APROVADO**. Componente interativo posicionado corretamente. Altera o texto de exibição lateral e o ícone visual correspondente em tempo real conforme é alternado pelo usuário.
- **Cartão `Resumo`**: 
  -  *Resultado:* **APROVADO**. Seção visualizada na parte inferior do formulário, estilizada em formato de card, espelhando os dados simultaneamente ao preenchimento.
- **Botão principal `Salvar Entregador`**: 
  -  *Resultado:* **APROVADO**. Botão com dimensões adequadas para toque (acessibilidade), centralizado e com feedback visual de clique.

---

##  RELATÓRIO 2: Execução dos Casos de Teste (Validações e Fluxo)

Este relatório detalha a execução dos cenários de comportamento, validações do `GlobalKey<FormState>` e controle de estado concorrente (`_isLoading`).

### 1. Carregamento inicial
- **Passos:** Abrir a tela `EntregadorPage`.
- **Resultado esperado:** Todos os campos vazios; status `Ativo` por padrão; resumo mostrando `Nome: —`, `Telefone: —`, `Status: Ativo`; botão `Salvar Entregador` habilitado.
- ** RESULTADO REAL:** **PASSOU**. O estado inicial da página é instanciado corretamente. Os controladores dos campos de texto iniciam limpos e o resumo reflete o estado padrão perfeitamente.

### 2. Validação de campo `Nome` vazio
- **Passos:** Deixar o campo `Nome` vazio, preencher o telefone com um número válido e tocar em `Salvar Entregador`.
- **Resultado esperado:** Exibe erro abaixo do campo `Nome`: `Informe o nome do entregador.`; o formulário não envia.
- ** RESULTADO REAL:** **PASSOU**. O validador do `TextFormField` interceptou o clique. A mensagem de erro em vermelho apareceu abaixo do campo e o fluxo de salvamento foi bloqueado.

### 3. Validação de `Nome` curto
- **Passos:** Inserir `Jo` no campo `Nome`, preencher telefone válido e tentar salvar.
- **Resultado esperado:** Exibe erro: `O nome deve ter ao menos 3 caracteres.`; não prossegue com o envio.
- ** RESULTADO REAL:** **PASSOU**. A regra de tamanho mínimo da string funcionou adequadamente, impedindo o avanço com nomes incompletos ou abreviações inválidas.

### 4. Validação de campo `Telefone` vazio
- **Passos:** Preencher nome válido, deixar telefone vazio e tocar em `Salvar Entregador`.
- **Resultado esperado:** Exibe erro: `Informe o telefone do entregador.`; não prossegue.
- ** RESULTADO REAL:** **PASSOU**. Sistema de validação barrou o envio com sucesso, exigindo o preenchimento do campo obrigatório de contato.

### 5. Validação de telefone inválido
- **Passos:** Preencher nome válido, inserir telefone com menos de 10 dígitos (ex: `12345`) e tentar salvar.
- **Resultado esperado:** Exibe erro: `Telefone inválido. Use DDD + número.`; não envia.
- ** RESULTADO REAL:** **PASSOU**. O sistema identificou a falta de dígitos necessários para cobrir o DDD + número, disparando o alerta de formato inválido.

### 6. Salvar entregador com sucesso
- **Passos:** Preencher `Nome` e `Telefone` válidos, confirmar o status e tocar em `Salvar Entregador`.
- **Resultado esperado:** O botão passa a mostrar `Salvando...` e o spinner/indicador de carregamento; fica desabilitado; após ~1s exibe `SnackBar` verde de confirmação; a página fecha ou retorna.
- ** RESULTADO REAL:** **PASSOU**. O estado `_isLoading` foi alternado para verdadeiro com sucesso, travando o botão contra múltiplos cliques acidentais. O `Future.delayed` simulou a requisição perfeitamente, disparando o `SnackBar` verde de sucesso na tela e executando o `Navigator.pop(context)` para retornar à listagem.

### 7. Teste de falha no salvamento
- **Notas:** Simulação de exceção no método `_salvarEntregador`.
- **Resultado esperado:** Exibe `SnackBar` vermelho com mensagem `Falha ao salvar entregador: <erro>`; botão retorna ao estado normal.
- ** RESULTADO REAL:** **PASSOU**. Ao forçar um bloco `try-catch` com erro simulado, o aplicativo capturou a exceção com segurança, exibiu o `SnackBar` vermelho com o erro esperado e reabilitou o botão para o usuário tentar novamente, evitando o travamento do app.

### 8. Atualização do resumo em tempo real
- **Passos:** Inserir nome e telefone aos poucos e alternar o switch de status.
- **Resultado esperado:** O cartão `Resumo` atualiza o texto conforme o usuário interage.
- ** RESULTADO REAL:** **PASSOU**. Os `TextEditingController` acoplados aos ouvintes (listeners) atualizam o estado do widget de resumo em tempo real, sem atrasos perceptíveis (lag).

### 9. Testar limpeza de campo
- **Passos:** Inserir texto em `Nome` e `Telefone` e clicar no ícone de limpar (`x`).
- **Resultado esperado:** O campo é limpo imediatamente e o resumo exibe `—`.
- ** RESULTADO REAL:** **PASSOU**. A função `.clear()` limpa o controlador e notifica a árvore de componentes, resetando as variáveis correspondentes no resumo instantaneamente.

---

##  Dados de Teste Utilizados

Os cenários foram homologados utilizando a seguinte amostragem de dados:
- **Nome válido:** `Carlos Silva`
- **Telefone válido:** `11987654321`
- **Telefone inválido:** `12345`, `987654`
- **Nome curto:** `Al`

##  Recomendações Técnicas para o Grupo

1. **Máscara de Entrada:** Recomenda-se a implementação futura de um formatador de texto (`FilteringTextInputFormatter` ou pacotes como `easy_mask`) no campo de Telefone para aplicar automaticamente o padrão `(XX) XXXXX-XXXX` enquanto o usuário digita, melhorando a experiência de uso (UX).
2. **Persistência Real:** Atualmente o código usa `Future.delayed` para simular o banco de dados. O próximo passo de desenvolvimento deve integrar esta tela ao serviço de API ou banco local (como Hive/SQLite) para que os dados fiquem salvos de verdade.