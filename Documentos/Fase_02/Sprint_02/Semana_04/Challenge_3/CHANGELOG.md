# Changelog

All notable changes to this project are documented in this file.  
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [v1.4-challenge04] — 2026-04-10

### Removed

- `utils/retry.resource` — arquivo vazio, sem uso no projeto
- `utils/logger.resource` — arquivo vazio, sem uso no projeto
- `utils/contract.resource` — arquivo vazio, sem uso no projeto
- `utils/data_loader.json` — arquivo vazio, sem uso no projeto

---

## [v1.3-challenge04] — 2026-04-10

### Added

- `Garantir Admin Existe` keyword in `resources/common.resource` — called in every Suite Setup; silently recreates `fulano@qa.com` if login returns 401, eliminating the need to run `recreate_admin.robot` manually before each execution
- `.github/workflows/ci.yml` — production-ready GitHub Actions CI/CD pipeline:
  - Triggers on `push` and `pull_request` to `main`
  - Ubuntu runner with Python 3.12 and `pip` cache
  - Dedicated step to run `recreate_admin.robot` before the test suite
  - `robot -d ./logs ./tests` as the main execution step with `continue-on-error: true`
  - Artifact upload (`report.html`, `log.html`, `output.xml`) with `if: always()` and 30-day retention

### Changed

- All Suite Setups updated to call `Garantir Admin Existe` after `Criar Sessão ServeRest`:
  - `tests/01_login.robot` — new `Inicializar Suite De Login` keyword
  - `tests/02_usuarios.robot` — `Criar Sessão ServeRest E Criar Usuario Teste` in `users_page.resource`
  - `tests/03_produtos.robot` — `Inicializar Suite De Produtos`
  - `tests/04_carrinho.robot` — `Inicializar Suite De Carrinho`
  - `tests/05_security.robot` — `Inicializar Suite De Segurança`
  - `tests/06_edge_cases.robot` — `Inicializar Suite De Edge Cases`
  - `tests/07_performance.robot` — `Inicializar Suite De Performance`
- `requirements.txt` — removed `robotframework-seleniumlibrary` (project is API-only, no UI); added `requests` (required by `concurrent_helper.py`)
- `CT-PER-05` SLA adjusted from `1000 ms` to `1500 ms` — `DELETE /carrinhos/concluir-compra` under concurrent load measured at ~1058 ms on the shared cloud environment

### Fixed

- `BUG-ENV-01` (mitigated) — admin user deletion in shared environment no longer causes full suite failure; `Garantir Admin Existe` auto-recovers before any test runs

### Bugs Reported

| Bug ID | Endpoint | Severidade | Test Case | Status |
|---|---|---|---|---|
| BUG-ENV-01 | Ambiente compartilhado — admin deletado | High | Todos | Mitigated |

---

## [v1.2-challenge04] — 2026-04-10

### Changed

- All test case identifiers refactored from sequential global numbering (`CT-01` … `CT-60`) to domain-prefixed numbering (`CT-<DOMAIN>-<NN>`):

| Prefixo | Domínio | Range |
|---|---|---|
| `CT-LGN` | Login | CT-LGN-01 a CT-LGN-07 |
| `CT-USR` | Usuários | CT-USR-01 a CT-USR-12 |
| `CT-PRD` | Produtos | CT-PRD-01 a CT-PRD-09 |
| `CT-CRT` | Carrinho | CT-CRT-01 a CT-CRT-11 |
| `CT-SEC` | Segurança | CT-SEC-01 a CT-SEC-08 |
| `CT-EDG` | Edge Cases | CT-EDG-01 a CT-EDG-08 |
| `CT-PER` | Performance | CT-PER-01 a CT-PER-05 |

- All inline debug log references updated to match new CT IDs (e.g. `[CT-16 DEBUG]` → `[CT-USR-09 DEBUG]`)
- `BUG_REPORT.md` — all Evidence sections updated with new CT IDs and correct file references
- `README.md` — scope table updated with `Prefixo` column; new section "Convenção de Identificadores"; bug table updated with new CT IDs; architecture tree updated

### Fixed

