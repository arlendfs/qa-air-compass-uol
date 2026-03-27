*** Settings ***
Documentation    Suite de testes de Produtos — fluxos de criação e listagem no endpoint /produtos.
Resource    ../resources/common.resource
Resource    ../resources/prod_page.resource
Suite Setup      Inicializar Suite De Produtos
Suite Teardown   Delete All Sessions


*** Test Cases ***
CT-07: Cadastrar Novo Produto Com Sucesso
    [Documentation]    Um produto com dados válidos e nome único deve ser cadastrado com sucesso.
    [Tags]    produtos    positivo    smoke
    Quando Cadastro Um Novo Produto    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Ter Sucesso

CT-08: Tentar Cadastrar Produto Com Nome Duplicado
    [Documentation]    Tentar cadastrar com nome já existente deve retornar erro de conflito.
    [Tags]    produtos    negativo
    Dado Que Existe Um Produto Cadastrado    ${TOKEN_ADMIN}
    Quando Tento Cadastrar Um Produto Com Nome Já Existente    ${TOKEN_ADMIN}
    Então O Cadastro De Produto Deve Falhar Com    Já existe produto com esse nome

CT-09: Listar Todos Os Produtos E Validar Contrato
    [Documentation]    A listagem deve retornar 200 e os produtos devem conter os campos obrigatórios.
    [Tags]    produtos    positivo    contrato
    Quando Listo Todos Os Produtos
    Então A Listagem De Produtos Deve Estar Correta


*** Keywords ***
Inicializar Suite De Produtos
    [Documentation]    Cria sessão e obtém token de admin. Expõe ${TOKEN_ADMIN} para toda a suite.
    # Keyword de setup mantida no arquivo de teste pois é específica desta suite.
    # Resources de página não devem conhecer o ciclo de vida da suite.
    Criar Sessão ServeRest
    ${token}    Pegar Token de Autenticação
    Set Suite Variable    ${TOKEN_ADMIN}    ${token}
