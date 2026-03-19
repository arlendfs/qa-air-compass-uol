*** Settings ***
Documentation   Testes de Login para a API ServeRest
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
Suite Setup    Criar Sessão ServeRest


*** Test Cases ***
CT-01: Login Com Credenciais Válidas
    [Documentation]    Verifica se o login é bem-sucedido com credenciais válidas
    ${res}    Fazer Login    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    authorization

CT-02: Login Com Senha Inválida
    [Documentation]    Verifica se o login falha com uma senha inválida
    ${res}    Fazer Login    ${ADMIN_EMAIL}    senha_incorreta
    Should Be Equal As Integers    ${res.status_code}    401    ${res}
    Dictionary Should Contain Key    ${res.json()}    message
    Should Be Equal As Strings    ${res.json()['message']}    Email e/ou senha inválidos

CT-03: Login Com Email Com Formato Inválido
    [Documentation]    Verifica se o login falha com um email em formato Inválido
    ${res}    Fazer Login    email_Inválido    ${ADMIN_PASSWORD}
    Should Be Equal As Integers    ${res.status_code}    400    ${res}
    Dictionary Should Contain Key    ${res.json()}    email
    Should Be Equal As Strings    ${res.json()['email']}    email deve ser um email válido