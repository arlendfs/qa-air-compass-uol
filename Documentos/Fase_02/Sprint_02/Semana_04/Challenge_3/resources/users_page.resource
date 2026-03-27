*** Settings ***
Documentation    Keywords de usuários — camadas Given/When/Then para o endpoint /usuarios.
Resource    common.resource


*** Keywords ***
# ── Dado (Given) — pré-condições e estado inicial ───────────────────────────

Dado Que Existe Um Usuário Cadastrado
    [Documentation]    Cria um usuário via API e expõe ${ID_USUARIO} e ${EMAIL_USUARIO} como variáveis de teste.
    # Usado como pré-condição em cenários que dependem de um usuário já existente (ex: busca, duplicata).
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Então O Cadastro De Usuário Deve Ter Sucesso    ${res}
    Set Test Variable    ${ID_USUARIO}     ${res.json()['_id']}
    Set Test Variable    ${EMAIL_USUARIO}  ${email}

# ── Quando (When) — ações sobre o endpoint ──────────────────────────────────

Quando Cadastro Um Novo Usuário
    [Documentation]    Envia POST /usuarios com dados válidos e únicos.
    # Email gerado dinamicamente — elimina dependência de dados fixos no ambiente.
    ${email}    Gerar Email Aleatório
    ${res}      Cadastrar Usuário    ${USER_NAME}    ${email}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Tento Cadastrar Um Usuário Com Email Já Existente
    [Documentation]    Reutiliza o email de um usuário já criado para forçar conflito 400.
    # Depende de "Dado Que Existe Um Usuário Cadastrado" ter sido executado antes.
    ${res}    Cadastrar Usuário    ${USER_NAME}    ${EMAIL_USUARIO}    ${ADMIN_PASSWORD}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

Quando Busco O Usuário Por ID
    [Documentation]    Envia GET /usuarios/{id} usando o ID exposto pelo Given.
    ${res}    Pesquisar Usuário Por ID    ${ID_USUARIO}
    Set Test Variable    ${RESPOSTA_USUARIO}    ${res}

# ── Então (Then) — asserções de resultado ───────────────────────────────────

Então O Cadastro De Usuário Deve Ter Sucesso
    [Documentation]    Valida status 201 e mensagem de sucesso no cadastro.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Validar Resposta Da API    ${res}    201    Cadastro realizado com sucesso

Então O Cadastro De Usuário Deve Falhar Com
    [Documentation]    Valida status 400 e a mensagem de erro esperada.
    [Arguments]    ${mensagem_esperada}    ${res}=${RESPOSTA_USUARIO}
    Validar Resposta Da API    ${res}    400    ${mensagem_esperada}

Então Os Dados Do Usuário Devem Estar Corretos
    [Documentation]    Valida status 200 e presença dos campos obrigatórios do contrato /usuarios/{id}.
    [Arguments]    ${res}=${RESPOSTA_USUARIO}
    Should Be Equal As Integers    ${res.status_code}    200
    Dictionary Should Contain Key    ${res.json()}    nome
    Dictionary Should Contain Key    ${res.json()}    email
    Dictionary Should Contain Key    ${res.json()}    administrador

# ── Primitivas (baixo nível) — chamadas HTTP diretas ────────────────────────

Cadastrar Usuário
    [Documentation]    Primitiva HTTP: POST /usuarios. Usada pelas keywords Gherkin acima.
    [Arguments]    ${nome}    ${email}    ${password}    ${administrador}=${ADMINISTRADOR}
    &{body}    Create Dictionary    nome=${nome}    email=${email}
    ...    password=${password}    administrador=${administrador}
    ${res}    POST On Session    serverest    /usuarios    json=${body}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}

Pesquisar Usuário Por ID
    [Documentation]    Primitiva HTTP: GET /usuarios/{id}. Usada pelas keywords Gherkin acima.
    [Arguments]    ${user_id}
    ${res}    GET On Session    serverest    /usuarios/${user_id}
    ...    expected_status=any    verify=${VERIFY_SSL}
    RETURN    ${res}
