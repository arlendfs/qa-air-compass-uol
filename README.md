# Challenge 3: Automação de API REST com Robot Framework

## Descrição do Projeto
Este repositório contém a automação de testes da API ServeRest, desenvolvida como parte do Challenge 3 do programa de bolsas da AI/R Compass UOL. O objetivo é validar fluxos críticos (Login, Usuários, Produtos e Carrinho) e garantir a integridade do contrato da API.


## Estrutura do Framework

A organização segue a separação de responsabilidades
(Actions/Keywords e TestCases):

```text
Challenge_03/
  |--- logs/
  |--- resourcers/   
        - login_page.resource
        - users_page.resource
        - prod-page.resource
        - cart-page.resource
  |--- common.resource
  |--- tests/
        - 01_login.robot
        - 02_usuarios.robot
        - 03_produtos.robot
        - 04_carrinho.robot
  |--- .gitignore
  README.md
  requirements.txt
```
## Tecnologia e Conceitos Aplicados

- Robot Framework: RequestsLibrary, Collections, String.
- Lógica de Automação:
    - Arguments & Variables: Parametrização de keywords.
    - Dictionaries & List: Manipulação de payloads JSON.
    - Control Structures: Uso de FOR e IF/ELSE para validações dinâmicas
    - Session Management: Persistência de conexão com a API.
## Instalação e Execução

Clone o repositório:

```bash
  git clone git@github.com:arlendfs/qa-air-compass-uol.git
  cd qa-air-compass-uol/Documentos/Fase_02/Sprint_02/Semana_04/Challenge_3
```

Instale as dependêncies:

```bash
  pip install -r requirements.txt
```

Execute a suíte completa:

```bash
  robot -d ./logs tests/
```


## Autor

- [@arlendfs](https://www.github.com/arlendfs)
