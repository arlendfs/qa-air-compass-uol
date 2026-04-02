*** Settings ***
Documentation    Login suite — validates positive and negative flows for POST /login.
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
Resource    ../utils/logger.resource
Suite Setup      Login Suite Setup
Suite Teardown   Delete All Sessions
Test Tags        login    regression


*** Test Cases ***
CT-01: Login Com Credenciais Válidas
    [Documentation]    Valid credentials must return 200 and a Bearer token.
    [Tags]    smoke    critical    positivo
    Log Step    CT-01    Login with valid credentials
    Quando Realizo Login Com    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Então O Login Deve Ser Bem-Sucedido

CT-02: Login Com Senha Inválida
    [Documentation]    Wrong password must return 401 with an error message.
    [Tags]    negativo
    Log Step    CT-02    Login with wrong password
    Quando Realizo Login Com    ${ADMIN_EMAIL}    senha_incorreta
    Então O Login Deve Falhar Com Status    401    Email e/ou senha inválidos

CT-03: Login Com Email Em Formato Inválido
    [Documentation]    Malformed email must return 400 with a validation message.
    [Tags]    negativo    edge
    Log Step    CT-03    Login with malformed email
    Quando Realizo Login Com    email_invalido    ${ADMIN_PASSWORD}
    Então O Login Deve Falhar Com Status    400    email deve ser um email válido    email


*** Keywords ***
Login Suite Setup
    Log Suite Banner    Login Suite — POST /login
    Criar Sessão ServeRest
