![Robot Framework](https://img.shields.io/badge/Robot%20Framework-Automation-green)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
# 🚀 Challenge 3: Automação de API REST com Robot Framework

## 📌 Visão Geral

Este projeto contém a automação de testes da API ServeRest, desenvolvido como parte do Challenge 3 do programa de bolsas da AI/R Compass UOL.

O objetivo é validar fluxos críticos da aplicação e garantir a confiabilidade da API por meio de testes funcionais e validação de contrato.

---

## 🎯 Cenários Cobertos

* 🔐 Login (Autenticação)
* 👤 Gestão de Usuários
* 📦 Gestão de Produtos
* 🛒 Carrinho e Checkout
* 📜 Validação de Contrato da API (estrutura e integridade)

---

## 🏗️ Arquitetura do Projeto

O framework segue uma estrutura modular e escalável, baseada em separação de responsabilidades:

```text
Challenge_03/
│
├── logs/
├── resources/
│   ├── common.resource
│   ├── login_page.resource
│   ├── users_page.resource
│   ├── prod_page.resource
│   ├── cart_page.resource
│
├── tests/
│   ├── 01_login.robot
│   ├── 02_usuarios.robot
│   ├── 03_produtos.robot
│   ├── 04_carrinho.robot
├── .gitignore
├── README.md
├── requirements.txt
```

---

## ⚙️ Tecnologias e Conceitos Aplicados

### 🧪 Tecnologias

* Robot Framework
* RequestsLibrary
* Collections
* String

### 🧠 Conceitos

* Padrão Gherkin (Given / When / Then)
* Separação de responsabilidades (Resources vs Tests)
* Reutilização de keywords
* Manipulação de dados dinâmicos
* Gerenciamento de sessão (Session Management)
* Validação de contrato (Contract Testing)

---

## ▶️ Instalação e Execução

### Clone o repositório:

```bash
git clone git@github.com:arlendfs/qa-air-compass-uol.git
cd qa-air-compass-uol/Documentos/Fase_02/Sprint_02/Semana_04/Challenge_3
```

### Instale as dependências:

```bash
pip install -r requirements.txt
```

### Execute os testes:

```bash
robot -d ./logs tests/
```

---

## 📈 Evoluções do Projeto

* Implementação de testes de contrato
* Padronização com Gherkin
* Estrutura modular escalável
* Melhoria na legibilidade e manutenção dos testes
  
---

## 👨‍💻 Autor

* Arlen — [GitHub](https://github.com/arlendfs)
