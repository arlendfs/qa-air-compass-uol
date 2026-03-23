*** Settings ***
Resource    common.resource

*** Variables ***
${ID_USUARIO_TESTE}    ${EMPTY}
${EMAIL_USUARIO_TESTE}    ${EMPTY}

*** Keywords ***
Criar Sessão ServeRest E Criar Usuario Teste
    [Documentation]    Cria uma sessão para a API ServeRest e um usuário para teste de atualização
    Criar Sessão ServeRest
    ${email}    Gerar Email Aleatório
    &{body}    Create Dictionary    nome=Arlen Original    email=${email}    password=teste    administrador=true
    ${res}    POST On Session    serverest    /usuarios    json=${body}    expected_status=any    verify=${VERIFY_SSL}

    ${ID_USUARIO_TESTE}    Set Variable   ${res.json()['_id']}
    ${EMAIL_USUARIO_TESTE}    Set Variable    ${email}

    Set Suite Variable    ${ID_USUARIO_TESTE}
    Set Suite Variable    ${EMAIL_USUARIO_TESTE}

Limpar Usuario Teste
    [Documentation]    Limpa o usuário criado para teste de atualização
    DELETE On Session    serverest    /usuarios/${ID_USUARIO_TESTE}    expected_status=any    verify=${VERIFY_SSL}
    Log    Usuário de teste limpo com ID: ${ID_USUARIO_TESTE}

Atualizar Usuário Por ID
    [Documentation]    Atualiza um usuário específico por ID
    [Arguments]    ${user_id}    ${nome}    ${email}    ${password}    ${administrador}
    ${body}    Create Dictionary    nome=${nome}    email=${email}    password=${password}    administrador=${administrador}
    ${res}    PUT On Session    serverest    /usuarios/${user_id}    json=${body}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Buscar Usuário Por ID
    [Documentation]    Busca um usuário específico por ID
    [Arguments]    ${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
