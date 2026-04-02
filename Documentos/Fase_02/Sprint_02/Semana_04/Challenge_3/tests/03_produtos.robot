*** Settings ***
Documentation    Products suite — create and list flows for /produtos endpoint.
Resource    ../resources/common.resource
Resource    ../resources/prod_page.resource
Resource    ../utils/logger.resource
Suite Setup      Products Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        produtos    regression


*** Test Cases ***
CT-07: Cadastrar Novo Produto Com Sucesso
    [Documentation]    A product with valid data and a unique name must be registered successfully.
    [Tags]    smoke    critical    positivo
    Log Step    CT-07    Create new product
    Quando Cadastro Um Novo Produto    ${TOKEN}
    Então O Cadastro De Produto Deve Ter Sucesso

CT-08: Tentar Cadastrar Produto Com Nome Duplicado
    [Documentation]    Registering with a duplicate name must return a 400 conflict error.
    [Tags]    negativo
    Log Step    CT-08    Duplicate product name conflict
    Dado Que Existe Um Produto Cadastrado    ${TOKEN}
    Quando Tento Cadastrar Um Produto Com Nome Já Existente    ${TOKEN}
    Então O Cadastro De Produto Deve Falhar Com    Já existe produto com esse nome

CT-09: Listar Todos Os Produtos E Validar Contrato
    [Documentation]    The listing must return 200 and products must contain all mandatory fields.
    [Tags]    positivo    contrato
    Log Step    CT-09    List all products and validate contract
    Quando Listo Todos Os Produtos
    Então A Listagem De Produtos Deve Estar Correta


*** Keywords ***
Products Suite Setup
    Log Suite Banner    Products Suite — /produtos
    Create Authenticated Session
