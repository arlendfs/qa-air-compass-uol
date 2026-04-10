# Changelog

All notable changes to this project are documented in this file.  
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [v1.0-challenge04] — 2026-04-09

### Added

#### Test Suites
- `tests/01_login.robot` — CT-01 to CT-07 (7 tests): login positivo, negativo, contrato e edge cases
- `tests/02_usuarios.robot` — CT-08 to CT-16 (9 tests): criação, busca, listagem, atualização, deleção e edge cases de usuários
- `tests/03_produtos.robot` — CT-17 to CT-25 (9 tests): criação, listagem, busca, atualização e edge cases de produtos
- `tests/04_carrinho.robot` — CT-26 to CT-36 (11 tests): criação, checkout, cancelamento, contrato e edge cases de carrinho
- `tests/04_usuarios_update.robot` — CT-37 to CT-39 (3 tests): atualização de usuários com validação de campos
- `tests/05_security.robot` — CT-40 to CT-47 (8 tests): autenticação, autorização e resistência a payloads maliciosos
- `tests/06_edge_cases.robot` — CT-48 to CT-55 (8 tests): boundary values, unicode, limites numéricos, carrinho multi-item e concorrência
- `tests/07_performance.robot` — CT-56 to CT-60 (5 tests): SLA de tempo de resposta e carga concorrente

#### Resources
- `resources/security.resource` — keywords de segurança: autenticação, autorização e injeção
- `resources/users_update_page.resource` — keywords de atualização de usuários via `PUT /usuarios/{id}`

#### Utilities
- `utils/concurrent_helper.py` — biblioteca Python para requisições HTTP concorrentes via `ThreadPoolExecutor`; expõe `post_usuario_concorrente`, `post_usuario_concorrente_com_tempo` e `delete_concluir_compra_com_tempo`
- `utils/performance.resource` — keywords de SLA: `Obter Elapsed Ms`, `Validar SLA`, `Validar SLA Lista`
- `utils/recreate_admin.robot` — script utilitário para recriar o usuário admin no ambiente compartilhado quando o login retornar 401

#### Schemas
- `schemas/login_schema.json` — schema JSON Draft-07 para `POST /login` (campos `message` e `authorization`)
- `schemas/user_schema.json` — schemas para `POST /usuarios` (201), `GET /usuarios` (200) e `GET /usuarios/{id}` (200)
- `schemas/product_schema.json` — schemas para `POST /produtos` (201), `GET /produtos` (200) e `GET /produtos/{id}` (200)
- `schemas/cart_schema.json` — schemas para `POST /carrinhos` (201) e `GET /carrinhos/{id}` (200)

#### Documentation
- `BUG_REPORT.md` — relatório profissional com 7 bugs identificados (BUG-12 a BUG-17)
- `CHANGELOG.md` — este arquivo

---

### Changed

#### `resources/common.resource`
- `Pegar Token de Autenticação` agora valida o status code antes de acessar o campo `authorization`, emitindo mensagem de erro clara quando o login retorna 401 — evita `KeyError: authorization` em cascata

#### `resources/users_page.resource`
- `Então O Cadastro De Usuário Deve Falhar Com` reescrita com lógica defensiva: valida status antes de acessar campos, trata tanto `message` quanto campos de validação nomeados (ex: `{"nome": "..."}`)
- `Então Os Dados Do Usuário Devem Estar Corretos` expandida com campos `password` e `_id` que estavam ausentes
- Adicionadas primitivas: `Listar Usuários`, `Atualizar Usuário`, `Deletar Usuário`
- Adicionadas keywords Gherkin: `Quando Listo Todos Os Usuários`, `Quando Atualizo O Email Do Usuário Para Um Já Existente`, `Quando Deleto O Usuário`, `Quando Busco Usuário Com ID Malformado`
- Adicionados Thens de contrato: `Então O Contrato De Criação De Usuário Deve Estar Correto`, `Então O Contrato De Listagem De Usuários Deve Estar Correto`

#### `resources/prod_page.resource`
- `Então O Cadastro De Produto Deve Falhar Com` reescrita com log de debug e lógica `message` vs campo de validação
- Adicionadas keywords: `Então O Contrato Do Produto Deve Estar Correto`, `Então A Operação De Produto Não Deve Ser Erro Interno`
- Adicionadas primitivas: `Atualizar Produto`, `Deletar Produto`