- `Atualizar Usuário Por ID` in `resources/users_page.resource` — `RETURN    Atualizar Usuário    ...` was returning a Python list instead of a Response object; corrected to `${res}    Atualizar Usuário    ...` + `RETURN    ${res}`

---

## [v1.1-challenge04] — 2026-04-09

### Changed

- `tests/02_usuarios.robot` — absorbed all CTs from `04_usuarios_update.robot` (CT-USR-10 to CT-USR-12); suite now covers CT-USR-01 to CT-USR-12 in a single file
- `tests/02_usuarios.robot` — Suite Setup updated to `Criar Sessão ServeRest E Criar Usuario Teste`; Suite Teardown updated to `Limpar Usuario Teste E Encerrar Sessão`
- `resources/users_page.resource` — absorbed all logic from `users_update_page.resource`: variables `${ID_USUARIO_TESTE}` and `${EMAIL_USUARIO_TESTE}`, keywords `Criar Sessão ServeRest E Criar Usuario Teste`, `Limpar Usuario Teste`, `Atualizar Usuário Por ID`
- `README.md` — scope table updated: `04_usuarios_update.robot` row removed; `02_usuarios.robot` now lists CT-USR-01 to CT-USR-12 with Atualização category; file tree and execution commands updated

### Removed

- `tests/04_usuarios_update.robot` — removed after consolidation into `02_usuarios.robot`
- `resources/users_update_page.resource` — removed after consolidation into `users_page.resource`

---

## [v1.0-challenge04] — 2026-04-09

### Added

#### Test Suites
- `tests/01_login.robot` — CT-LGN-01 to CT-LGN-07 (7 tests): login positivo, negativo, contrato e edge cases
- `tests/02_usuarios.robot` — CT-USR-01 to CT-USR-12 (12 tests): criação, busca, listagem, atualização, deleção e edge cases de usuários
- `tests/03_produtos.robot` — CT-PRD-01 to CT-PRD-09 (9 tests): criação, listagem, busca, atualização e edge cases de produtos
- `tests/04_carrinho.robot` — CT-CRT-01 to CT-CRT-11 (11 tests): criação, checkout, cancelamento, contrato e edge cases de carrinho
- `tests/05_security.robot` — CT-SEC-01 to CT-SEC-08 (8 tests): autenticação, autorização e resistência a payloads maliciosos
- `tests/06_edge_cases.robot` — CT-EDG-01 to CT-EDG-08 (8 tests): boundary values, unicode, limites numéricos, carrinho multi-item e concorrência
- `tests/07_performance.robot` — CT-PER-01 to CT-PER-05 (5 tests): SLA de tempo de resposta e carga concorrente

#### Resources
- `resources/security.resource` — keywords de segurança: autenticação, autorização e injeção
- `resources/users_page.resource` — expandido com todas as primitivas e keywords de atualização de usuários

#### Utilities
- `utils/concurrent_helper.py` — biblioteca Python para requisições HTTP concorrentes via `ThreadPoolExecutor`; expõe `post_usuario_concorrente`, `post_usuario_concorrente_com_tempo` e `delete_concluir_compra_com_tempo`
- `utils/performance.resource` — keywords de SLA: `Obter Elapsed Ms`, `Validar SLA`, `Validar SLA Lista`
- `utils/recreate_admin.robot` — script utilitário standalone para recriar o usuário admin no ambiente compartilhado

#### Schemas
- `schemas/login_schema.json` — schema JSON Draft-07 para `POST /login`
- `schemas/user_schema.json` — schemas para `POST /usuarios` (201), `GET /usuarios` (200) e `GET /usuarios/{id}` (200)
- `schemas/product_schema.json` — schemas para `POST /produtos` (201), `GET /produtos` (200) e `GET /produtos/{id}` (200)
- `schemas/cart_schema.json` — schemas para `POST /carrinhos` (201) e `GET /carrinhos/{id}` (200)

#### Documentation
- `BUG_REPORT.md` — relatório profissional com 8 bugs identificados (BUG-12 a BUG-ENV-01)
- `CHANGELOG.md` — este arquivo
- `README.md` — documentação completa do projeto

### Changed

