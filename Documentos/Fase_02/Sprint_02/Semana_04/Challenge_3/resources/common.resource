*** Settings ***
Documentation    Common resources: session management, authentication, and shared utilities.
Library    Collections
Library    String
Library    RequestsLibrary


*** Variables ***
${BASE_URL}           https://compassuol.serverest.dev
${USER_NAME}          Arlen
${ADMIN_EMAIL}        fulano@qa.com
${ADMIN_PASSWORD}     teste
${ADMINISTRADOR}      true
${VERIFY_SSL}         ${False}


*** Keywords ***
Create Authenticated Session
    [Documentation]    Creates the reusable HTTP session and stores a fresh Bearer token as a suite variable.
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session    serverest    ${BASE_URL}    headers=${headers}
    ...    verify=${VERIFY_SSL}    disable_warnings=1
    # Import here to avoid circular dependency — auth_service imports common.resource
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    ${token}    Get From Dictionary    ${res.json()}    authorization
    Set Suite Variable    ${TOKEN}    ${token}

Criar Sessão ServeRest
    [Documentation]    Backward-compatible alias for Create Authenticated Session.
    Create Authenticated Session

Pegar Token de Autenticação
    [Documentation]    Returns a fresh Bearer token. Kept for backward compatibility.
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    ${token}    Get From Dictionary    ${res.json()}    authorization
    RETURN    ${token}

Gerar Email Aleatório
    [Documentation]    Generates a unique email to avoid conflicts between runs.
    ${sufixo}    Generate Random String    length=6    chars=[LETTERS][NUMBERS]
    ${sufixo}    Convert To Lower Case    ${sufixo}
    ${email}    Set Variable    test_${sufixo}@emailteste.com
    RETURN    ${email}

Gerar Nome Único
    [Documentation]    Generates a unique name with a configurable prefix.
    [Arguments]    ${prefixo}=Item
    ${sufixo}    Generate Random String    length=8    chars=[LETTERS][NUMBERS]
    ${nome}    Set Variable    ${prefixo} ${sufixo}
    RETURN    ${nome}

Validar Resposta Da API
    [Documentation]    Generic reusable assertion: validates status code and response message.
    [Arguments]    ${res}    ${status_esperado}    ${mensagem_esperada}    ${campo}=message
    ${valor}    Get From Dictionary    ${res.json()}    ${campo}
    Should Be Equal As Integers    ${res.status_code}    ${status_esperado}
    Should Be Equal As Strings     ${valor}    ${mensagem_esperada}
