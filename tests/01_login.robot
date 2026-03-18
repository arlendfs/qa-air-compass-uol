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