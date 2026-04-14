![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.4.2-green)
![Python](https://img.shields.io/badge/Python-3.14.3-blue)
![Status](https://img.shields.io/badge/status-Challenge%2004%20Complete-brightgreen)
![Tests](https://img.shields.io/badge/tests-60%20CTs-informational)
![Bugs](https://img.shields.io/badge/bugs%20found-7-red)

# 🚀 Challenge 04 — Automação de API REST com Robot Framework

## 📌 Visão Geral

Este projeto contém a automação de testes da API **ServeRest** (`compassuol.serverest.dev`), desenvolvido como parte do **Challenge 04** do programa de bolsas **AI/R Compass UOL — Fase 02, Sprint 02**.

O objetivo é validar fluxos críticos da aplicação por meio de testes funcionais, de contrato, segurança, edge cases e performance, totalizando **60 casos de teste** distribuídos em **7 suites**.

---

## 🎯 Escopo de Cobertura

| Suite | Arquivo | Prefixo | CTs | Categorias |
|---|---|---|---|---|
| Login | `01_login.robot` | `CT-LGN` | CT-LGN-01 a CT-LGN-07 | Positivo, Negativo, Contrato, Edge |
| Usuários | `02_usuarios.robot` | `CT-USR` | CT-USR-01 a CT-USR-12 | Positivo, Negativo, Contrato, Atualização, Bug, Edge |
| Produtos | `03_produtos.robot` | `CT-PRD` | CT-PRD-01 a CT-PRD-09 | Positivo, Negativo, Contrato, Bug, Edge |
| Carrinho | `04_carrinho.robot` | `CT-CRT` | CT-CRT-01 a CT-CRT-11 | Positivo, Negativo, Contrato, Edge, Segurança |
| Segurança | `05_security.robot` | `CT-SEC` | CT-SEC-01 a CT-SEC-08 | Autenticação, Autorização, Injeção |
| Edge Cases | `06_edge_cases.robot` | `CT-EDG` | CT-EDG-01 a CT-EDG-08 | Boundary, Unicode, Limites, Concorrência |
| Performance | `07_performance.robot` | `CT-PER` | CT-PER-01 a CT-PER-05 | SLA, Carga Concorrente |

### Convenção de Identificadores

Os casos de teste seguem o padrão `CT-<DOMÍNIO>-<NN>`, onde o prefixo identifica o domínio funcional e a numeração reinicia em `01` por domínio:

| Prefixo | Domínio |
|---|---|
| `CT-LGN` | Login / Autenticação |
| `CT-USR` | Usuários (criação, busca, atualização) |
| `CT-PRD` | Produtos |
| `CT-CRT` | Carrinho |
| `CT-SEC` | Segurança |
| `CT-EDG` | Edge Cases |
| `CT-PER` | Performance |

### Endpoints Cobertos

| Método | Endpoint | Coberto |
|---|---|---|
| `POST` | `/login` | ✅ |
| `GET` | `/usuarios` | ✅ |
| `POST` | `/usuarios` | ✅ |
| `PUT` | `/usuarios/{id}` | ✅ |
| `DELETE` | `/usuarios/{id}` | ✅ |
| `GET` | `/produtos` | ✅ |
| `POST` | `/produtos` | ✅ |
| `PUT` | `/produtos/{id}` | ✅ |
| `DELETE` | `/produtos/{id}` | ✅ |
| `GET` | `/carrinhos` | ✅ |
| `POST` | `/carrinhos` | ✅ |
| `DELETE` | `/carrinhos/concluir-compra` | ✅ |
| `DELETE` | `/carrinhos/cancelar-compra` | ✅ |

---

## 🐛 Bugs Identificados

| Bug ID | Endpoint | Severidade | Test Case |
|---|---|---|---|
| BUG-12a | `PUT /usuarios/{id}` — aceita `nome` vazio | High | CT-USR-11 |
| BUG-12b | `PUT /usuarios/{id}` — aceita `password` vazio | High | CT-USR-12 |
| BUG-13 | `PUT /produtos/{id}` — permite nome duplicado | Medium | CT-PRD-05 |
| BUG-14 | `DELETE /usuarios/{id}` — deleta usuário com carrinho ativo | High | CT-USR-07 |
| BUG-15 | `GET /usuarios` — endpoint público sem autenticação | Critical | CT-SEC-01 |
| BUG-16 | `POST /usuarios` — aceita `nome` com 500+ chars | Low | CT-EDG-02 |
| BUG-17 | `POST /produtos` — aceita `preco=0` | Low | CT-EDG-04 |

> Detalhes completos em [`BUG_REPORT.md`](./BUG_REPORT.md)

---

## 🏗️ Arquitetura do Projeto

```text
Challenge_3/
│
├── tests/
│   ├── 01_login.robot              # CT-LGN-01 a CT-LGN-07
│   ├── 02_usuarios.robot           # CT-USR-01 a CT-USR-12
│   ├── 03_produtos.robot           # CT-PRD-01 a CT-PRD-09
│   ├── 04_carrinho.robot           # CT-CRT-01 a CT-CRT-11
│   ├── 05_security.robot           # CT-SEC-01 a CT-SEC-08
│   ├── 06_edge_cases.robot         # CT-EDG-01 a CT-EDG-08
│   └── 07_performance.robot        # CT-PER-01 a CT-PER-05
│
├── resources/
│   ├── common.resource
│   ├── login_page.resource
│   ├── users_page.resource
│   ├── prod_page.resource
│   ├── cart_page.resource
│   └── security.resource
│
├── schemas/
│   ├── login_schema.json
│   ├── user_schema.json
│   ├── product_schema.json
│   └── cart_schema.json
│
├── utils/
│   ├── concurrent_helper.py
│   ├── performance.resource
│   └── recreate_admin.robot
│
├── data/
│   ├── login.json
│   ├── users.json
│   └── products.json
│
├── logs/
│   ├── regression/
│   ├── smoke/
│   ├── contract/
│   ├── security/
│   └── performance/
│
├── BUG_REPORT.md
├── CHANGELOG.md
├── README.md
└── requirements.txt
```

---

## ⚙️ Tecnologias e Conceitos Aplicados

### 🧪 Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Robot Framework | 7.4.2 | Framework de automação |
| RequestsLibrary | latest | Requisições HTTP |
| Python | 3.14.3 | Runtime e helpers |
| `concurrent.futures` | stdlib | Testes de concorrência |
| `requests` | latest | HTTP no helper Python |

### 🧠 Conceitos

- Padrão **Gherkin** (Given / When / Then)
- Separação de responsabilidades (Resources vs Tests)
- **Contract Testing** com validação de schema JSON
- **Security Testing** — autenticação, autorização, injeção
- **Edge Case Testing** — boundary values, unicode, limites numéricos
- **Performance Testing** — SLA, carga concorrente via `ThreadPoolExecutor`
- **Bug Documentation** via `Log WARN` com rastreabilidade por CT
- Gerenciamento de estado com `Set Test Variable` / `Set Suite Variable`
- Teardown isolado por teste para garantir idempotência

---

## ▶️ Instalação e Execução

### Clone o repositório

```bash
git clone git@github.com:arlendfs/qa-air-compass-uol.git
cd qa-air-compass-uol/Documentos/Fase_02/Sprint_02/Semana_04/Challenge_3
```

### Instale as dependências

```bash
pip install -r requirements.txt
```

### Pré-requisito: recriar o usuário admin (ambiente compartilhado)

> O ambiente `compassuol.serverest.dev` é compartilhado. Execute este script antes de rodar as suites se o login retornar 401.

```bash
robot utils/recreate_admin.robot
```

### Execute todas as suites

```bash
robot -d ./logs tests/
```

### Execute por tag

```bash
robot -d ./logs --include smoke tests/
robot -d ./logs --include contrato tests/
robot -d ./logs --include segurança tests/
robot -d ./logs --include performance tests/
robot -d ./logs --include bug tests/
```

### Execute por domínio (prefixo de CT)

```bash
robot -d ./logs tests/01_login.robot           # CT-LGN
robot -d ./logs tests/02_usuarios.robot        # CT-USR (01-12, inclui atualização)
robot -d ./logs tests/03_produtos.robot        # CT-PRD
robot -d ./logs tests/04_carrinho.robot        # CT-CRT
robot -d ./logs tests/05_security.robot        # CT-SEC
robot -d ./logs tests/06_edge_cases.robot      # CT-EDG
robot -d ./logs tests/07_performance.robot     # CT-PER
```

---

## 📊 Distribuição dos Testes por Categoria

```
Positivo    ████████████░░░░  18 CTs  (30%)
Negativo    ████████████████  22 CTs  (37%)
Contrato    ████░░░░░░░░░░░░   6 CTs  (10%)
Segurança   ████░░░░░░░░░░░░   8 CTs  (13%)
Edge Cases  ████░░░░░░░░░░░░   8 CTs  (13%)
Performance ██░░░░░░░░░░░░░░   5 CTs   (8%)
Bug         ██░░░░░░░░░░░░░░   5 CTs   (8%)
```

---

## 👨💻 Autor

**Arlen Freitas** — [GitHub](https://github.com/arlendfs)  
Estágio em QA — Automação de Testes · AI/R Compass UOL
