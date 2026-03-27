*** Settings ***
Documentation    Keywords de atualização de usuários: setup/teardown de dados e operações PUT/GET do endpoint /usuarios.
Resource    common.resource


*** Variables ***
${ID_USUARIO_TESTE}      ${EMPTY}
${EMAIL_USUARIO_TESTE}   ${EMPTY}


*** Keywords ***
Criar Sessão ServeRest E Criar Usuario Teste
    [Documentation]    Cria sessão e provisiona um usuário de teste para a suite de atualização.
    Criar Sessão ServeRest
    ${email}    Gerar Email Aleatório
    &{body}    Create Dictionary    nome=Arlen Original    email=${email}
    ...    password=teste    administrador=true
    ${res}    POST On Session    serverest    /usuarios    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Set Suite Variable    ${ID_USUARIO_TESTE}    ${res.json()['_id']}
    Set Suite Variable    ${EMAIL_USUARIO_TESTE}    ${email}

Limpar Usuario Teste
    [Documentation]    Remove o usuário de teste criado no setup da suite.
    DELETE On Session    serverest    /usuarios/${ID_USUARIO_TESTE}
    ...    expected_status=any    verify=${VERIFY_SSL}
    Log    Usuário de teste removido — ID: ${ID_USUARIO_TESTE}

Atualizar Usuário Por ID
    [Documentation]    Envia PUT /usuarios/{id} com os dados fornecidos.
    [Arguments]    ${user_id}    ${nome}    ${email}    ${password}    ${administrador}
    ${body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    ${res}    PUT On Session    serverest    /usuarios/${user_id}    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Buscar Usuário Por ID
    [Documentation]    Envia GET /usuarios/{id} e retorna a resposta.
    [Arguments]    ${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
