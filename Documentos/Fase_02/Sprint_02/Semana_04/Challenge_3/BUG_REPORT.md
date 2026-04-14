# Bug Report — ServeRest API
**Project:** QA Automation — AI/R Compass UOL · Challenge 04  
**Environment:** `https://compassuol.serverest.dev`  
**Framework:** Robot Framework 7.4.2 · Python 3.12  
**Reported by:** Arlen Freitas  
**Date:** 2026-04-10  

---

## BUG-12 — PUT /usuarios/{id} Accepts Empty `nome` and `password` Fields

### Description
The `PUT /usuarios/{id}` endpoint accepts update requests where the `nome` or `password` fields are sent as empty strings, returning HTTP `200 OK` and persisting the invalid data. The API should reject these payloads with `400 Bad Request`, consistent with the validation applied on `POST /usuarios`.

### Steps to Reproduce

**BUG-12a — Empty `nome`:**
```http
PUT /usuarios/{valid_id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "nome": "",
  "email": "valid@email.com",
  "password": "teste123",
  "administrador": "true"
}
```

**BUG-12b — Empty `password`:**
```http
PUT /usuarios/{valid_id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "nome": "Valid Name",
  "email": "valid@email.com",
  "password": "",
  "administrador": "true"
}
```

### Expected Result
```json
HTTP 400 Bad Request
{ "nome": "nome não pode ficar em branco" }
```
```json
HTTP 400 Bad Request
{ "password": "password não pode ficar em branco" }
```

### Actual Result (Bug)
```json
HTTP 200 OK
{ "message": "Registro alterado com sucesso" }
```
The API accepts and persists the empty values without any validation error.

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **High** |
| Priority | **High** |
| Affected endpoint | `PUT /usuarios/{id}` |
| Data integrity | User records can be saved with empty `nome` or `password`, breaking downstream authentication and display logic |
| Security | An empty `password` effectively disables authentication for that user account |

### Evidence
- Automated test: `CT-USR-11` in `tests/02_usuarios.robot` — logs `WARN: BUG-12: API aceitou nome vazio`
- Automated test: `CT-USR-12` in `tests/02_usuarios.robot` — logs `WARN: BUG-12: API aceitou password vazio`
- Both tests consistently reproduce the bug on every execution against `compassuol.serverest.dev`

### Suggested Fix
Apply the same Joi/validation schema used in `POST /usuarios` to the `PUT /usuarios/{id}` handler. Both `nome` and `password` should be validated as non-empty strings before persisting.

```javascript
// Suggested validation rule (Node.js / Joi)
nome: Joi.string().min(1).required(),
password: Joi.string().min(1).required()
```

---

## BUG-13 — PUT /produtos/{id} Allows Updating to a Duplicate Product Name

### Description
The `PUT /produtos/{id}` endpoint allows renaming a product to a name already used by another existing product, returning HTTP `200 OK`. The `POST /produtos` endpoint correctly rejects duplicate names with `400 Bad Request`. This inconsistency means the uniqueness constraint is enforced only on creation, not on update.

### Steps to Reproduce
```http
# Step 1 — Create Product A
POST /produtos
Authorization: Bearer <admin_token>
{ "nome": "Produto A", "preco": 100, "descricao": "desc", "quantidade": 10 }
# → 201 Created, _id: "id_produto_a"

# Step 2 — Create Product B
POST /produtos
Authorization: Bearer <admin_token>
{ "nome": "Produto B", "preco": 200, "descricao": "desc", "quantidade": 5 }
# → 201 Created

# Step 3 — Rename Product A to "Produto B" (duplicate)
PUT /produtos/id_produto_a
Authorization: Bearer <admin_token>
{ "nome": "Produto B", "preco": 100, "descricao": "desc", "quantidade": 10 }
```

### Expected Result
```json
HTTP 400 Bad Request
{ "message": "Já existe produto com esse nome" }
```

### Actual Result (Bug)
```json
HTTP 200 OK
{ "message": "Registro alterado com sucesso" }
```
Two products now share the same name, violating the uniqueness constraint.

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **Medium** |
| Priority | **Medium** |
| Affected endpoint | `PUT /produtos/{id}` |
| Data integrity | Duplicate product names break catalog uniqueness, causing ambiguity in search and order flows |
| Consistency | Inconsistent behavior between `POST` (validates) and `PUT` (does not validate) |

### Evidence
- Automated test: `CT-PRD-05` in `tests/03_produtos.robot` — logs `WARN: BUG-13: API permitiu atualizar produto com nome duplicado`
- Bug consistently reproduced on every execution

### Suggested Fix
Apply the same uniqueness check used in `POST /produtos` to the `PUT /produtos/{id}` handler, excluding the product being updated from the duplicate check.

```javascript
// Pseudo-code
const existing = await db.produtos.findOne({ nome: body.nome, _id: { $ne: id } });
if (existing) return res.status(400).json({ message: "Já existe produto com esse nome" });
```

---

