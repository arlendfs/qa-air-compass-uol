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

| Suite | Arquivo | CTs | Categorias |
|---|---|---|---|
| Login | `01_login.robot` | CT-01 a CT-07 | Positivo, Negativo, Contrato, Edge |
| Usuários | `02_usuarios.robot` | CT-08 a CT-16 | Positivo, Negativo, Contrato, Bug |
| Produtos | `03_produtos.robot` | CT-17 a CT-25 | Positivo, Negativo, Contrato, Bug, Edge |
| Carrinho | `04_carrinho.robot` | CT-26 a CT-36 | Positivo, Negativo, Contrato, Edge, Segurança |
| Atualização de Usuários | `04_usuarios_update.robot` | CT-37 a CT-39 | Positivo, Bug |
| Segurança | `05_security.robot` | CT-40 a CT-47 | Autenticação, Autorização, Injeção |
| Edge Cases | `06_edge_cases.robot` | CT-48 a CT-55 | Boundary, Unicode, Limites, Concorrência |
| Performance | `07_performance.robot` | CT-56 a CT-60 | SLA, Carga Concorrente |

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
| BUG-12a | `PUT /usuarios/{id}` — aceita `nome` vazio | High | CT-38 |
| BUG-12b | `PUT /usuarios/{id}` — aceita `password` vazio | High | CT-39 |
| BUG-13 | `PUT /produtos/{id}` — permite nome duplicado | Medium | CT-21 |
| BUG-14 | `DELETE /usuarios/{id}` — deleta usuário com carrinho ativo | High | CT-14 |
| BUG-15 | `GET /usuarios` — endpoint público sem autenticação | Critical | CT-40 |
| BUG-16 | `POST /usuarios` — aceita `nome` com 500+ chars | Low | CT-49 |
| BUG-17 | `POST /produtos` — aceita `preco=0` | Low | CT-51 |

> Detalhes completos em [`BUG_REPORT.md`](./BUG_REPORT.md)

---

## 🏗️ Arquitetura do Projeto

```text
Challenge_3/
│
├── tests/
│   ├── 01_login.robot
│   ├── 02_usuarios.robot
│   ├── 03_produtos.robot
│   ├── 04_carrinho.robot
│   ├── 04_usuarios_update.robot
│   ├── 05_security.robot
│   ├── 06_edge_cases.robot
│   └── 07_performance.robot
│
├── resources/
│   ├── common.resource
│   ├── login_page.resource
│   ├── users_page.resource
│   ├── users_update_page.resource
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
│   ├── recreate_admin.robot
│   ├── contract.resource
│   ├── logger.resource
│   └── retry.resource
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

### Execute uma suite específica

```bash
robot -d ./logs/performance tests/07_performance.robot
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

## 👨‍💻 Autor

**Arlen Freitas** — [GitHub](https://github.com/arlendfs)  
Desenvolvedor — Automação de Testes · AI/R Compass UOL
