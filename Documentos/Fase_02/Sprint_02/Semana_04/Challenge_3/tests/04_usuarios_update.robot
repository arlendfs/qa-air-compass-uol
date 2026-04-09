*** Settings ***
Documentation    Suite de testes de Atualização de Usuários — valida o endpoint PUT /usuarios/{id}.
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Resource    ../resources/users_update_page.resource
Suite Setup      Criar Sessão ServeRest E Criar Usuario Teste
Suite Teardown   Limpar Usuario Teste


*** Test Cases ***
CT-37: Atualizar Usuário Com Sucesso
    [Documentation]    Dado dados válidos, a atualização deve retornar 200 e persistir os novos valores.
    [Tags]    usuarios    atualizar    positivo
    ${novo_nome}     Set Variable    Arlen Atualizado
    ${novo_email}    Gerar Email Aleatório
    ${res}    Atualizar Usuário Por ID
    ...    ${ID_USUARIO_TESTE}    ${novo_nome}    ${novo_email}    teste123    true
    Log    [CT-37 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    Status Should Be    200    ${res}
    Should Be Equal As Strings    ${res.json()['message']}    Registro alterado com sucesso
    ${res_busca}    Pesquisar Usuário Por ID    ${ID_USUARIO_TESTE}
    Should Be Equal As Strings    ${res_busca.json()['nome']}     ${novo_nome}
    Should Be Equal As Strings    ${res_busca.json()['email']}    ${novo_email}

CT-38: [BUG] Atualizar Usuário Com Nome Vazio
    [Documentation]    BUG-12: API não deveria aceitar nome vazio no PUT /usuarios/{id}.
    ...                Registra o comportamento atual — se aceitar (200), loga como WARN.
    [Tags]    usuarios    atualizar    bug
    ${email}    Gerar Email Aleatório
    ${res}    Atualizar Usuário Por ID    ${ID_USUARIO_TESTE}    ${EMPTY}    ${email}    teste123    true
    Log    [CT-38 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    IF    ${res.status_code} == 200
        Log    BUG-12: API aceitou nome vazio — Status: ${res.status_code} | Body: ${res.text}    WARN
    ELSE
        Status Should Be    400    ${res}
    END

CT-39: [BUG] Atualizar Usuário Com Password Vazio
    [Documentation]    BUG-12: API não deveria aceitar password vazio no PUT /usuarios/{id}.
    ...                Registra o comportamento atual — se aceitar (200), loga como WARN.
    [Tags]    usuarios    atualizar    bug
    ${email}    Gerar Email Aleatório
    ${res}    Atualizar Usuário Por ID    ${ID_USUARIO_TESTE}    Arlen Teste    ${email}    ${EMPTY}    true
    Log    [CT-39 DEBUG] Status: ${res.status_code} | Body: ${res.text}    DEBUG
    IF    ${res.status_code} == 200
        Log    BUG-12: API aceitou password vazio — Status: ${res.status_code} | Body: ${res.text}    WARN
    ELSE
        Status Should Be    400    ${res}
    END
