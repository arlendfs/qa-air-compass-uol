*** Settings ***
Documentation    User keywords — Gherkin Given/When/Then for /usuarios endpoint.
Resource    common.resource
Resource    ../services/user_service.resource


*** Keywords ***
Dado Que Existe Um Usuário Cadastrado
    [Documentation]    Creates a user via API and exposes ${ID_USUARIO} and ${EMAIL_USUARIO}.
    ${email}    Gerar Email Aleatório
    ${res}      Create User    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Então O Cadastro De Usuário Deve Ter Sucesso    ${res}
    Set Test Variable    ${ID_USUARIO}     ${res.json()['_id']}
    Set Test Variable    ${EMAIL_USUARIO}  ${email}

Quando Cadastro Um Novo Usuário
    [Documentation]    Sends POST /usuarios with valid unique data.
    ${email}    Gerar Email Aleatório
    ${res}      Create User    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Tento Cadastrar Um Usuário Com Email Já Existente
    [Documentation]    Reuses an existing email to force a 400 conflict.
    ${res}    Create User    ${USER_NAME}    ${EMAIL_USUARIO}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Busco O Usuário Por ID
    [Documentation]    Sends GET /usuarios/{id} using the ID exposed by the Given.
    ${res}    Get User By ID    ${ID_USUARIO}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Então O Cadastro De Usuário Deve Ter Sucesso
    [Documentation]    Asserts status 201 and success message.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Validar Resposta Da API    ${res}    201    Cadastro realizado com sucesso

Então O Cadastro De Usuário Deve Falhar Com
    [Documentation]    Asserts status 400 and the expected error message.
    [Arguments]    ${mensagem_esperada}    ${res}=${RESPOSTA_USUARIO}
    Validar Resposta Da API    ${res}    400    ${mensagem_esperada}

Então Os Dados Do Usuário Devem Estar Corretos
    [Documentation]    Asserts status 200 and presence of mandatory contract fields.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    nome
    Dictionary Should Contain Key    ${res.json()}    email
    Dictionary Should Contain Key    ${res.json()}    administrador
