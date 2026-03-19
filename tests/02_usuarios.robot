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