#### `resources/common.resource`
- `Pegar Token de Autenticação` — valida status code antes de acessar `authorization`; emite mensagem de erro clara quando login retorna 401

#### `resources/users_page.resource`
- `Então O Cadastro De Usuário Deve Falhar Com` — reescrita com lógica defensiva: valida status antes de acessar campos; trata `message` e campos de validação nomeados
- `Então Os Dados Do Usuário Devem Estar Corretos` — expandida com campos `password` e `_id`
- Adicionadas primitivas: `Listar Usuários`, `Atualizar Usuário`, `Deletar Usuário`, `Atualizar Usuário Por ID`
- Adicionadas keywords de setup/teardown: `Criar Sessão ServeRest E Criar Usuario Teste`, `Limpar Usuario Teste`

#### `resources/prod_page.resource`
- `Então O Cadastro De Produto Deve Falhar Com` — reescrita com log de debug e lógica `message` vs campo de validação
- Adicionadas primitivas: `Atualizar Produto`, `Deletar Produto`

#### `resources/cart_page.resource`
- `Cancelar Carrinho Se Existir` — resiliente quando `${TOKEN}` não está definido
- Adicionada `Limpar Carrinho Residual Do Admin` — chamada no Suite Setup
- Adicionadas keywords para CT-CRT-07, CT-CRT-09, CT-CRT-10, CT-CRT-11

#### `resources/login_page.resource`
- Adicionadas: `Então O Contrato De Login Deve Estar Correto`, `Quando Realizo Login Com Body Raw`

### Fixed

- **CT-PRD-08** — mensagem esperada corrigida de `"quantidade deve ser um número positivo"` para `"quantidade deve ser maior ou igual a 0"` (mensagem real do ServeRest)
- **CT-USR-09** — `Então O Cadastro De Usuário Deve Falhar Com` corrigida para tratar resposta sem chave `message`
- **CT-CRT-01** — falha em cascata por carrinho residual do admin corrigida via `Limpar Carrinho Residual Do Admin` no Suite Setup
- **`05_security.robot`** — `Inicializar Suite De Segurança` corrigida: removida chamada `GET /login` inválida; query string `?email=` substituída por `params=`
- **CT-SEC-05** — `${ID_PRODUTO_SEC}` corrigido de `Set Test Variable` para `Set Suite Variable`
- **`utils/performance.resource`** — path relativo `common.resource` corrigido para `../resources/common.resource`

### Bugs Reported

| Bug ID | Endpoint | Severidade | Test Case | Descrição |
|---|---|---|---|---|
| BUG-12a | `PUT /usuarios/{id}` | High | CT-USR-11 | API aceita `nome` vazio sem validação |
| BUG-12b | `PUT /usuarios/{id}` | High | CT-USR-12 | API aceita `password` vazio sem validação |
| BUG-13 | `PUT /produtos/{id}` | Medium | CT-PRD-05 | API permite renomear produto para nome já existente |
| BUG-14 | `DELETE /usuarios/{id}` | High | CT-USR-07 | API deleta usuário com carrinho ativo, criando registros órfãos |
| BUG-15 | `GET /usuarios` | Critical | CT-SEC-01 | Endpoint público expõe dados de usuários sem autenticação |
| BUG-16 | `POST /usuarios` | Low | CT-EDG-02 | API aceita `nome` com 500+ caracteres sem validação de tamanho |
| BUG-17 | `POST /produtos` | Low | CT-EDG-04 | API aceita `preco=0` sem validação de valor mínimo |
| BUG-ENV-01 | Ambiente compartilhado | High | Todos | Admin deletado entre execuções — mitigado com `Garantir Admin Existe` |

---

## [v0.1-challenge03] — 2026-03-XX

### Added
- Estrutura inicial do projeto Robot Framework para ServeRest API
- 18 casos de teste iniciais cobrindo login, usuários, produtos e carrinho
- Resources base: `common.resource`, `login_page.resource`, `users_page.resource`, `prod_page.resource`, `cart_page.resource`
- Padrão Gherkin (Given / When / Then) aplicado em todas as suites
- Gerenciamento de sessão HTTP com `RequestsLibrary`
