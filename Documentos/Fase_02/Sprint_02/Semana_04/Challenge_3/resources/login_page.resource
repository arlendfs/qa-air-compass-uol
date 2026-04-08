*** Settings ***
Documentation    Keywords de login: ações e asserções separadas seguindo o padrão Gherkin.
Library    OperatingSystem
Library    Collections
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

Então O Contrato De Login Deve Estar Correto
    [Documentation]    Valida que a resposta 200 contém exatamente os campos message e authorization com tipos corretos.
    [Arguments]    ${res}
    Should Be Equal As Integers    ${res.status_code}    200
    ${body}    Set Variable    ${res.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    authorization
    ${auth}    Get From Dictionary    ${body}    authorization
    Should Start With    ${auth}    Bearer
    Should Be True    len('${auth}') > 7

Quando Realizo Login Com Body Raw
    [Documentation]    Envia POST /login com payload de string bruta (não-JSON) para testar rejeição de body malformado.
    [Arguments]    ${raw_body}
    ${headers}    Create Dictionary    Content-Type=application/json    accept=application/json
    ${res}    POST On Session    serverest    /login    data=${raw_body}
    ...    headers=${headers}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
