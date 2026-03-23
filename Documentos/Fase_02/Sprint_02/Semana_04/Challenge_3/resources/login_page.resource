*** Settings ***
Documentation   Recursos específicos para os testes de login da API ServeRest
Resource    common.resource


*** Keywords ***
Fazer Login
    [Documentation]    Realiza login com as credenciais fornecidas
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}    expected_status=ANY    verify=${VERIFY_SSL}
    RETURN    ${res}
