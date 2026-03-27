*** Settings ***
Documentation    Keywords de login: ações e asserções separadas seguindo o padrão Gherkin.
Resource    common.resource


*** Keywords ***
# ── Ações (When) ────────────────────────────────────────────────────────────

Quando Realizo Login Com
    [Documentation]    Envia a requisição POST /login com as credenciais fornecidas.
    [Arguments]    ${email}    ${password}
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

# ── Asserções (Then) ─────────────────────────────────────────────────────────

Então O Login Deve Ser Bem-Sucedido
    [Documentation]    Valida status 200 e presença do token na resposta.
    [Arguments]    ${res}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    authorization

Então O Login Deve Falhar Com Status
    [Documentation]    Valida status de erro e a mensagem retornada pela API.
    [Arguments]    ${res}    ${status_esperado}    ${mensagem_esperada}    ${campo}=message
    Should Be Equal As Integers    ${res.status_code}    ${status_esperado}
    Dictionary Should Contain Key    ${res.json()}    ${campo}
    Should Be Equal As Strings    ${res.json()['${campo}']}    ${mensagem_esperada}
