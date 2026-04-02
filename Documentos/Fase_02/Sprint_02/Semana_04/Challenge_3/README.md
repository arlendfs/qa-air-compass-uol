![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.x-green)
![Python](https://img.shields.io/badge/Python-3.11-blue)
![CI](https://github.com/arlendfs/qa-air-compass-uol/actions/workflows/ci.yml/badge.svg)
![Status](https://img.shields.io/badge/status-production--grade-brightgreen)

# 🚀 Challenge 3 — ServeRest API Automation Framework

Production-grade Robot Framework test suite for the [ServeRest API](https://compassuol.serverest.dev),
built as part of the AI/R Compass UOL program.

---

## 📁 Project Structure

```
Challenge_3/
│
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions — 5 jobs: smoke, regression, security, performance, custom
│
├── data/                       # External JSON test data (data-driven testing)
│   ├── login.json
│   ├── users.json
│   └── products.json
│
├── resources/                  # Gherkin keyword layer (Given/When/Then)
│   ├── common.resource         # Session management, auth, shared utilities
│   ├── login_page.resource
│   ├── users_page.resource
│   ├── prod_page.resource
│   └── cart_page.resource
│
├── schemas/                    # JSON Schema Draft-07 contract files
│   ├── login_schema.json
│   ├── user_schema.json
│   ├── product_schema.json
│   └── cart_schema.json
│
├── services/                   # HTTP service layer (raw API calls only)
│   ├── auth_service.resource
│   ├── user_service.resource
│   ├── product_service.resource
│   └── cart_service.resource
│
├── tests/                      # Test suites
│   ├── 01_login.robot          # CT-01 to CT-03
│   ├── 02_usuarios.robot       # CT-04 to CT-06
│   ├── 03_produtos.robot       # CT-07 to CT-09
│   ├── 04_carrinho.robot       # CT-13 to CT-18
│   ├── 04_usuarios_update.robot# CT-10 to CT-12
│   ├── 05_security.robot       # CT-SEC-01 to CT-SEC-12
│   ├── 06_edge_cases.robot     # CT-EDGE-01 to CT-EDGE-17
│   └── 07_performance.robot    # CT-PERF-01 to CT-PERF-09
│
├── utils/                      # Cross-cutting utilities
│   ├── contract.resource       # JSON Schema validation
│   ├── data_loader.resource    # JSON data file loader
│   ├── logger.resource         # Structured request/response logging
│   ├── performance.resource    # SLA assertions and load helpers
│   └── retry.resource          # Retry logic and diagnostics
│
├── logs/                       # Generated artifacts (gitignored)
├── .gitignore
├── README.md
├── requirements.txt
└── robot.yaml                  # Named execution profiles
```

---

## 🏷️ Tagging Strategy

| Tag | Meaning | When to run |
|---|---|---|
| `smoke` | Core happy paths — fastest feedback | Every push |
| `critical` | Business-critical flows | Every push, pre-deploy |
| `regression` | Full functional coverage | PRs, nightly |
| `security` | Auth, injection, authorization | PRs, nightly |
| `performance` | SLA and load checks | Nightly, scheduled |
| `contrato` / `schema` | JSON Schema contract validation | PRs, nightly |
| `edge` | Boundary and data validation | Regression |
| `data-driven` | JSON-file-driven scenarios | Regression |
| `negativo` | Expected failure scenarios | Regression |
| `positivo` | Expected success scenarios | Regression |
| `bug` | Known bugs — documents behavior | Regression |

---

## ⚙️ Installation

```bash
git clone git@github.com:arlendfs/qa-air-compass-uol.git
cd qa-air-compass-uol/Documentos/Fase_02/Sprint_02/Semana_04/Challenge_3
pip install -r requirements.txt
```

---

## ▶️ Execution

### Quick commands

```bash
# Smoke only (~30s)
robot --include smoke --outputdir logs/smoke tests/

# Full regression (no performance)
robot --include regression --exclude performance --outputdir logs/regression tests/

# Security suite
robot --include security --outputdir logs/security tests/05_security.robot

# Performance suite
robot --include performance --outputdir logs/performance tests/07_performance.robot

# Contract validation only
robot --include schema --outputdir logs/contract tests/

# Single suite
robot --outputdir logs tests/01_login.robot

# Override SLA thresholds
robot --include performance --variable SLA_FAST:800 tests/07_performance.robot

# Override base URL (e.g. production)
robot --variable BASE_URL:https://serverest.onrender.com tests/
```

### CI/CD jobs (GitHub Actions)

| Job | Trigger | Tag filter |
|---|---|---|
| Smoke | Every push | `smoke` |
| Regression | PRs + `main` push | `regression AND NOT performance` |
| Security | Every PR | `security` |
| Performance | Nightly schedule | `performance` |
| Custom | Manual dispatch | User-defined |

---

## 🧪 Test Coverage

| Suite | Tests | Tags |
|---|---|---|
| 01_login | 3 | smoke, regression, negativo |
| 02_usuarios | 3 | smoke, regression, contrato |
| 03_produtos | 3 | smoke, regression, contrato |
| 04_carrinho | 6 | smoke, regression, contrato |
| 04_usuarios_update | 3 | smoke, regression, bug |
| 05_security | 12 | security, critical, injection |
| 06_edge_cases | 17 | edge, schema, data-driven |
| 07_performance | 9 | performance, load |
| **Total** | **56** | |

---

## 🏗️ Architecture Decisions

- **Service layer** (`services/`) owns all HTTP calls — no `POST On Session` in test files
- **Gherkin layer** (`resources/`) orchestrates flow and state — no HTTP knowledge
- **Utils** are stateless cross-cutting concerns — imported only where needed
- **`Log Request` / `Log Response`** called automatically in every service keyword — zero test-level logging boilerplate
- **`Retry Request Until Success`** wraps any service keyword by name — no code duplication
- **`Validate Response Against Schema`** uses `jsonschema.Draft7Validator.iter_errors()` — reports all violations, not just the first
- **`Test Tags`** at suite level + `[Tags]` at test level — additive, not overriding

---

## 👨‍💻 Author

Arlen — [GitHub](https://github.com/arlendfs)
