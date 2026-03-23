*** Settings ***
Resource    common.resource


*** Keywords ***
Cadastrar Usuário
    [Documentation]    Cadastra um novo usuário com dados válidos
    [Arguments]    ${nome}    ${email}    ${password}
    &{body}    Create Dictionary    nome=${nome}    email=${email}    password=${password}    administrador=true
    ${res}    POST On Session    serverest    /usuarios    json=${body}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Pesquisar Usuário Por ID
    [Documentation]    Pesquisa um usuário pelo ID
    [Arguments]    ${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

