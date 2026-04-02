*** Settings ***
Documentation    Users update suite — validates PUT /usuarios/{id} endpoint.
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../services/user_service.resource
Resource    ../utils/logger.resource
Suite Setup      Provisionar Usuário De Teste
Suite Teardown   Remover Usuário De Teste
Test Tags        usuarios    atualizar    regression


*** Variables ***
${ID_USUARIO_TESTE}      ${EMPTY}
${EMAIL_USUARIO_TESTE}   ${EMPTY}


*** Test Cases ***
CT-10: Atualizar Usuário Com Sucesso
    [Documentation]    Valid data must return 200 and persist the new values.
    [Tags]    smoke    critical    positivo
    Log Step    CT-10    Update user with valid data
    ${novo_nome}     Set Variable    Arlen Atualizado
    ${novo_email}    Gerar Email Aleatório
    ${res}    Update User By ID
    ...    ${ID_USUARIO_TESTE}    ${novo_nome}    ${novo_email}    teste123    true
    Should Be Equal As Integers    ${res.status_code}    200
    Should Be Equal As Strings    ${res.json()['message']}    Registro alterado com sucesso
    ${res_busca}    Get User By ID    ${ID_USUARIO_TESTE}
    Log Assertion    Updated nome persisted in GET /usuarios/{id}
    Should Be Equal As Strings    ${res_busca.json()['nome']}     ${novo_nome}
    Should Be Equal As Strings    ${res_busca.json()['email']}    ${novo_email}

CT-11: [BUG] Atualizar Usuário Com Nome Vazio
    [Documentation]    BUG-12: API should not accept an empty name. Records current behavior.
    [Tags]    bug    edge
    Log Step    CT-11    BUG-12 — update with empty name
    ${email}    Gerar Email Aleatório
    ${res}    Update User By ID    ${ID_USUARIO_TESTE}    ${EMPTY}    ${email}    teste123    true
    IF    ${res.status_code} == 200
        Log    BUG-12: API aceitou nome vazio — Status: ${res.status_code}    WARN
    ELSE
        Should Be Equal As Integers    ${res.status_code}    400
    END

CT-12: [BUG] Atualizar Usuário Com Password Vazio
    [Documentation]    BUG-12: API should not accept an empty password. Records current behavior.
    [Tags]    bug    edge
    Log Step    CT-12    BUG-12 — update with empty password
    ${res}    Update User By ID    ${ID_USUARIO_TESTE}    Arlen Teste    email_invalido    ${EMPTY}    true
    IF    ${res.status_code} == 200
        Log    BUG-12: API aceitou password vazio — Status: ${res.status_code}    WARN
    ELSE
        Should Be Equal As Integers    ${res.status_code}    400
    END


*** Keywords ***
Provisionar Usuário De Teste
    Log Suite Banner    Users Update Suite — PUT /usuarios/{id}
    Criar Sessão ServeRest
    ${email}    Gerar Email Aleatório
    ${res}    Create User    Arlen Original    ${email}    teste    true
    Set Suite Variable    ${ID_USUARIO_TESTE}     ${res.json()['_id']}
    Set Suite Variable    ${EMAIL_USUARIO_TESTE}  ${email}

Remover Usuário De Teste
    Delete User By ID    ${ID_USUARIO_TESTE}
    Delete All Sessions
