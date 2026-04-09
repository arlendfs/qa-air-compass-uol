*** Settings ***
Documentation    Recursos comuns: configuração de sessão, autenticação e utilitários gerais.
# SeleniumLibrary removida — projeto é exclusivamente API REST, não há UI.
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
Criar Sessão ServeRest
    [Documentation]    Cria a sessão HTTP reutilizável para toda a suite.
    ${headers}    Create Dictionary    accept=application/json    Content-Type=application/json
    Create Session    serverest    ${BASE_URL}    headers=${headers}
    ...    verify=${VERIFY_SSL}    disable_warnings=1

Pegar Token de Autenticação
    [Documentation]    Realiza login e retorna o Bearer token. Usa credenciais de admin por padrão.
    [Arguments]    ${email}=${ADMIN_EMAIL}    ${password}=${ADMIN_PASSWORD}
    &{body}    Create Dictionary    email=${email}    password=${password}
    ${res}    POST On Session    serverest    /login    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Should Be Equal As Integers    ${res.status_code}    200
    ...    msg=Falha no login com '${email}' — status: ${res.status_code} | body: ${res.text}. Verifique se o usuário existe no ambiente.
    ${token}    Get From Dictionary    ${res.json()}    authorization
    RETURN    ${token}

Gerar Email Aleatório
    [Documentation]    Gera um email único para evitar conflitos entre execuções.
    ${sufixo}    Generate Random String    length=6    chars=[LETTERS][NUMBERS]
    ${sufixo}    Convert To Lower Case    ${sufixo}
    ${email}    Set Variable    test_${sufixo}@emailteste.com
    RETURN    ${email}

Gerar Nome Único
    [Documentation]    Gera um nome único com prefixo configurável. Usado por usuários, produtos, etc.
    # Centralizado aqui para evitar duplicação entre resources de página.
    [Arguments]    ${prefixo}=Item
    ${sufixo}    Generate Random String    length=8    chars=[LETTERS][NUMBERS]
    ${nome}    Set Variable    ${prefixo} ${sufixo}
    RETURN    ${nome}

Validar Resposta Da API
    [Documentation]    Asserção genérica reutilizável: valida status code e mensagem da resposta.
    # Evita repetir Should Be Equal As Integers + Should Be Equal As Strings em todo test case.
    [Arguments]    ${res}    ${status_esperado}    ${mensagem_esperada}    ${campo}=message
    # ${campo} extraído antes da asserção — interpolação dentro de ['...'] não é expandida pelo RF.
    ${valor}    Get From Dictionary    ${res.json()}    ${campo}
    Should Be Equal As Integers    ${res.status_code}    ${status_esperado}
    Should Be Equal As Strings     ${valor}    ${mensagem_esperada}
