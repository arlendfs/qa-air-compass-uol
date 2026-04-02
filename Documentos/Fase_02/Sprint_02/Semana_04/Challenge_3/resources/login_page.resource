*** Settings ***
Documentation    Login keywords — Gherkin actions and assertions for POST /login.
Resource    common.resource
Resource    ../services/auth_service.resource


*** Keywords ***
Quando Realizo Login Com
    [Documentation]    Sends POST /login and stores the response in ${res}.
    [Arguments]    ${email}    ${password}
    ${res}    Login User    ${email}    ${password}
    Set Test Variable    ${res}

Então O Login Deve Ser Bem-Sucedido
    [Documentation]    Asserts status 200 and presence of the token in the response.
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    authorization

Então O Login Deve Falhar Com Status
    [Documentation]    Asserts error status and the message returned by the API.
    [Arguments]    ${status_esperado}    ${mensagem_esperada}    ${campo}=message
    Validar Resposta Da API    ${res}    ${status_esperado}    ${mensagem_esperada}    ${campo}