#### `resources/cart_page.resource`
- `Cancelar Carrinho Se Existir` agora é resiliente quando `${TOKEN}` não está definido — obtém token fresco antes de tentar cancelar
- Adicionada `Limpar Carrinho Residual Do Admin` — chamada no Suite Setup para garantir estado limpo entre execuções
- Adicionadas keywords: `Então O Contrato De Criação De Carrinho Deve Estar Correto`, `Então A Operação Deve Retornar Não Autorizado`
- Adicionadas keywords When para CT-32, CT-34, CT-35, CT-36

#### `resources/login_page.resource`
- Adicionadas keywords: `Então O Contrato De Login Deve Estar Correto`, `Quando Realizo Login Com Body Raw`

#### `tests/04_carrinho.robot`
- Suite Setup atualizado para chamar `Limpar Carrinho Residual Do Admin`, prevenindo falha em cascata por carrinho residual de execução anterior

---

### Fixed

- **CT-24** — mensagem esperada corrigida de `"quantidade deve ser um número positivo"` para `"quantidade deve ser maior ou igual a 0"` (mensagem real do ServeRest)
- **CT-16** — `Então O Cadastro De Usuário Deve Falhar Com` corrigida para tratar resposta de validação de campo sem chave `message`
- **CT-26** — falha em cascata por carrinho residual do admin corrigida via `Limpar Carrinho Residual Do Admin` no Suite Setup
- **05_security.robot** — `Inicializar Suite De Segurança` corrigida: removida chamada `GET /login` inválida; query string `?email=` substituída por `params=` para evitar erro de parsing do Robot Framework
- **CT-44** — `${ID_PRODUTO_SEC}` corrigido de `Set Test Variable` para `Set Suite Variable` em `Provisionar Produto Com Token Admin`
- **`performance.resource`** — path relativo `common.resource` corrigido para `../resources/common.resource`

---

### Bugs Reported

| Bug ID | Endpoint | Severidade | Test Case | Descrição |
|---|---|---|---|---|
| BUG-12a | `PUT /usuarios/{id}` | High | CT-38 | API aceita `nome` vazio sem validação |
| BUG-12b | `PUT /usuarios/{id}` | High | CT-39 | API aceita `password` vazio sem validação |
| BUG-13 | `PUT /produtos/{id}` | Medium | CT-21 | API permite renomear produto para nome já existente |
| BUG-14 | `DELETE /usuarios/{id}` | High | CT-14 | API deleta usuário com carrinho ativo, criando registros órfãos |
| BUG-15 | `GET /usuarios` | Critical | CT-40 | Endpoint público expõe dados de usuários sem autenticação |
| BUG-16 | `POST /usuarios` | Low | CT-49 | API aceita `nome` com 500+ caracteres sem validação de tamanho |
| BUG-17 | `POST /produtos` | Low | CT-51 | API aceita `preco=0` sem validação de valor mínimo |

> Detalhes completos em [`BUG_REPORT.md`](./BUG_REPORT.md)

---

### Documentation

- `README.md` atualizado com escopo completo do Challenge 04: tabela de suites, endpoints cobertos, bugs identificados, estrutura de projeto, comandos de execução por tag e distribuição de testes por categoria
- `BUG_REPORT.md` criado com 7 bugs documentados seguindo estrutura profissional: Description, Steps to Reproduce, Expected Result, Actual Result, Impact, Evidence, Suggested Fix
- `CHANGELOG.md` criado (este arquivo)

---

## [v0.1-challenge03] — 2026-03-XX

### Added
- Estrutura inicial do projeto Robot Framework para ServeRest API
- 18 casos de teste iniciais (CT-01 a CT-18) cobrindo login, usuários, produtos e carrinho
- Resources base: `common.resource`, `login_page.resource`, `users_page.resource`, `prod_page.resource`, `cart_page.resource`
- Padrão Gherkin (Given / When / Then) aplicado em todas as suites
- Gerenciamento de sessão HTTP com `RequestsLibrary`