## BUG-14 — DELETE /usuarios/{id} Behavior With Active Cart Is Inconsistent

### Description
The `DELETE /usuarios/{id}` endpoint is expected to return `400 Bad Request` when the target user has an active cart, preventing orphaned cart records. During automated testing, the API intermittently returns `200 OK` and deletes the user while the cart remains active in the database, creating orphaned cart records.

### Steps to Reproduce
```http
# Step 1 — Create a non-admin user
POST /usuarios
{ "nome": "Test User", "email": "test@email.com", "password": "teste123", "administrador": "false" }

# Step 2 — Create a product (admin token required)
POST /produtos
Authorization: Bearer <admin_token>
{ "nome": "Produto Teste", "preco": 100, "descricao": "desc", "quantidade": 5 }

# Step 3 — Create a cart for the non-admin user
POST /carrinhos
Authorization: Bearer <user_token>
{ "produtos": [{ "idProduto": "<product_id>", "quantidade": 1 }] }

# Step 4 — Attempt to delete the user while cart is active
DELETE /usuarios/<user_id>
```

### Expected Result
```json
HTTP 400 Bad Request
{ "message": "Não é permitido excluir usuário com carrinho cadastrado" }
```

### Actual Result (Bug)
```json
HTTP 200 OK
{ "message": "Registro excluído com sucesso" }
```
The user is deleted while the cart record remains active, creating an orphaned cart with no associated user.

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **High** |
| Priority | **High** |
| Affected endpoint | `DELETE /usuarios/{id}` |
| Data integrity | Orphaned cart records reference a non-existent `idUsuario`, breaking referential integrity |
| Business logic | Checkout and cancellation flows fail for orphaned carts since the user no longer exists |

### Evidence
- Automated test: `CT-USR-07` in `tests/02_usuarios.robot` — logs `WARN: BUG-14: API permitiu deletar usuário com carrinho ativo`
- Bug is intermittent — the test uses `IF/ELSE` to document both outcomes without failing the pipeline

### Suggested Fix
Add a pre-deletion check in the `DELETE /usuarios/{id}` handler to verify whether the user has any active cart before proceeding.

```javascript
// Pseudo-code
const cart = await db.carrinhos.findOne({ idUsuario: id });
if (cart) {
  return res.status(400).json({ message: "Não é permitido excluir usuário com carrinho cadastrado" });
}
```

---

## BUG-15 — GET /usuarios Endpoint Is Publicly Accessible Without Authentication

### Description
The `GET /usuarios` endpoint returns the full list of registered users, including names, emails, and passwords, without requiring any `Authorization` header. This exposes sensitive user data to unauthenticated requests.

### Steps to Reproduce
```http
GET /usuarios
# No Authorization header
```

### Expected Result
```json
HTTP 401 Unauthorized
{ "message": "Token de acesso ausente, inválido, expirado ou usuário do token não existe mais" }
```

### Actual Result (Bug)
```json
HTTP 200 OK
{
  "quantidade": N,
  "usuarios": [
    { "nome": "...", "email": "...", "password": "...", "administrador": "...", "_id": "..." }
  ]
}
```
Full user list including passwords returned without authentication.

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **Critical** |
| Priority | **High** |
| Affected endpoint | `GET /usuarios` |
| Security | Unauthenticated data exposure — passwords visible in plaintext |
| Compliance | Violates OWASP API Security Top 10 — API2: Broken Authentication |

### Evidence
- Automated test: `CT-SEC-01` in `tests/05_security.robot` — documents that `GET /usuarios` returns `200` without a token
- Test tagged `positivo` — passes because the API accepts the unauthenticated request, which is the documented (but insecure) behavior

### Suggested Fix
Require a valid Bearer token for `GET /usuarios`. If public listing is a product requirement, at minimum remove `password` from the response payload.

---

## BUG-16 — POST /usuarios Accepts Nome With 500+ Characters (No Length Validation)

### Description
The `POST /usuarios` endpoint accepts a `nome` field with 500 or more characters without any validation error, returning `201 Created`. There is no documented maximum length for this field, and no server-side enforcement exists.

### Steps to Reproduce
```http
POST /usuarios
{
  "nome": "AAAA...AAA",  // 500 random alphanumeric characters
  "email": "test@email.com",
  "password": "teste123",
  "administrador": "false"
}
```

### Expected Result
```json
HTTP 400 Bad Request
{ "nome": "nome deve ter no máximo X caracteres" }
```

### Actual Result (Bug)
```json
HTTP 201 Created
{ "message": "Cadastro realizado com sucesso", "_id": "..." }
```

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **Low** |
| Priority | **Low** |
| Affected endpoint | `POST /usuarios` |
| Data integrity | Unbounded string storage can cause database performance issues at scale |
| UX | UI components rendering the `nome` field may overflow or break with excessively long values |

### Evidence
- Automated test: `CT-EDG-02` in `tests/06_edge_cases.robot` — logs `WARN: OBSERVAÇÃO: API aceitou nome de 500 chars — sem limite de tamanho definido`
- Reproduced consistently on every execution

