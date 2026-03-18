*** Settings ***
Documentation   Recursos comuns para os testes da API ServeRest
Library    Collections
Library    String
Library    SeleniumLibrary
Library    RequestsLibrary


*** Variables ***
${BASE_URL}          https://compassuol.serverest.dev
${USER_NAME}         arlen_qa
${ADMIN_EMAIL}       fulano@qa.com
${ADMIN_PASSWORD}    teste
${ADMNISTRADOR}      true
${VERIFY_SSL}        ${false}


*** Keywords ***
Criar Sessão ServeRest
    [Documentation]    Cria uma sessão para o ServeRest
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session    serverest    ${BASE_URL}    headers=${headers}    verify=${VERIFY_SSL}

Pegar Token de Autenticação
    [Documentation]    Realiza login e retorna o token de autenticação
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}
    ${token}    Get From Dictionary    ${res.json()}    authorization
    RETURN    ${token}

Gerar Email Aleatório
    [Documentation]    Gera um email aleatório para testes
    ${aleatorio}    Generate Random String    length=4    chars=[LETTERS][NUMBERS]
    ${aleatorio}    Convert To Lower Case    ${aleatorio}
    ${email}    Set Variable     test_user_${aleatorio}@emailteste.com
    Log    Email gerado: ${email}
    RETURN    ${email}
