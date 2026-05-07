# Plano de trabalho — Produto

Objetivo: criar telas para listar, visualizar e cadastrar produtos, com componente de formulário reutilizável e integração com a API.

Etapas:

1. Criar modelo `Produto` em `lib/model/produto.dart`.
2. Implementar `ProdutoService` em `lib/services/produto_service.dart` (usa `dio` e `lib/utils/constants_api.dart`).
3. Criar pasta de telas `lib/pages/produtos/` com:
   - `produto_list_page.dart` — tela de listagem e visualização básica.
   - `produto_form_page.dart` — tela que usa o componente de formulário para criar/editar.
   - `components/product_form_component.dart` — componente reutilizável do formulário (create/edit).
4. Atualizar `lib/pages/produto.dart` para apontar para a nova listagem.
5. Testar manualmente: `flutter run -d web-server` ou `flutter run -d chrome`.

Notas de implementação:
- O serviço usa os endpoints fornecidos: POST /produtos, GET /produtos, GET /produtos/{id}, PUT /produtos/{id}, DELETE /produtos/{id}.
- O componente de formulário aceita um `Produto?` inicial e uma função `onSubmit` que executa a requisição (create/update).
- Após criar/editar/excluir, as telas atualizam a listagem automaticamente.

Riscos/validações:
- Preservar campos obrigatórios (nome, preco, tipoProduto, setorProducao, categoriaId).
- Erros de rede são tratados com SnackBar simples.

Próximo passo: implementação dos arquivos listados.
