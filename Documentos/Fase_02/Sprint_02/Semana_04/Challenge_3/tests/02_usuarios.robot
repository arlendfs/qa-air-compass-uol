*** Settings ***
Documentation    Users suite — create and search flows for /usuarios endpoint.
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../utils/logger.resource
Suite Setup      Users Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        usuarios    regression


*** Test Cases ***
CT-04: Cadastrar Novo Usuário Administrador Com Sucesso
    [Documentation]    A new user with valid data must be registered successfully.
    [Tags]    smoke    critical    positivo
    Log Step    CT-04    Create new admin user
    Quando Cadastro Um Novo Usuário
    Então O Cadastro De Usuário Deve Ter Sucesso

CT-05: Tentar Cadastrar Usuário Com E-mail Já Existente
    [Documentation]    Registering with a duplicate email must return a 400 conflict error.
    [Tags]    negativo
    Log Step    CT-05    Duplicate email conflict
    Dado Que Existe Um Usuário Cadastrado
    Quando Tento Cadastrar Um Usuário Com Email Já Existente
    Então O Cadastro De Usuário Deve Falhar Com    Este email já está sendo usado

CT-06: Buscar Usuário Por ID E Validar Campos Obrigatórios
    [Documentation]    A registered user must be found by ID with all contract fields present.
    [Tags]    positivo    contrato
    Log Step    CT-06    Get user by ID and validate contract
    Dado Que Existe Um Usuário Cadastrado
    Quando Busco O Usuário Por ID
    Então Os Dados Do Usuário Devem Estar Corretos


*** Keywords ***
Users Suite Setup
    Log Suite Banner    Users Suite — /usuarios
    Criar Sessão ServeRest
