*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/users_page.resource
Suite Setup    Criar Sessão ServeRest


*** Test Cases ***
CT-04: Cadastrar Novo Usuário Administrador Com Sucesso
    [Documentation]    Verifica se é possível cadastrar um novo usuário administrador com dados válidos
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário   ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Should Be Equal As Integers    ${res.status_code}    201
    Dictionary Should Contain Key    ${res.json()}    message
    Should Be Equal As Strings    ${res.json()['message']}    Cadastro realizado com sucesso

CT-05: Tentar Cadastrar Usuário Com E-mail Já Existente
    [Documentation]    Verifica se o sistema impede o cadastro de um usuário com email já existente
    &{body}    Create Dictionary    nome=Arlen    email=beltrano@qa.com    password=teste    administrador=true
    ${res}    POST On Session    serverest    /usuarios    json=${body}    expected_status=any    verify=${VERIFY_SSL}
    Status Should Be    400    ${res}
    Should Be Equal As Strings    ${res.json()['message']}    Este email já está sendo usado

CT-06: Buscar Usuário por ID E Validar Campos Obrigatórios
    [Documentation]    Verifica se é possível buscar um usuário por ID e validar os campos obrigatórios
    ${email}    Gerar Email Aleatório
    ${res_cadastro}    Cadastrar Usuário   ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Should Be Equal As Integers    ${res_cadastro.status_code}    201
    ${user_id}    Get From Dictionary    ${res_cadastro.json()}    _id
    ${res_busca}    Pesquisar Usuário Por ID   ${user_id}
    Should Be Equal As Integers    ${res_busca.status_code}    200
    Dictionary Should Contain Key    ${res_busca.json()}    nome
    Dictionary Should Contain Key    ${res_busca.json()}    email
    