### Suggested Fix
Add a maximum length constraint to the `nome` field validation schema.

```javascript
nome: Joi.string().min(1).max(100).required()
```

---

## BUG-17 — POST /produtos Accepts preco=0 (No Minimum Price Validation)

### Description
The `POST /produtos` endpoint accepts `preco=0`, creating a product with a zero price. While negative values are correctly rejected with `400`, zero is silently accepted. A product with zero price has no commercial meaning and likely indicates a data entry error.

### Steps to Reproduce
```http
POST /produtos
Authorization: Bearer <admin_token>
{
  "nome": "Produto Preco Zero",
  "preco": 0,
  "descricao": "Test",
  "quantidade": 10
}
```

### Expected Result
```json
HTTP 400 Bad Request
{ "preco": "preco deve ser um número positivo" }
```

### Actual Result (Bug)
```json
HTTP 201 Created
{ "message": "Cadastro realizado com sucesso", "_id": "..." }
```

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **Low** |
| Priority | **Low** |
| Affected endpoint | `POST /produtos` |
| Business logic | Products with zero price can be added to carts and checked out for free |
| Consistency | Inconsistent with the rejection of negative prices — zero should be treated the same way |

### Evidence
- Automated test: `CT-EDG-04` in `tests/06_edge_cases.robot` — logs `WARN: OBSERVAÇÃO: API aceitou preco=0 — comportamento permissivo documentado`
- Reproduced consistently on every execution

### Suggested Fix
Change the price validation from `>= 0` to `> 0`.

```javascript
preco: Joi.number().positive().required()
// instead of
preco: Joi.number().min(0).required()
```

---

## BUG-ENV-01 — Shared Environment: Admin User Deleted Between Test Runs

### Description
The test environment `compassuol.serverest.dev` is shared among all program participants. The admin user `fulano@qa.com` is periodically deleted by other users' test executions (e.g., tests that call `DELETE /usuarios` without proper cleanup). This causes all suites that depend on admin authentication to fail with `401 Unauthorized` at Suite Setup.

### Steps to Reproduce
```
1. Run the full test suite successfully
2. Wait for another participant to run a DELETE /usuarios test without cleanup
3. Run the test suite again
4. All suites fail at Suite Setup with:
   "Falha no login com 'fulano@qa.com' — status: 401"
```

### Expected Result
The admin user should persist between test runs. The environment should either protect the admin account or provide isolated environments per user.

### Actual Result (Bug)
```
Suite setup failed:
Falha no login com 'fulano@qa.com' — status: 401 | body: {"message": "Email e/ou senha inválidos"}
```
All 60 tests fail in cascade.

### Impact
| Dimension | Assessment |
|---|---|
| Severity | **High** (environment) |
| Priority | **High** |
| Affected | All 7 suites (60 tests) |
| CI/CD | Pipeline fails on every affected run without manual intervention |
| Reproducibility | Intermittent — depends on other participants' activity |

### Evidence
- Observed repeatedly across multiple test sessions
- Affects suites: `01_login`, `02_usuarios`, `03_produtos`, `04_carrinho`, `05_security`, `06_edge_cases`, `07_performance`

### Mitigation Applied
- `utils/recreate_admin.robot` — standalone recovery script
- `Garantir Admin Existe` keyword in `resources/common.resource` — called in every Suite Setup; silently recreates the admin if login returns 401
- `.github/workflows/ci.yml` — CI pipeline runs `recreate_admin.robot` as a dedicated step before the test suite

---

## Summary Table

| Bug ID | Endpoint | Severity | Priority | Status | Test Case | File |
|---|---|---|---|---|---|---|
| BUG-12a | `PUT /usuarios/{id}` — aceita `nome` vazio | High | High | Open | CT-USR-11 | `02_usuarios.robot` |
| BUG-12b | `PUT /usuarios/{id}` — aceita `password` vazio | High | High | Open | CT-USR-12 | `02_usuarios.robot` |
| BUG-13 | `PUT /produtos/{id}` — permite nome duplicado | Medium | Medium | Open | CT-PRD-05 | `03_produtos.robot` |
| BUG-14 | `DELETE /usuarios/{id}` — deleta usuário com carrinho ativo | High | High | Open | CT-USR-07 | `02_usuarios.robot` |
| BUG-15 | `GET /usuarios` — endpoint público sem autenticação | Critical | High | Open | CT-SEC-01 | `05_security.robot` |
| BUG-16 | `POST /usuarios` — aceita `nome` com 500+ chars | Low | Low | Open | CT-EDG-02 | `06_edge_cases.robot` |
| BUG-17 | `POST /produtos` — aceita `preco=0` | Low | Low | Open | CT-EDG-04 | `06_edge_cases.robot` |
| BUG-ENV-01 | Ambiente compartilhado — admin deletado entre execuções | High | High | Mitigated | Todos | `common.resource` |
